<template>
  <div class="question-detail">
    <mt-header :title=title
               class="header">
      <router-link to slot="left">
        <mt-button icon="back"
                   @click.native="$router.go(-1)">
        </mt-button>
      </router-link>
    </mt-header>
    <div class="qa-content">
      <div class="qa-left">
        <img :src="user.user_picture"
             alt="">
      </div>
      <div class="qa-right">
        <div class="qa-user">
          <span class="user-name">{{ user.user_nickname }}</span>
          <span class="user-time">{{ data_info.create_time }}</span>
          <p class="user-content">{{ data_info.question_content }}</p>
        </div>
        <hr v-show="show_teacher">
        <div class="qa-teacher"
             v-show="show_teacher">
          <div class="teacher-header">
            <img :src="teacher.teacher_picture"
                 alt="">
            <div class="teacher-center">
              <span class="teacher-name">{{ teacher.teacher_name }}</span>
              <span class="teacher-time">{{ data_info.question_answer_time }}</span>
            </div>
            <span class="watch">
              <img src="../assets/images/eye.png"
                   alt="">
              {{ data_info.sign_id }}
            </span>
          </div>
          <p class="teacher-content">{{ data_info.question_content }}</p>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: 'QuestionDetail',
  data() {
    return {
      title: '',
      data_info: {},
      user: {},
      teacher: {},
      show_teacher: false,
    };
  },
  activated() {
    this.data_info = this.$route.query;
    this.title = this.data_info.user.user_nickname + '的提问';
    this.user = this.data_info.user;
    this.teacher = this.data_info.teachers;
    this.show_teacher = this.data_info.question_status == 1 ? true : false;
  },
  created() {
  },
  methods: {
  },
};
</script>
<style lang="css" scoped>
.qa-content {
  width: 100%;
  padding: 16px;
  display: flex;
  flex-direction: row;
}
.qa-left {
  width: 50px;
}
.qa-left img {
  width: 44px;
  height: 44px;
  border-radius: 22px;
  border: 0 6px;
}
.qa-right {
  width: calc(100% - 50px - 32px - 5px);
  padding: 0px;
  display: flex;
  flex-direction: column;
  padding-left: 5px;
}
.qa-right hr {
  width: 100%;
  background: #E1E1E1;
  margin: 5px 0;
  height: 1px;
  border: 0;
}
.qa-right .qa-user {
  padding: 2px 5px 1px 0px;
  width: 100%;
}
.qa-user span {
  display: block;
  text-align: left;
  margin-bottom: 3px;
}
.qa-user .user-name {
  color: #323232;
  font-size: 15px;
}
.qa-user .user-time {
  color: #989898;
  font-size: 11px;
}
.qa-user .user-content {
  color: #323232;
  font-size: 15px;
  text-align: left;
  margin: 8px 0;
}
.qa-right .qa-teacher {
  width: 100%;
  margin-top: 5px;
}
.qa-teacher .teacher-header {
  display: flex;
  flex-direction: row;
}
.teacher-header img {
  width: 32px;
  height: 32px;
  border-radius: 16px;
}
.teacher-header .watch {
  position: absolute;
  right: 16px;
}
.teacher-header .teacher-center {
  display: flex;
  flex-direction: column;
  text-align: left;
  margin-left: 5px;
}
.teacher-center span {
  margin-bottom: 2px;
}
.teacher-center .teacher-name {
  color: #656565;
  font-size: 13px;
}
.teacher-center .teacher-time {
  color: #989898;
  font-size: 11px;
}
.teacher-header span {
  font-size: 12px;
  color: #989898;
}
.teacher-header span img {
  width: 13px;
  height: 9px;
}
.qa-teacher .teacher-content {
  text-align: left;
  margin: 8px 0;
}
</style>