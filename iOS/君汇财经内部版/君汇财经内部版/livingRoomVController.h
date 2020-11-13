//
//  livingRoomVController.h
//  君汇财经内部版
//
//  Created by 李少杰 on 2020/11/3.
//  Copyright © 2020 李少杰. All rights reserved.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface livingRoomVController : ViewController

@property (nonatomic, strong) NSDictionary *courseInfo;



// 0 音视频
// 1 纯音频
// 2 外部导入
// 3 录屏
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSURL *pushURL;

// 外部导入数据的源
@property (nonatomic, strong) NSURL *mediaURL;

@end

NS_ASSUME_NONNULL_END
