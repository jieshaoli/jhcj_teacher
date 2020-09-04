import request from './request.js';
import QS from 'qs';

// 课程列表
export function getCourseList(params) {
  return request({
      url: 'v1/course/list',
      method: 'get',
      params: params//QS.stringify(params)
  });
}
// 用户提问列表
export function teacherQuestionlist(id,params) {
  return request({
      url: 'v1/teacher/question/list?id='+id,
      method: 'get',
      params: params
  });
}
// 回复用户问题接口
export function teacherQuestionanswer(params) {
  return request({
      url: 'v1/teacher/question/answer',
      method: 'post',
      data: QS.stringify(params)
  });
}
// 聊天室的token
export function getTheChatRoomToken(params) {
    return request({
        url: 'v1/course/room/teacherToken',
        method: 'post',
        data: QS.stringify(params)
    });
}
// 获取直播中聊天室的token
export function getLiveRoomChatToken(params) {
  return request({
      url: 'v1/course/live/room/token',
      method: 'post',
      data: QS.stringify(params)
  });
}
// 关闭直播课程
export function closeTheLiveRoom(params) {
  console.log(QS.stringify(params),'000000');
    return request({
        url: 'v1/course/live/close',
        method: 'post',
        data: QS.stringify(params)
    });
}