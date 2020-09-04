<template>
  <div class="answer-question">
    <mt-header :title=title
               class="header">
      <mt-button icon="back"
                 slot="left"
                 @click.native="$router.go(-1)">
      </mt-button>
      <router-link to
                   slot="right">
        <mt-button :class="class_confirm"
                   @click.native="comfirmClick">回答</mt-button>
      </router-link>
    </mt-header>
    <div class="answer-box">
      <textarea name="input"
                @input="checkValueLength"
                id="answer-textarea"
                maxlength="300"
                placeholder="请详细描述你想咨询的问题…"></textarea>
      <span>{{ textLength }}</span>
    </div>
  </div>
</template>
<script>
import { teacherQuestionanswer } from '@/api/courseApi.js';
import { Toast } from 'mint-ui';

export default {
  name: 'AnswerQuestion',
  data() {
    return {
      title: '',
      question: {},
      textLength: '0/300',
      class_confirm: 'confirm-btn1',
    };
  },
  activated() {
    this.question = this.$route.query;
    this.title = '向' + this.question.user.user_nickname + '回答';
    if (!this.question || this.title.length <= 0) {
      this.$router.push();
    }
  },
  created() {},
  methods: {
    comfirmClick() {
      var text = document.getElementById('answer-textarea');
      console.log(text, text.value);
      if (text.value.length > 0) {
        teacherQuestionanswer({
          id: this.question.id,
          question_answer: text.value,
        })
          .then((res) => {
            this.$router.go(-1);
            Toast('已提交回答');
          })
          .catch((rej) => {});
      } else {
        Toast('请输入文字后点击提交');
      }
    },
    checkValueLength(val) {
      var text = document.getElementById('answer-textarea');
      this.textLength = text.value.length + '/300';
      if (text.value.length > 0) {
        this.class_confirm = 'confirm-btn2';
      } else {
        this.class_confirm = 'confirm-btn1';
      }
    },
  },
};
</script>
<style lang="css" scoped>
.answer-question {
  background: #f5f5f5;
  width: 100%;
  height: 100%;
}
.confirm-btn1 {
  color: #ffc4c5;
}
.confirm-btn2 {
  color: #e3191a;
}
#answer-textarea {
  width: calc(100% - 32px);
  height: 180px;
  font-size: 15px;
  border: none;
  padding: 5px 16px;
  outline: none;
}
.answer-box span {
  position: absolute;
  top: 200px;
  right: 16px;
}
</style>