<template>
  <div id="chat-room">
    <div class="fixed-div">
      <mt-header :title=title
                 class="header">
        <router-link to
                     slot="left">
          <mt-button icon="back">
                     <!-- @click.native="$router.go(-1)"> -->
          </mt-button>
        </router-link>
        <mt-button v-show="canFinish"
                   class="nav-right-btn"
                   slot="right"
                   @click="finished">
          结束直播
        </mt-button>
      </mt-header>
    </div>
    <div class="content">
      <Live-chat v-bind:course_info="course_info"></Live-chat>
    </div>
  </div>
</template>

<script>
import LiveChat from '../components/LiveChat';
import noti from '../common/notification';
import { MessageBox, Toast } from 'mint-ui';
import {
  getTheChatRoomToken,
  getLiveRoomChatToken,
  closeTheLiveRoom,
} from '@/api/courseApi.js';

export default {
  name: 'ChatRoom',
  data() {
    return {
      title: '文字直播课',
      course_info: {},
      canFinish: false,
    };
  },
  components: {
    LiveChat,
  },
  created() {
    var courseData = this.$route.query;
    this.title = courseData.course_head;
    this.course_info = courseData;
    this.canFinish = courseData.type_id == 2 ? true : false;
  },
  mounted() {
  },
  methods: {
    finished() {
      MessageBox.confirm(
        '结束直播之后不可再次进入本节直播课',
        '确定要结束直播吗？'
      )
        .then((res) => {
          console.log(this.course_info.id, 'finished');
          closeTheLiveRoom({ id: this.course_info.id })
            .then((res) => {
              Toast('课堂结束成功');
              this.$router.go(-1);
            })
            .catch((rej) => {
              Toast('课堂结束失败,请联系后台人员');
              this.$router.go(-1);
            });
        })
        .catch((rej) => {
          console.log(rej);
        });
    },
    haveLogin() {
      let access_token = localStorage.getItem('access_token');
      if (
        access_token != null &&
        access_token != undefined &&
        access_token.length > 1
      ) {
        return true;
      } else {
        return false;
      }
    },
    backPage() {
      console.log('backPage');
    },
  },
};
</script>

<style scoped>
.nav-right-btn {
  width: 60px;
  height: 40px;
}
.fixed-div {
  position: fixed;
  width: 100%;
}
.header {
  background: white;
  color: #323232;
}
.content {
  position: fixed;
  top: 40px;
  background: white;
  width: 100%;
  overflow-y: hidden;
  /* height: 100%; */
  height: calc(100vh - 40px);
}
</style>
