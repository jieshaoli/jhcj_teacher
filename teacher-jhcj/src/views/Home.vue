<template>
  <div class="home">
    <mt-header fixed
               :title="navTitle">
      <router-link to
                   slot="left">
        <mt-button @click.native="logout">退出登录</mt-button>
      </router-link>
      <!-- <mt-button icon="more"
                 slot="right"></mt-button> -->
    </mt-header>
    <div class="content">
      <keep-alive>
        <router-view></router-view>
      </keep-alive>
    </div>
    <div class="tabbar"
         id="tab">
      <mt-tabbar v-model="selected"
                 value="Live">
        <mt-tab-item id="Live"
                     @click.native="tapLive">
          <img slot="icon"
               src="../assets/images/tabbar_live_.png"
               v-show="showLive">
          <img slot="icon"
               src="../assets/images/tabbar_live_nor_.png"
               v-show="!showLive">
          直播
        </mt-tab-item>
        <mt-tab-item id="QuestionList"
                     @click.native="tapQa">
          <img slot="icon"
               src="../assets/images/tabbar_qa_.png"
               v-show="!showLive">
          <img slot="icon"
               src="../assets/images/tabbar_qa_nor_.png"
               v-show="showLive">
          问答
        </mt-tab-item>
      </mt-tabbar>
    </div>
  </div>
</template>

<script>
// @ is an alias to /src
// import HelloWorld from '@/components/HelloWorld.vue'
import { mapGetters } from 'vuex';
import noti from '../common/notification.js';
import { MessageBox, Toast } from 'mint-ui';

export default {
  name: 'Home',
  data() {
    return {
      navTitle: '',
      selected: 'Live',
      showLive: true,
    };
  },
  created() {
    noti.$on('title', (msg) => {
      this.navTitle = msg;
    });
    noti.$on('route', (msg) => {
      if (msg.info) {
        this.$router.push({ path: msg.path, query: msg.info });
      } else {
        this.$router.push(msg.path);
      }
    });
    if (this.$route.name == 'Live') {
      this.showLive = true;
      this.selected = 'Live';
    } else {
      this.showLive = false;
      this.selected = 'QuestionList';
    }
  },
  watch: {
    access_token(value, oldValue) {
      if (value == null || value == '' || value == undefined) {
        this.$router.replace('/Login');
      } else {
        if (value && value.length > 4) {
        }
      }
    },
    $route(value, oldValue) {
      this.selected = value.name;
      if (value.name == 'Live') {
        this.showLive = true;
      } else {
        this.showLive = false;
      }
    },
  },
  components: {},
  computed: {
    ...mapGetters({
      access_token: 'access_token',
    }),
  },
  mounted() {},
  methods: {
    tapLive() {
      this.showLive = true;
      this.$router.replace('/Live');
    },
    tapQa() {
      this.showLive = false;
      this.$router.replace('/QuestionList');
    },
    logout() {
      MessageBox.confirm('确定要退出登录吗？')
        .then((res) => {
          console.log(res);
          this.$store.dispatch('Logout');
          localStorage.clear();
          Toast({
            message: '退出成功',
            position: 'bottom',
            duration: 1000,
          });
          this.$router.push('/Login');
        })
        .catch((rej) => {
          console.log(rej);
        });
    },
  },
};
</script>

<style lang="css" scoped>
.home {
  width: 100%;
  height: 100%;
  padding: 0;
  margin: 0;
}
.tabbar {
  position: fixed;
  width: 100%;
  bottom: 0;
  border-top: 1px solid #999;
  height: 55px;
}
.mint-tabbar > .mint-tab-item.is-selected {
  color: red;
  background: #fff;
}
.mint-tabbar {
  border: 1px 0 0;
  background: #fff;
  border-color: #000;
}
.content {
  position: fixed;
  top: 40px;
  padding: 0;
  margin: 0;
  width: 100%;
}
</style>
