import axios from "axios";
import _setting from "../common/setting";
import router from "../router/index"
import { Toast } from 'mint-ui'

let access_token = "";
const ax = axios.create({
  baseURL: _setting.API_PATH,
  timeout: 5000
});

ax.interceptors.request.use(
  config => {
    let need = config.needToken;
    console.log(config);
    // debugger;
    if (need !== 'false') {
      if (access_token === "") {
        access_token = localStorage.getItem("access_token");
      }
      if (access_token == null || access_token == '' || access_token == undefined) {
        console.log('缺失token')
      }else{
        if (access_token.length > 4) {
          config.headers = {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'Authorization': 'Bearers ' + access_token
          };
        }
      }
    } else {
      config.headers = {
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
      };
    }
    return config;
  },
  error => {
    console.log('request error',error);
    return Promise.reject(error);
  }
);
ax.interceptors.response.use(
  response => {
    // debugger;
    let status = response.status;
    if (status === 200 || status === 201) {
      console.log("success:", response);
      if (
        response.request.responseURL.indexOf("cms/admin/login") > -1
      ) {
        localStorage.setItem("access_token", response.data.access_token);
        localStorage.setItem(
          "refresh_token",
          response.data.refresh_token
        );
        access_token = response.data.access_token;
      }
      return response.data;
    } else {
      console.log("else:", response);
      if (code === 10000 || code === 10001 || code === 10004 || code === 10005 || code === 10006) {
        localStorage.removeItem("access_token");
        access_token = '';
        Toast('token失效，请重新登录');
        router.push('/Login');
      }
      return Promise.reject(response);
    }
  },
  error => {
    let data = error.response.data;
    let code = data.code;
    if (code === 10000 || code === 10001 || code === 10004 || code === 10005 || code === 10006) {
      localStorage.removeItem("access_token");
      access_token = '';
      Toast('token失效，请重新登录');
      router.push('/Login');
    }
    console.log("error:", error.response);
    return Promise.reject(error);
  }
);

export default ax;
