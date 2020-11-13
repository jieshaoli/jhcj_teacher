<template>
  <div id="videoPlay">
    <mt-header :title=title
               class="header">
      <mt-button icon="back"
                 slot="left"
                 @click.native="$router.go(-1)">
      </mt-button>
    </mt-header>
    <div class="content"
         id="videoContent">
      <div id="mse"></div>
      <div class="comment">
        <div class="comment-nav">评论</div>
        <div class="comment-list"></div>
        <div class="comment-action">
          <textarea id="editor"
                    type="text"
                    v-model="input_text"
                    placeholder="请输入内容。。。"
                    @focus="inputIn"
                    @blur="inputOut"></textarea>
          <button id="smile"
                  style="width:25px;"
                  @click="showEmoji">
            <img id="smileImg"
                 style="width:25px;"
                 src="../assets/images/smile.png"
                 alt="" />
          </button>
          <mt-button class="send-btn"
                     type="primary"
                     @click.native="sendMsg">发送</mt-button>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: 'videoPlay',
  data() {
    return {
      player: null,
      info: {},
      input_text: '',
      title: '',
    };
  },
  created() {
    this.info = this.$route.query;
    this.title = this.info.course_head;
    this.initPlayer();
  },
  beforeDestroy() {
    this.player.destroy(true);
  },
  methods: {
    initPlayer() {
      this.player = new Player({
        id: 'mse',
        url: this.info.course_resource_url,
        width: window.innerWidth,
        height: 'auto',
        volume: 0.6,
        autoplay: true,
        poster: this.info.course_picture,
      });
    },
    inputIn() {},
    inputOut() {},
    showEmoji() {},
    sendMsg() {},
  },
};
</script>
<style scoped>
#videoPlay {
  overflow: hidden;
}
.content {
  background: red;
  width: 100%;
  display: flex;
  flex-direction: column;
}
.comment {
  width: 100%;
  height: 100%;
}
.comment .comment-nav {
  height: 49px;
  width: 100%;
  background: white;
  font-size: 22px;
  line-height: 50px;
  border-bottom: 1px solid #333;
}
.comment .comment-list {
  width: 100%;
  height: 100%;
  background: yellowgreen;
}
.comment .comment-action {
  width: 100%;
  background: white;
  height: 50px;
  position: fixed;
  bottom: 0px;
  display: flex;
  border-top: 1px solid #333;
}
.comment-action #editor {
  border-radius: 6px;
  border: 0.5px solid #edebec;
  background: #fbf9fa;
  height: 32px;
  width: 100%;
  outline: none;
  resize: none;
  display: flex;
  font-size: 15px;
  line-height: 32px;
  margin-top: 8px;
  margin-left: 16px;
  position: relative;
  padding-left: 10px;
}
.comment-action #smile {
  position: relative;
  width: 25px;
  height: 25px;
  margin: 12px 0 12px 5px;
  border-width: 0;
  background: transparent;
}
.comment-action .send-btn {
  position: relative;
  height: 32px;
  width: 70px;
  margin: 9px 16px 9px 16px;
  font-size: 14px;
  white-space: nowrap;
}
</style>
