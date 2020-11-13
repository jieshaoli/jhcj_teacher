//
//  PLSettingsView.m
//  PLMediaStreamingKitDemo
//
//  Created by 冯文秀 on 2020/6/9.
//  Copyright © 2020 Pili. All rights reserved.
//

#import "PLSettingsView.h"

#import "PLSegmentTableViewCell.h"
#import "PLListArrTableViewCell.h"
#import "PLListArrayView.h"

#import "NSString+Random.h"

#define PL_SETTING_X_SPACE 20
#define PL_SETTING_Y_SPACE 5

static NSString *segmentIdentifier = @"segmentCell";
static NSString *listIdentifier = @"listCell";

@interface PLSettingsView()
<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
// 自定义 view 代理
PLListArrayViewDelegate
>
// 采集编码推流 sdk
@property (nonatomic, strong) PLMediaStreamingSession *mediaSession;
// 编码推流 sdk
@property (nonatomic, strong) PLStreamingSession *streamSession;

// configuration 和其他配置分栏
@property (nonatomic, strong) UISegmentedControl *setSegmentControl;

// PLMediaStreamingSession、PLStreamingSession 类型分栏
@property (nonatomic, strong) UISegmentedControl *typeSegmentControl;

// configuration 配置数组
@property (nonatomic, strong) NSMutableArray *configurationArray;
// session 配置数组
@property (nonatomic, strong) NSMutableArray *sessionArray;

// 推流 URL 地址
@property (nonatomic, strong) NSURL *streamURL;
// 推流 URL 生成按钮
@property (nonatomic, strong) UIButton *setButton;
// 所有配置的 tableView
@property (nonatomic, strong) UITableView *settingsTableView;

// 帮助判断是否是 session 的相关配置
@property (nonatomic, assign) NSInteger isSession;

@end

@implementation PLSettingsView

- (void)delloc {
    NSLog(@"[PLSettingsView] dealloc !");
}

- (id)initWithFrame:(CGRect)frame mediaSession:(PLMediaStreamingSession *)mediaSession streamSession:(PLStreamingSession *)streamSession pushURL:(NSString *)pushURL {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];

        _urlTextField = [[UITextField alloc] init];
        _urlTextField.borderStyle = UITextBorderStyleRoundedRect;
        _urlTextField.font = FONT_LIGHT(11.f);
        _urlTextField.textColor = [UIColor blackColor];
        _urlTextField.text = pushURL;
        _urlTextField.delegate = self;
        [self addSubview:_urlTextField];
        
        [self requestPublishURL];
        
        _setButton = [[UIButton alloc] init];
        _setButton.layer.borderColor = [UIColor blackColor].CGColor;
        _setButton.layer.borderWidth = 0.5f;
        _setButton.titleLabel.font = FONT_LIGHT(11.f);
        [_setButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_setButton setTitle:@"URL 生成" forState:UIControlStateNormal];
        [_setButton addTarget:self action:@selector(requestPublishURL) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_setButton];
    
        // 音视频/纯音频 采集推流
        _mediaSession = mediaSession;
        
        // 外部数据导入/录屏 源数据推流
        _streamSession = streamSession;
        
        _streamType = PLStreamTypeAll;
        
        // 推流类型
        UILabel *streamTypeLab = [[UILabel alloc]init];
        streamTypeLab.font = FONT_LIGHT(12.f);
        streamTypeLab.textColor = [UIColor blackColor];
        streamTypeLab.textAlignment = NSTextAlignmentLeft;
        streamTypeLab.text = @"推流类型：";
        [self addSubview:streamTypeLab];
        
        // 类型选择
        _typeSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"A&V", @"Audio only", @"Import", @"Screen"]];
        _typeSegmentControl.backgroundColor = [UIColor whiteColor];
        _typeSegmentControl.tintColor = COLOR_RGB(16, 169, 235, 1);
        _typeSegmentControl.selectedSegmentIndex = 0;
        [_typeSegmentControl addTarget:self action:@selector(streamTypeSegmentAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_typeSegmentControl];
        
        // 先确认分类
        _setSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Configuration 配置", @"Session 配置"]];
        _setSegmentControl.backgroundColor = [UIColor whiteColor];
        _setSegmentControl.tintColor = COLOR_RGB(16, 169, 235, 1);
        _setSegmentControl.selectedSegmentIndex = 0;
        [_setSegmentControl addTarget:self action:@selector(settingsSegmentAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_setSegmentControl];
        
        [self combineConfigurationSettings];
        [self combineSessionSettings];
        
        _isSession = 0;
        
        // 再给数据
        _settingsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _settingsTableView.backgroundColor = [UIColor whiteColor];
        _settingsTableView.delegate = self;
        _settingsTableView.dataSource = self;
        _settingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_settingsTableView registerClass:[PLSegmentTableViewCell class] forCellReuseIdentifier:segmentIdentifier];
        [_settingsTableView registerClass:[PLListArrTableViewCell class] forCellReuseIdentifier:listIdentifier];
        [self addSubview:_settingsTableView];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor blackColor];
        [self addSubview:lineView];
        
        
        // masonry 集中布局
        [_setButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right).offset(-PL_SETTING_X_SPACE);
            make.top.mas_equalTo(PL_SETTING_Y_SPACE);
            make.size.mas_equalTo(CGSizeMake(60, 26));
        }];
        
        [_urlTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(PL_SETTING_X_SPACE);
            make.right.mas_equalTo(_setButton.mas_left).offset(-15);
            make.top.mas_equalTo(PL_SETTING_Y_SPACE);
            make.height.mas_equalTo(26);
        }];
        
        [streamTypeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(PL_SETTING_X_SPACE);
            make.top.mas_equalTo(_urlTextField.mas_bottom).offset(14);
            make.size.mas_equalTo(CGSizeMake(60, 26));
        }];
        
        [_typeSegmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(streamTypeLab.mas_right);
            make.right.mas_equalTo(self.mas_right).offset(-PL_SETTING_X_SPACE);
            make.top.mas_equalTo(streamTypeLab.mas_top);
            make.height.mas_equalTo(26);
        }];
        
        [_setSegmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(PL_SETTING_X_SPACE);
            make.right.mas_equalTo(self.mas_right).offset(-PL_SETTING_X_SPACE);
            make.top.mas_equalTo(streamTypeLab.mas_bottom).offset(10);
            make.height.mas_equalTo(26);
        }];
        
        [_settingsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(PL_SETTING_X_SPACE);
            make.right.mas_equalTo(self.mas_right).offset(-PL_SETTING_X_SPACE);
            make.top.mas_equalTo(_setSegmentControl.mas_bottom).offset(10);
            make.bottom.mas_equalTo(self.mas_bottom).offset(7);
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(PL_SETTING_X_SPACE);
            make.right.mas_equalTo(self.mas_right).offset(-PL_SETTING_X_SPACE);
            make.top.mas_equalTo(_settingsTableView.mas_bottom).offset(6);
            make.height.mas_equalTo(0.8);
        }];

    }
    return self;
}

