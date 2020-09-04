<template>
  <div class="question-list">
    <div class="content">
      <mt-loadmore :topMethod="loadTop"
                   :bottomMethod="loadBottom"
                   @top-status-change="watchTopStatus"
                   @bottom-status-change="watchBottomStatus"
                   :bottomAllLoaded="allLoaded"
                   ref="loadmore"
                   :autoFill="false"
                   :topDistance="50"
                   :bottomDistance="80"
                   :bottomPullText="pullText">
        <ul>
          <li v-for="(item, index) in questionList"
              :key="index">
            <div class="cell"
                 @click="pushToNextPage(index)">
              <div class="cell-left">
                <img :src="item.user.user_picture"
                     alt="">
              </div>
              <div class="cell-center">
                <span class="con-title">{{ item.user.user_nickname }}</span>
                <span class="con-intro">{{ item.question_content }}</span>
                <div class="con-bottom">
                  <span class="con-time">{{ item.create_time }}</span>
                  <span class="con-status1"
                        v-if="item.question_status == 1">已回复</span>
                  <span class="con-status2"
                        v-else>未回复</span>
                </div>
              </div>
              <div class="cell-right"
                   @click.stop="answerClick(index)">
                <span class="watched"
                      v-if="item.is_look_over == 1 && item.question_status == 1">已查看</span>
                <span class="no-watch"
                      v-else-if="item.is_look_over == 0 && item.question_status == 1">未查看</span>
                <button class="answer-btn"
                        v-else-if="item.question_status == -1">回答</button>
              </div>
            </div>
          </li>
        </ul>
      </mt-loadmore>
    </div>
  </div>
</template>

<script>
import { teacherQuestionlist } from '@/api/courseApi.js';
import noti from '../common/notification.js';

export default {
  name: 'QuestionList',
  data() {
    return {
      title: '问答列表',
      questionList: [],
      currentPage: 1,
      maxPages: 1,
      allLoaded: false,
      pullText: '上拉加载更多',
    };
  },
  activated() {
    noti.$emit('title', this.title);
    if (this.questionList.length <= 0) {
      var user_id = this.$store.state.user.user_id;
      if (user_id && user_id.length > 0) {
        
      }else{
        let user = JSON.parse(localStorage.getItem('user'));
        if (user) {
          this.$store.commit('SET_USER', user);
        }
      }
      this.networkForQuestionList();
    }
  },
  watch: {
    $route(to, from) {
      if (to.name == 'Login') {
        this.questionList = [];
      }
    }
  },
  deactivated() {},
  methods: {
    networkForQuestionList() {
      teacherQuestionlist(this.$store.state.user.user_id, {
        page: this.currentPage,
      })
        .then((res) => {
          let dataArr = res.result;
          dataArr.forEach((qa) => {
            this.questionList.push(qa);
          })
          if (this.currentPage === 1) {
            this.$refs.loadmore.onTopLoaded();
          } else {
            this.$refs.loadmore.onBottomLoaded();
          }
        })
        .catch((rej) => {
          if (this.currentPage === 1) {
            this.$refs.loadmore.onTopLoaded();
          } else {
            this.$refs.loadmore.onBottomLoaded();
          }
        });
    },
    pushToNextPage(index) {
      noti.$emit('route', {path: '/QuestionDetail', info: this.questionList[index]});
    },
    answerClick(index) {
      var question = this.questionList[index];
      noti.$emit('route', {path: '/AnswerQuestion', info: question});
    },
    loadTop() {
      this.currentPage = 1;
      this.networkForQuestionList();
    },
    loadBottom() {
      this.currentPage++;
      if (this.currentPage >= this.maxPages) {
        this.pullText = '全部加载完成';
        this.allLoaded = true;
      }
      this.networkForQuestionList();
    },
    watchTopStatus(status) {
      console.log(status);
    },
    watchBottomStatus(status) {
      console.log(status);
    },
  },
};
</script>
<style lang="css" scoped>
.content {
  background: white;
  height: calc(100vh - 96px);
  overflow-x: auto;
  overflow-y: scroll;
  -webkit-overflow-scrolling: touch;
}
ul,
li {
  padding: 0;
  margin: 0;
  list-style: none;
}
.cell {
  margin-top: 8px;
  width: 100%;
  height: 82px;
  display: flex;
  justify-content: flex-start;
  box-shadow: 0 3px 5px 4px #eee;
  /* 0 -3px -5px -4px #eee; */
}
.cell .cell-left {
  /* width: calc(60px + 16px + 16px);
  height: 82px; */
  display: inline-block;
  padding: 11px 16px;
}
.cell-left img {
  border-radius: 30px;
  width: 60px;
  height: 60px;
}
.cell-center {
  width: calc(100% - 92px - 26px - 41px);
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  overflow: hidden;
  padding-top: 11px;
}
.cell-center span {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  text-align: left;
  width: 100%;
}
.cell-center .con-title {
  color: #323232;
  font-size: 16px;
}
.cell-center .con-intro {
  color: #656565;
  font-size: 13px;
}
.con-bottom .con-time {
  color: #989898;
  font-size: 12px;
}
.con-bottom .con-status1 {
  background: #fb4546;
  color: white;
  font-size: 10px;
  border-radius: 3px;
  padding: 2px 3px;
  margin-left: 15px;
}
.con-bottom .con-status2 {
  background: #eeeeee;
  color: #989898;
  font-size: 10px;
  border-radius: 3px;
  padding: 2px 3px;
  margin-left: 15px;
}
.cell-right {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: calc(41px + 26px);
}
.cell-right span {
  font-size: 10px;
  margin-top: 11px;
}
.cell-right .watched {
  color: #fb4546;
}
.cell-right .no-watch {
  color: #989898;
}
.cell-right button {
  margin: auto;
  background: white;
  color: #fb4546;
  border: 1px solid #fb4546;
  border-radius: 3px;
}
</style>