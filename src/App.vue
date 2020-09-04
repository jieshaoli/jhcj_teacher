<template>
  <div id="app">
    <!-- <div id="nav">
      <router-link to="/">Home</router-link> |
      <router-link to="/about">About</router-link>
    </div>
    <router-view/> -->
    <keep-alive exclude="ChatRoom">
      <router-view></router-view>
    </keep-alive>
  </div>
</template>
<script>
export default {
  name: 'App',
  created() {},
};
</script>
<style>
html,
body,
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  height: 100%;
  padding: 0;
  margin: 0;
  -webkit-tap-highlight-color: white;
  -webkit-tap-highlight-color: transparent;
}
body .mint-msgbox {
  border-radius: 10px;
}
body .mint-header {
  background: white;
  border-bottom: 1px solid #e1e1e1;
}
.mint-header .mint-header-button.is-left {
  color: black;
}
/* .mint-header .mint-button {
  width: 40px;
} */
body .mint-header-title {
  color: #000;
  font-size: 20px;
}
</style>