#pragma mark - 请求获取推流地址 URL
- (void)requestPublishURL {
#warning 填写自己的请求域名，以获取推流地址
    NSString *streamServer = @"";
    NSString *streamID = [NSString randomizedString];
    NSString *streamURLString = [streamServer stringByAppendingPathComponent:streamID];
    NSURL *URL = [NSURL URLWithString:streamURLString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil || response == nil || data == nil) {
            NSLog(@"get play json faild, %@, %@, %@", error, response, data);
            return;
        }
        NSString *streamString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *urlArray = [streamString componentsSeparatedByString:@"?"];
        
        // 更新推流的 URL
        _streamURL = [NSURL URLWithString:urlArray[0]];
        dispatch_async(dispatch_get_main_queue(), ^{
            _urlTextField.text = urlArray[0];
        });
    }];

    [task resume];
}

#pragma mark - 将 configuration 的相关配置转换成 model
- (void)combineConfigurationSettings {
    NSArray *configureArr;
    
    // PLVideoCaptureConfiguration 相关属性
    NSDictionary *videoFrameRateDict = @{@"videoFrameRate - 帧率 ( Default：24fps )":@[@"5", @"15", @"20", @"24", @"30"], @"default":@3};
     
    NSDictionary *sessionPresetDict;
    if ([IOS_SYSTEM_STRING compare:@"9.0.0"] >= 0){
        sessionPresetDict = @{@"sessionPreset - 预览分辨率 ( Default：640x480 )":@[@"352x288", @"640x480", @"1280x720", @"1920x1080", @"3840x2160"], @"default":@1};
    } else {
        sessionPresetDict = @{@"sessionPreset - 预览分辨率 ( Default：640x480 )":@[@"352x288", @"640x480", @"1280x720", @"1920x1080"], @"default":@1};
    }
    
    NSDictionary *previewMirrorFrontFacingDict = @{@"previewMirrorFrontFacing - 前置预览镜像 ( Default：YES )":@[@"NO", @"YES"], @"default":@1};
    NSDictionary *previewMirrorRearFacingDict = @{@"previewMirrorRearFacing - 后置预览镜像 ( Default：NO )":@[@"NO", @"YES"], @"default":@0};
    NSDictionary *streamMirrorFrontFacingDict = @{@"streamMirrorFrontFacing - 前置编码镜像 ( Default：NO )":@[@"NO", @"YES"], @"default":@0};
    NSDictionary *streamMirrorRearFacingDict = @{@"streamMirrorRearFacing - 后置编码镜像 ( Default：NO )":@[@"NO", @"YES"], @"default":@0};
    NSDictionary *cameraPositionDict = @{@"cameraPositon - 摄像头采集位置 ( Default：Back )":@[@"Unspecified", @"Back", @"Front"], @"default":@1};
    NSDictionary *videoOrientationDict = @{@"videoOrientation - 摄像头采集旋转方向 ( Default：Portrait )":@[@"Portrait", @"PortraitUpsideDown", @"LandscapeRight", @"LandscapeLeft"], @"default":@0};
     
    NSDictionary *videoCaptureDict = @{@"PLVideoCaptureConfiguration":@[videoFrameRateDict, sessionPresetDict, previewMirrorFrontFacingDict, previewMirrorRearFacingDict, streamMirrorFrontFacingDict, streamMirrorRearFacingDict, cameraPositionDict, videoOrientationDict]};
     
    // PLVideoStreamingConfiguration 相关属性
    NSDictionary *videoProfileLevelDict = @{@"videoProfileLevel - H264 编码等级 ( Default：H264Baseline31 )":@[@"H264Baseline30", @"H264Baseline31", @"H264Baseline41", @"H264BaselineAutoLevel", @"H264Main30", @"H264Main31", @"H264Main32", @"H264Main41", @"H264MainAutoLevel", @"H264High40", @"H264High41", @"H264HighAutoLevel"], @"default":@1};
    NSDictionary *videoSizeDict = @{@"videoSize - 编码尺寸 ( Default：720x1280 )":@[@"272x480", @"368x640", @"400x720", @"540x960", @"720x1280", @"1080x1280"], @"default":@3};
    NSDictionary *expectedSourceVideoFrameRateDict = @{@"expectedSourceVideoFrameRate - 预期视频源帧率 ( Default：24fps )":@[@"5", @"10", @"15", @"20", @"24", @"30"], @"default":@4};
    NSDictionary *videoMaxKeyframeIntervalDict = @{@"videoMaxKeyframeInterval - 最大关键帧间隔 ( Default：72fps )":@[@"15", @"30", @"45", @"60", @"72", @"90"], @"default":@4};
    NSDictionary *averageVideoBitRateDict = @{@"averageVideoBitRate - 平均编码码率 ( Default：768Kbps )":@[@"512Kbps", @"768Kbps", @"1024Kbps", @"1280Kbps", @"1536Kbps", @"2048Kbps"], @"default":@2};
    NSDictionary *videoEncoderTypeDict = @{@"videoEncoderType - H.264 编码器类型 ( Default：AVFoundation )":@[@"AVFoundation", @"VideoToolbox"], @"default":@0};
     
    NSDictionary *videoStreamingDict = @{@"PLVideoStreamingConfiguration":@[videoProfileLevelDict, videoSizeDict, expectedSourceVideoFrameRateDict, videoMaxKeyframeIntervalDict, averageVideoBitRateDict, videoEncoderTypeDict]};
     
    // PLAudioCaptureConfiguration 相关属性
    NSDictionary *audioCaptureDict = @{@"PLAudioCaptureConfiguration":@[@{@"channelsPerFrame - 采集音频声道数 ( Default：1 )":@[@"1", @"2"], @"default":@0}, @{@"acousticEchoCancellationEnable - 回声消除 ( Default：NO )":@[@"NO", @"YES"], @"default":@0}]};
     
    // PLAudioStreamingConfiguration 相关属性
    NSDictionary *audioStreamingDict = @{@"PLAudioStreamingConfiguration":@[@{@"encodedAudioSampleRate - 音频采样率 ( Default：48000Hz )":@[@"48000Hz",@"44100Hz",@"22050Hz", @"11025Hz"], @"default":@0}, @{@"audioBitRate - 音频编码码率 ( Default：96Kbps )":@[@"64Kbps", @"96Kbps", @"128Kbps"], @"default":@1}, @{@"encodedNumberOfChannels - 编码声道数 ( Default：1 )":@[@"1", @"2"], @"default":@0}, @{@"audioEncoderType - 编码类型 ( Default：iOS_AAC )":@[@"iOS_AAC", @"fdk_AAC_LC", @"fdk_AAC__HE_BSR"], @"default":@0}]};
    
    if (_streamType == PLStreamTypeAll) {
        configureArr = @[videoCaptureDict, videoStreamingDict, audioCaptureDict, audioStreamingDict];
    } else if (_streamType == PLStreamTypeAudioOnly) {
        configureArr = @[audioCaptureDict, audioStreamingDict];
    } else {
        configureArr = @[videoStreamingDict, audioStreamingDict];
    }
    // 装入属性数组
    _configurationArray = [NSMutableArray arrayWithArray:[PLCategoryModel categoryArrayWithArray:configureArr]];
}

