import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import Mint from "mint-ui";
import "mint-ui/lib/style.css";
import "./assets/css/litewebchat.css";

Vue.use(Mint);

Vue.config.productionTip = false

Vue.filter("showTime", function(value) {
  let datetime = Number(value);
  if (datetime == undefined || datetime == "" || datetime == null) {
    return "wrong time";
  } else {
    var nDate = new Date(datetime);
    let yyyy = nDate.getFullYear();
    let MM =
      nDate.getMonth() + 1 >= 10
        ? nDate.getMonth() + 1
        : "0" + (nDate.getMonth() + 1);
    let DD = nDate.getDate() >= 10 ? nDate.getDate() : "0" + nDate.getDate();
    let h = nDate.getHours() >= 10 ? nDate.getHours() : "0" + nDate.getHours();
    let m =
      nDate.getMinutes() >= 10 ? nDate.getMinutes() : "0" + nDate.getMinutes();
    let s =
      nDate.getSeconds() >= 10 ? nDate.getSeconds() : "0" + nDate.getSeconds();
    return h + ":" + m;
  }
});

new Vue({
  router,
  store,
  render: h => h(App),
  mounted() {
    if (sessionStorage.getItem("state")) {
      this.$store.replaceState(
        Object.assign(
          {},
          this.$store.state,
          JSON.parse(sessionStorage.getItem("state"))
        )
      );
    }
    window.addEventListener("beforeunload", this.saveState);
  },
  methods: {
    saveState() {
      sessionStorage.setItem("state", JSON.stringify(this.$store.state));
    }
  }
}).$mount('#app')
