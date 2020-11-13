import request from './request.js';
import QS from 'qs';

// 登陆
export function login(params) {
  return request({
      url: 'cms/admin/login',
      method: 'post',
      data: QS.stringify(params),
      needToken: 'false'
  });
}

// 查询登录账号关联老师信息
export function getTeacherInfoByTheAccount() {
  return request({
      url: 'v1/series/teacher/message',
      method: 'post'
  });
}