#pragma mark - 将 seesion 的相关配置转换成 model
- (void)combineSessionSettings {
    NSArray *sessionArr;
    
    // PLMediaStreamingKit 相关的属性
    NSDictionary *fillModeDict = @{@"fillMode - 画面填充模式（ Default：RatioAndFill ）":@[@"Stretch", @"AspectRatio", @"RatioAndFill"], @"default":@1};
    NSDictionary *PLSessionDict = @{@"PLMediaStreamingKit":@[fillModeDict]};

    // PLStreamingKit 相关属性
    NSDictionary *quicDict = @{@"quicEnable - QUIC 协议推流（ Default：NO ）":@[@"NO", @"YES"], @"default":@0};
    NSDictionary *dynamicFrameEnableDict = @{@"dynamicFrameEnable - 动态帧率 ( Default：NO )":@[@"NO", @"YES"], @"default":@0};
    NSDictionary *adaptiveBitrateDict = @{@"adaptiveBitrate - 自适应码率 ( Default：disable )":@[@"disable", @"150kbps", @"200kbps", @"300kbps", @"500kbps"], @"default":@0};
    NSDictionary *autoReconnectEnableDict = @{@"autoReconnectEnable - 自动断线重连 ( Default：NO )":@[@"NO", @"YES"], @"default":@0};
    NSDictionary *monitorNetworkStateEnableDict = @{@"monitorNetworkStateEnable - 网络切换监测  ( Default：NO )":@[@"NO", @"YES"], @"default":@0};
    NSDictionary *statusUpdateIntervalDict = @{@"statusUpdateInterval - 流状态更新间隔 ( Default：3s )":@[@"1", @"3", @"5", @"10", @"15", @"20", @"30"], @"default":@1};
    NSDictionary *thresholdDict = @{@"threshold - 丢包策略的阀值 ( Default：0.5 )":@[@"0", @"0.5", @"0.25", @"0.75", @"1"], @"default":@0};
    NSDictionary *maxCountDict = @{@"maxCount - 队列最大容纳包 ( Default：300 )":@[@"0", @"50", @"100", @"150", @"300", @"450", @"600"], @"default":@4};
    
    NSDictionary *PLStreamingKitDict = @{@"PLStreamingKit":@[quicDict, dynamicFrameEnableDict, adaptiveBitrateDict, autoReconnectEnableDict, monitorNetworkStateEnableDict, statusUpdateIntervalDict, thresholdDict, maxCountDict]};
    
    // CameraSource 相关属性
    NSDictionary *cameraSourceDict = @{@"CameraSource": @[@{@"continuousAutofocusEnable - 连续自动对焦 ( Default：YES )":@[@"NO", @"YES"], @"default":@1}, @{@"touchToFocusEnable - 手动对焦 ( Default：YES )":@[@"NO", @"YES"], @"default":@1}, @{@"smoothAutoFocusEnabled - 减缓自动对焦抖动 ( Default：YES )":@[@"NO", @"YES"], @"default":@1}, @{@"torchOn - 手电筒 ( Default：NO )":@[@"NO", @"YES"], @"default":@0}]};
    
    // MicrophoneSource 相关属性
    NSDictionary *microphoneSourceDict = @{@"MicrophoneSource":@[@{@"playback - 返听功能 ( Default：NO )":@[@"NO", @"YES"], @"default":@0}, @{@"inputGain - 麦克风采集的音量 ( Default：1 )":@[@"1", @"0.8", @"0.6", @"0.4", @"0.2"], @"default":@0}, @{@"allowAudioMixWithOthers - 允许在后台与其他App混音不被打断 ( Default：NO )":@[@"NO", @"YES"], @"default":@0}]};
    
    // Applictaion
    NSDictionary *applicationDict = @{@"Applictaion":@[@{@"idleTimerDisable - 是否关闭系统屏幕自动锁屏 ( Default：YES )":@[@"NO", @"YES"], @"default":@1}]};
    
    if (_streamType == PLStreamTypeAll) {
        sessionArr = @[PLSessionDict, PLStreamingKitDict, cameraSourceDict, microphoneSourceDict, applicationDict];
    } else if (_streamType == PLStreamTypeAudioOnly) {
        sessionArr = @[PLStreamingKitDict, microphoneSourceDict, applicationDict];
    } else {
        sessionArr = @[PLStreamingKitDict, applicationDict];
    }
    // 装入属性数组
    _sessionArray = [NSMutableArray arrayWithArray:[PLCategoryModel categoryArrayWithArray:sessionArr]];
}

