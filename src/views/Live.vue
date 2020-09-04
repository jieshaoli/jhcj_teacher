<template>
  <div class="live">
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
        <li v-for="(item, index) in courseList"
            :key="index"
            @click="pushToNextPage(index)">
          <div class="cell">
            <div class="cell-left">
              <img class="cell-img"
                   :src="item.course_picture">
            </div>
            <div class="cell-right">
              <div>
                <span class="con-title">{{ item.course_head }}</span>
                <span class="con-label"
                      v-show="item.course_type.length > 1 ? 'true': 'false'">{{ item.course_type }}</span>
              </div>
              <span class="con-intro">{{ item.course_desc }}</span>
              <Teacher-label :info="item.teacher"></Teacher-label>

            </div>
          </div>
        </li>
      </ul>
    </mt-loadmore>
  </div>
</template>

<script>
import noti from '../common/notification.js';
import { getCourseList } from '../api/courseApi.js';
import TeacherLabel from '../components/TeacherLabel';
import { Toast } from 'mint-ui';
export default {
  name: 'Live',
  data() {
    return {
      title: '直播',
      courseList: [],
      currentPage: 1,
      maxPages: 1,
      allLoaded: false,
      pullText: '上拉加载更多',
    };
  },
  components: {
    TeacherLabel,
  },
  activated() {
    noti.$emit('title', this.title);
    if (this.courseList.length <= 0) {
      this.networkForCourseList({ page: 1 });
    }
  },
  watch: {
    $route(to, from) {
      if (to.name == 'Login') {
        this.courseList = [];
      }
    }
  },
  deactivated() {},
  created() {},
  methods: {
    networkForCourseList(param) {
      getCourseList(param)
        .then((res) => {
          this.maxPages = Math.ceil(res.total_nums / 20);
          var arr = res.collection;
          if (this.currentPage === 1) {
            this.courseList = [];
          }
          arr.forEach((element) => {
            switch (element.type_id) {
              case 1:
                element.course_type = '聊天室';
                break;
              case 2:
                element.course_type = '直播室';
                break;
              case 3:
                element.course_type = '视频课';
                break;
              default:
                element.course_type = '';
                break;
            }
            this.courseList.push(element);
          });

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
      var course_info = this.courseList[index];
      var type = course_info.type_id;
      var status = course_info.course_status;
      var idStr = course_info.id;
      if (type === 1 || type === 2) {
        if (idStr && idStr !== undefined && idStr !== null) {
          if (status === 3) {
            Toast('课程已结束');
          } else if (status === -1) {
            Toast('视频课暂不支持观看');
          } else {
            //1直播未开始 2直播中 4暂停直播(聊天室没有此)
            noti.$emit('route', {path: '/ChatRoom', info: course_info});
          }
        } else {
          Toast('课程信息不全,请咨询后台人员');
        }
      } else {
        Toast('暂不支持视频课');
      }
    },
    loadTop() {
      console.log('加载更多数据');
      this.currentPage = 1;
      this.networkForCourseList({ page: this.currentPage });
    },
    loadBottom() {
      console.log('新数据加载完毕');
      this.currentPage++;
      if (this.currentPage >= this.maxPages) {
        this.pullText = '全部加载完成';
        this.allLoaded = true;
      }
      this.networkForCourseList({ page: this.currentPage });
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
.live {
  background: #f5f5f5;
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
  width: 100%;
  height: 90px;
  display: flex;
  justify-content: flex-start;
  border-bottom: 2px solid #eee;
  background: #ffffff;
}
.cell-left {
  display: inline-block;
}
.cell .cell-img {
  width: 64px;
  height: 64px;
  margin: 13px;
  border-radius: 6px;
}
.cell .cell-right {
  height: 90px;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: flex-start;
  width: calc(100vw - 90px - 16px);
  margin: 13px 16px 13px 0px;
  overflow: hidden;
}
.cell .cell-right span {
  /* display: inline-block; */
  line-height: 20px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
  text-align: left;
}
.cell-right .con-title {
  font-size: 16px;
  color: #323232;
  display: inline;
}
.cell-right .con-intro {
  font-size: 13px;
  color: #656565;
  display: inline-block;
}
.cell-right .con-label {
  background: #ffecec;
  color: #e3191a;
  font-size: 10px;
  border-radius: 3px;
  padding: 2px 3px;
  margin-left: 15px;
  display: inline;
}
</style>