<template>
  <div class="login-form">
    <h2>请输入老师的登录信息</h2>
    <div class="input-box">
      <input class="input-text"
             type="text"
             id="number"
             v-model="numberStr"
             placeholder="请输入您的账号">
      <input class="input-text"
             type="text"
             id="secret"
             v-model="secretStr"
             placeholder="请输入您的密码">
      <mt-button class="login-btn"
                 type="primary"
                 :disabled="banClick"
                 @click.native="loginFor">登录</mt-button>
    </div>
    <h4 @dblclick="clearCache">老师的账号密码需要向后台管理人员索取</h4>
  </div>
</template>

<script>
import { Indicator, Toast } from 'mint-ui';
import NativeJSMixin from '../utils/nativeJs.js';

export default {
  name: 'LoginForm',
  mixins: [NativeJSMixin],
  data() {
    return {
      banClick: true,
      numberStr: '',
      secretStr: '',
    };
  },
  watch: {
    numberStr(value, oldValue) {
      // console.log(value, oldValue);
      if (value.length >= 5) {
        var secret = document.getElementById('secret');
        if (secret.value.length >= 6) {
          this.banClick = false;
        }
      } else {
        this.banClick = true;
      }
    },
    secretStr(value, oldValue) {
      // console.log(value, oldValue);
      if (value.length >= 6) {
        var number = document.getElementById('number');
        if (number.value.length >= 5) {
          this.banClick = false;
        }
      } else {
        this.banClick = true;
      }
    },
  },
  methods: {
    loginFor() {
      this.banClick = true;
      Indicator.open({
        text: '努力加载中',
        spinnerType: 'snake',
      });
      this.$store
        .dispatch('Login', {
          nickname: this.numberStr,
          password: this.secretStr,
        })
        .then((res) => {
          Toast({
            message: '登录成功',
            position: 'bottom',
            duration: 2000,
          });
          this.loginFinish(true);
        })
        .catch((rej) => {
          Toast({
            message: '登录失败，请检查自己的账号密码',
            position: 'bottom',
            duration: 2000,
          });
          this.loginFinish(false);
        });
    },
    loginFinish(boolvalue) {
      if (boolvalue) {
        this.$store
          .dispatch('GetTeacherInfo')
          .then((res) => {})
          .catch((rej) => {});
      }
      Indicator.close();
      this.numberStr = '';
      this.secretStr = '';
    },
    clearCache() {
      this.js2native(JSON.stringify({type: 'clearCache'}));
    }
  },
};
</script>

<style lang="css" scoped>
.login-form {
  background: rgba(200, 200, 200, 0.5);
  border-radius: 6px;
  width: 90%;
  height: 50%;
  margin: 25% auto;
  position: relative;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
  padding: 0;
}
.login-form h2,
h4 {
  color: rgba(2, 2, 2, 0.7);
  margin: 15px auto;
}
.input-box {
  width: 80%;
}
.input-text {
  width: calc(100% - 15px);
  height: 50px;
  border-width: 0;
  padding-left: 15px;
  outline: none;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.7);
  margin: 5px 0;
}
.login-btn {
  width: 100%;
  display: block;
  margin: 5px 0;
}
</style>