#pragma mark - segment action
- (void)settingsSegmentAction:(UISegmentedControl *)segment {
    NSInteger index = segment.selectedSegmentIndex;
    
    if (index == _isSession) {
        return;
    }
    _isSession = index;
    
    [_settingsTableView reloadData];
}

- (void)streamTypeSegmentAction:(UISegmentedControl *)segment {
    NSInteger index = segment.selectedSegmentIndex;
    _streamType = index;
    
    // 重新选择流类型后，之前的配置将会被重置
    [self combineConfigurationSettings];
    [self combineSessionSettings];
    
    [_settingsTableView reloadData];
    
    PLMediaStreamingSession *mediaSession;
    PLStreamingSession *streamSession;
    
    switch (index) {
        case PLStreamTypeAll:
            mediaSession = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:[PLVideoCaptureConfiguration defaultConfiguration] audioCaptureConfiguration:[PLAudioCaptureConfiguration defaultConfiguration] videoStreamingConfiguration:[PLVideoStreamingConfiguration defaultConfiguration] audioStreamingConfiguration:[PLAudioStreamingConfiguration defaultConfiguration] stream:nil];
            break;
        case PLStreamTypeAudioOnly:
            mediaSession = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:nil audioCaptureConfiguration:[PLAudioCaptureConfiguration defaultConfiguration] videoStreamingConfiguration:nil audioStreamingConfiguration:[PLAudioStreamingConfiguration defaultConfiguration] stream:nil];
            break;
        case PLStreamTypeImport:
            streamSession = [[PLStreamingSession alloc] initWithVideoStreamingConfiguration:[PLVideoStreamingConfiguration defaultConfiguration] audioStreamingConfiguration:[PLAudioStreamingConfiguration defaultConfiguration] stream:nil];
            break;
        case PLStreamTypeScreen:
            streamSession = [[PLStreamingSession alloc] initWithVideoStreamingConfiguration:[PLVideoStreamingConfiguration defaultConfiguration] audioStreamingConfiguration:[PLAudioStreamingConfiguration defaultConfiguration] stream:nil];
            break;

        default:
            break;
    }
    if (mediaSession) {
        _mediaSession = mediaSession;
        _streamSession = nil;
    } else{
        _streamSession = streamSession;
        _mediaSession = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingsView:didChangedSession:streamSession:)]) {
        [self.delegate settingsView:self didChangedSession:_mediaSession streamSession:_streamSession ];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_setSegmentControl.selectedSegmentIndex == 0) {
        return _configurationArray.count;
    } else{
        return _sessionArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_setSegmentControl.selectedSegmentIndex == 0) {
        PLCategoryModel *categoryModel = _configurationArray[section];
        NSArray *array = categoryModel.categoryValue;
        return array.count;
    } else{
        PLCategoryModel *categoryModel = _sessionArray[section];
        NSArray *array = categoryModel.categoryValue;
        return array.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // confifuration
    if (_setSegmentControl.selectedSegmentIndex == 0) {
        PLCategoryModel *categoryModel = _configurationArray[indexPath.section];
        NSArray *array = categoryModel.categoryValue;
        PLConfigureModel *configureModel = array[indexPath.row];
        NSArray *rowArray = configureModel.configuraValue;
        if ((rowArray.count <= 7 && [rowArray[0] length] < 6) || (rowArray.count <= 3 && [rowArray[1] length] < 10)) {
            PLSegmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:segmentIdentifier forIndexPath:indexPath];
            [cell confugureSegmentCellWithConfigureModel:configureModel];
            cell.segmentControl.tag = 1000 * indexPath.section + indexPath.row;
            [cell.segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else{
            PLListArrTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier forIndexPath:indexPath];
            [cell confugureListArrayCellWithConfigureModel:configureModel];
            cell.listButton.tag = 1000 * indexPath.section + indexPath.row;
            [cell.listButton addTarget:self action:@selector(listButtonAction:) forControlEvents:UIControlEventTouchDown];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    // session
    } else{
        PLCategoryModel *categoryModel = _sessionArray[indexPath.section];
        NSArray *array = categoryModel.categoryValue;
        PLConfigureModel *configureModel = array[indexPath.row];
        NSArray *rowArray = configureModel.configuraValue;
        
        if ((rowArray.count <= 7 && [rowArray[0] length] < 6) || (rowArray.count <= 3 && [rowArray[1] length] < 14)) {
            PLSegmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:segmentIdentifier forIndexPath:indexPath];
            [cell confugureSegmentCellWithConfigureModel:configureModel];
            cell.segmentControl.tag = 2000 * indexPath.section + indexPath.row;
            [cell.segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else{
            PLListArrTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier forIndexPath:indexPath];
            [cell confugureListArrayCellWithConfigureModel:configureModel];
            cell.listButton.tag = 2000 * indexPath.section + indexPath.row;
            [cell.listButton addTarget:self action:@selector(listButtonAction:) forControlEvents:UIControlEventTouchDown];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLCategoryModel *categoryModel;
    NSInteger count = 0;
    if (_setSegmentControl.selectedSegmentIndex == 0) {
        categoryModel = _configurationArray[indexPath.section];
        count = 10;
    } else{
        categoryModel = _sessionArray[indexPath.section];
        count = 14;
    }
    NSArray *array = categoryModel.categoryValue;
    PLConfigureModel *configureModel = array[indexPath.row];
    NSArray *rowArray = configureModel.configuraValue;
    if ((rowArray.count <= 7 && [rowArray[0] length] < 6) || (rowArray.count <= 3 && [rowArray[1] length] < count)) {
        return [PLSegmentTableViewCell configureSegmentCellHeightWithString:configureModel.configuraKey];
    } else{
        return [PLListArrTableViewCell configureListArrayCellHeightWithString:configureModel.configuraKey];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, PLTABLE_VIEW_WIDTH, 26)];
    headerView.backgroundColor = [UIColor whiteColor];
    PLCategoryModel *categoryModel;
    if (_setSegmentControl.selectedSegmentIndex == 0) {
        categoryModel = _configurationArray[section];
    } else {
        categoryModel = _sessionArray[section];
    }
    UILabel *headLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, PLTABLE_VIEW_WIDTH, 26)];
    headLab.font = FONT_MEDIUM(13);
    headLab.textAlignment = NSTextAlignmentLeft;
    headLab.text = [NSString stringWithFormat:@">> %@", categoryModel.categoryKey];
    [headerView addSubview:headLab];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 26.f;
}

#pragma mark - configuration segment action
- (void)segmentAction:(UISegmentedControl *)segment {
    NSInteger basicCount = 1000;
    NSMutableArray *currentArray = _configurationArray;
    if (_setSegmentControl.selectedSegmentIndex == 1) {
        basicCount = 2000;
        currentArray = _sessionArray;
    }
    NSInteger section = segment.tag / basicCount;
    NSInteger row = segment.tag % basicCount;
    
    PLCategoryModel *categoryModel = currentArray[section];
    NSArray *array = categoryModel.categoryValue;
    PLConfigureModel *configureModel = array[row];
    [self controlPropertiesWithIndex:segment.selectedSegmentIndex configureModel:configureModel categoryModel:categoryModel];
}

#pragma mark - configuration listButton action
- (void)listButtonAction:(UIButton *)listButton {
    NSInteger basicCount = 1000;
    NSMutableArray *currentArray = _configurationArray;
    if (_setSegmentControl.selectedSegmentIndex == 1) {
        basicCount = 2000;
        currentArray = _sessionArray;
    }
    NSInteger section = listButton.tag / basicCount;
    NSInteger row = listButton.tag % basicCount;

    PLCategoryModel *categoryModel = currentArray[section];
    NSArray *array = categoryModel.categoryValue;
    PLConfigureModel *configureModel = array[row];
    NSArray *rowArray = configureModel.configuraValue;
    
    PLListArrayView *listView = [[PLListArrayView alloc]initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT) listArray:rowArray superView:_listSuperView];
    listView.delegate = self;
    listView.configureModel = configureModel;
    listView.categoryModel = categoryModel;
    NSInteger index = [configureModel.selectedNum integerValue];
    listView.listStr = rowArray[index];
}

#pragma mark - PLListArrayViewDelegate -
- (void)listArrayViewSelectedWithIndex:(NSInteger)index configureModel:(PLConfigureModel *)configureModel categoryModel:(PLCategoryModel *)categoryModel {
    [self controlPropertiesWithIndex:index configureModel:configureModel categoryModel:categoryModel];
}

- (void)controlPropertiesWithIndex:(NSInteger)index configureModel:(PLConfigureModel *)configureModel categoryModel:(PLCategoryModel *)categoryModel {
    configureModel.selectedNum = [NSNumber numberWithInteger:index];
    [_settingsTableView reloadData];
    [self configureStreamWithConfigureModel:configureModel categoryModel:categoryModel];
}

#pragma mark - 根据选择的设置 配置 mediaSession 或 streamSession
- (void)configureStreamWithConfigureModel:(PLConfigureModel *)configureModel categoryModel:(PLCategoryModel *)categoryModel {
    NSInteger index = [configureModel.selectedNum integerValue];
    
    if (_setSegmentControl.selectedSegmentIndex == 0) {
        // PLVideoCaptureConfiguration
        if ([categoryModel.categoryKey isEqualToString:@"PLVideoCaptureConfiguration"]) {
            if ([configureModel.configuraKey containsString:@"videoFrameRate"]) {
                _mediaSession.videoFrameRate = [configureModel.configuraValue[index] integerValue];
            } else if ([configureModel.configuraKey containsString:@"sessionPreset"]){
                if ([IOS_SYSTEM_STRING compare:@"9.0.0"] >= 0){
                    switch (index) {
                        case 0:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset352x288;
                            break;
                        case 1:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset640x480;
                            break;
                        case 2:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset1280x720;
                            break;
                        case 3:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset1920x1080;
                            break;
                        case 4:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset3840x2160;
                            break;
                        default:
                            break;
                    }
                } else {
                    switch (index) {
                        case 0:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset352x288;
                            break;
                        case 1:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset640x480;
                            break;
                        case 2:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset1280x720;
                            break;
                        case 3:
                            _mediaSession.sessionPreset = AVCaptureSessionPreset1920x1080;
                            break;
                            break;
                        default:
                            break;
                    }
                }
            } else if ([configureModel.configuraKey containsString:@"previewMirrorFrontFacing"]){
                _mediaSession.previewMirrorFrontFacing = index;

            } else if ([configureModel.configuraKey containsString:@"previewMirrorRearFacing"]){
                _mediaSession.previewMirrorRearFacing = index;

            } else if ([configureModel.configuraKey containsString:@"streamMirrorFrontFacing"]){
                _mediaSession.streamMirrorFrontFacing = index;

            } else if ([configureModel.configuraKey containsString:@"streamMirrorRearFacing"]){
                _mediaSession.streamMirrorRearFacing = index;

            } else if ([configureModel.configuraKey containsString:@"cameraPositon"]){
                _mediaSession.captureDevicePosition = index;

            } else if ([configureModel.configuraKey containsString:@"videoOrientation"]){
                _mediaSession.videoOrientation = index + 1;
            }
            
        // PLVideoStreamingConfiguration
        } else if ([categoryModel.categoryKey isEqualToString:@"PLVideoStreamingConfiguration"]) {
            PLVideoStreamingConfiguration *videoStreamConfiguration = _mediaSession.videoStreamingConfiguration;
            if ([configureModel.configuraKey containsString:@"videoProfileLevel"]) {
                switch (index) {
                    case 0:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264Baseline30;
                        break;
                    case 1:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264Baseline31;
                        break;
                    case 2:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264Baseline41;
                        break;
                    case 3:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264BaselineAutoLevel;
                        break;
                    case 4:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264Main30;
                        break;
                    case 5:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264Main31;
                        break;
                    case 6:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264Main32;
                        break;
                    case 7:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264Main41;
                        break;
                    case 8:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264MainAutoLevel;
                        break;
                    case 9:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264High40;
                        break;
                    case 10:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264High41;
                        break;
                    case 11:
                        videoStreamConfiguration.videoProfileLevel = AVVideoProfileLevelH264HighAutoLevel;
                        break;
                    default:
                        break;
                }
            } else if ([configureModel.configuraKey containsString:@"videoSize"]){
                switch (index) {
                    case 0:
                        videoStreamConfiguration.videoSize = CGSizeMake(272, 480);
                        break;
                    case 1:
                        videoStreamConfiguration.videoSize = CGSizeMake(368, 640);
                        break;
                    case 2:
                        videoStreamConfiguration.videoSize = CGSizeMake(400, 720);
                        break;
                    case 3:
                        videoStreamConfiguration.videoSize = CGSizeMake(720, 1280);
                        break;
                    default:
                        break;
                }
            } else if ([configureModel.configuraKey containsString:@"expectedSourceVideoFrameRate"]){
                videoStreamConfiguration.expectedSourceVideoFrameRate = [configureModel.configuraValue[index] integerValue];
            } else if ([configureModel.configuraKey containsString:@"videoMaxKeyframeInterval"]){
                videoStreamConfiguration.videoMaxKeyframeInterval = [configureModel.configuraValue[index] integerValue];
            } else if ([configureModel.configuraKey containsString:@"averageVideoBitRate"]){
                videoStreamConfiguration.averageVideoBitRate = [configureModel.configuraValue[index] integerValue];
            } else if ([configureModel.configuraKey containsString:@"videoEncoderType"]){
                videoStreamConfiguration.videoEncoderType = index;
            }
            if (_mediaSession) {
                [_mediaSession reloadVideoStreamingConfiguration:videoStreamConfiguration];
            }
            if (_streamSession) {
                [_streamSession reloadVideoStreamingConfiguration:videoStreamConfiguration];
            }
        
        // PLAudioCaptureConfiguration
        } else if ([categoryModel.categoryKey isEqualToString:@"PLAudioCaptureConfiguration"]) {
            if ([configureModel.configuraKey containsString:@"channelsPerFrame"]) {
                _mediaSession.audioCaptureConfiguration.channelsPerFrame = index + 1;

            } else if ([configureModel.configuraKey containsString:@"acousticEchoCancellationEnable"]){
                _mediaSession.audioCaptureConfiguration.acousticEchoCancellationEnable = index;
            }
            
        // PLAudioStreamingConfiguration
        } else if ([categoryModel.categoryKey isEqualToString:@"PLAudioStreamingConfiguration"]) {
            PLAudioStreamingConfiguration *audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
            if ([configureModel.configuraKey containsString:@"encodedAudioSampleRate"]) {
                audioStreamingConfiguration.encodedAudioSampleRate = index;
                if (_mediaSession) {
                    _mediaSession.audioStreamingConfiguration.encodedAudioSampleRate = index;
                }
            } else if ([configureModel.configuraKey containsString:@"audioBitRate"]){
                switch (index) {
                    case 0:
                        audioStreamingConfiguration.audioBitRate = PLStreamingAudioBitRate_64Kbps;
                        if (_mediaSession) {
                            _mediaSession.audioStreamingConfiguration.audioBitRate = PLStreamingAudioBitRate_64Kbps;
                        }

                        break;
                    case 1:
                        audioStreamingConfiguration.audioBitRate = PLStreamingAudioBitRate_96Kbps;
                        if (_mediaSession) {
                            _mediaSession.audioStreamingConfiguration.audioBitRate = PLStreamingAudioBitRate_96Kbps;
                        }

                        break;
                    case 2:
                        audioStreamingConfiguration.audioBitRate = PLStreamingAudioBitRate_128Kbps;
                        if (_mediaSession) {
                            _mediaSession.audioStreamingConfiguration.audioBitRate = PLStreamingAudioBitRate_128Kbps;
                        }

                        break;
                    default:
                        break;
                }
            } else if ([configureModel.configuraKey containsString:@"encodedNumberOfChannels"]){
                audioStreamingConfiguration.encodedNumberOfChannels = (UInt32) index + 1;
                if (_mediaSession) {
                    _mediaSession.audioStreamingConfiguration.encodedNumberOfChannels = (UInt32) index + 1;
                }
            } else if ([configureModel.configuraKey containsString:@"audioEncoderType"]){
                audioStreamingConfiguration.audioEncoderType = index;
                if (_mediaSession) {
                    _mediaSession.audioStreamingConfiguration.audioEncoderType = index;
                }
            }
            if (_streamSession) {
                [_streamSession reloadAudioStreamingConfiguration:audioStreamingConfiguration];
            }

        }
    } else {
        // PLMediaStreamingKit
        if ([categoryModel.categoryKey isEqualToString:@"PLMediaStreamingKit"]) {
            if ([configureModel.configuraKey containsString:@"fillMode"]){
                _mediaSession.fillMode = index;
            }
        
        // PLStreamingKit
        } else if ([categoryModel.categoryKey isEqualToString:@"PLStreamingKit"]) {
            if ([configureModel.configuraKey containsString:@"quicEnable"]){
                if (_mediaSession) {
                    _mediaSession.quicEnable = index;
                } else{
                    _streamSession.quicEnable = index;
                }

            } else if ([configureModel.configuraKey containsString:@"dynamicFrameEnable"]){
                if (_mediaSession) {
                    _mediaSession.dynamicFrameEnable = index;
                } else{
                    _streamSession.dynamicFrameEnable = index;
                }

            } else if ([configureModel.configuraKey containsString:@"adaptiveBitrate"]){
                if (_mediaSession) {
                    if (index == 0) {
                        [_mediaSession disableAdaptiveBitrateControl];
                    } else{
                        switch (index) {
                            case 1:
                                [_mediaSession enableAdaptiveBitrateControlWithMinVideoBitRate:150*1000];
                                break;
                            case 2:
                                [_mediaSession enableAdaptiveBitrateControlWithMinVideoBitRate:200*1000];
                                break;
                            case 3:
                                [_mediaSession enableAdaptiveBitrateControlWithMinVideoBitRate:400*1000];
                                break;
                            case 4:
                                [_mediaSession enableAdaptiveBitrateControlWithMinVideoBitRate:600*1000];
                                break;
                            case 5:
                                [_mediaSession enableAdaptiveBitrateControlWithMinVideoBitRate:800*1000];
                                break;
                            case 6:
                                [_mediaSession enableAdaptiveBitrateControlWithMinVideoBitRate:1000*1000];
                                break;
                            default:
                                break;
                        }
                    }
                } else{
                    if (index == 0) {
                        [_streamSession disableAdaptiveBitrateControl];
                    } else{
                        switch (index) {
                            case 1:
                                [_streamSession enableAdaptiveBitrateControlWithMinVideoBitRate:150*1000];
                                break;
                            case 2:
                                [_streamSession enableAdaptiveBitrateControlWithMinVideoBitRate:200*1000];
                                break;
                            case 3:
                                [_streamSession enableAdaptiveBitrateControlWithMinVideoBitRate:400*1000];
                                break;
                            case 4:
                                [_streamSession enableAdaptiveBitrateControlWithMinVideoBitRate:600*1000];
                                break;
                            case 5:
                                [_streamSession enableAdaptiveBitrateControlWithMinVideoBitRate:800*1000];
                                break;
                            case 6:
                                [_streamSession enableAdaptiveBitrateControlWithMinVideoBitRate:1000*1000];
                                break;
                            default:
                                break;
                        }
                    }
                }
            } else if ([configureModel.configuraKey containsString:@"autoReconnectEnable"]){
                if (_mediaSession) {
                    _mediaSession.autoReconnectEnable = index;
                } else{
                    _streamSession.autoReconnectEnable = index;
                }

            } else if ([configureModel.configuraKey containsString:@"monitorNetworkStateEnable"]){
                if (_mediaSession) {
                    _mediaSession.monitorNetworkStateEnable = index;
                } else{
                    _streamSession.monitorNetworkStateEnable = index;
                }

            } else if ([configureModel.configuraKey containsString:@"statusUpdateInterval"]) {
                if (_mediaSession) {
                    _mediaSession.statusUpdateInterval = [configureModel.configuraValue[index] integerValue];
                } else{
                    _streamSession.statusUpdateInterval = [configureModel.configuraValue[index] integerValue];
                }
                
            } else if ([configureModel.configuraKey containsString:@"threshold"]){
                if (_mediaSession) {
                    _mediaSession.threshold = [configureModel.configuraValue[index] floatValue];
                } else{
                    _streamSession.threshold = [configureModel.configuraValue[index] floatValue];
                }
                
            } else if ([configureModel.configuraKey containsString:@"maxCount"]){
                if (_mediaSession) {
                    _mediaSession.maxCount = [configureModel.configuraValue[index] integerValue];
                } else{
                    _streamSession.maxCount =[configureModel.configuraValue[index] integerValue];
                }
                
            }
        
        // CameraSource
        } else if ([categoryModel.categoryKey isEqualToString:@"CameraSource"]) {
            if ([configureModel.configuraKey containsString:@"continuousAutofocusEnable"]) {
                _mediaSession.continuousAutofocusEnable = index;

            } else if ([configureModel.configuraKey containsString:@"touchToFocusEnable"]){
                _mediaSession.touchToFocusEnable = index;
                
            } else if ([configureModel.configuraKey containsString:@"smoothAutoFocusEnabled"]){
                _mediaSession.smoothAutoFocusEnabled = index;

            } else if ([configureModel.configuraKey containsString:@"torchOn"]){
                _mediaSession.torchOn = index;
            }
        
        // MicrophoneSource
        } else if ([categoryModel.categoryKey isEqualToString:@"MicrophoneSource"]) {
            if ([configureModel.configuraKey containsString:@"playback"]) {
                _mediaSession.playback = index;

            } else if ([configureModel.configuraKey containsString:@"inputGain"]){
                _mediaSession.inputGain = [configureModel.configuraValue[index] floatValue];
                
            } else if ([configureModel.configuraKey containsString:@"allowAudioMixWithOthers"]){
                _mediaSession.allowAudioMixWithOthers = index;

            }
            
        // Applictaion
        } else if ([categoryModel.categoryKey isEqualToString:@"Applictaion"]) {
            if ([configureModel.configuraKey containsString:@"idleTimerDisable"]) {
                if (_mediaSession) {
                    _mediaSession.idleTimerDisable = index;
                } else{
                    _streamSession.idleTimerDisable = index;
                }
            }
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingsView:didChangedSession:streamSession:)]) {
        [self.delegate settingsView:self didChangedSession:_mediaSession streamSession:_streamSession ];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
