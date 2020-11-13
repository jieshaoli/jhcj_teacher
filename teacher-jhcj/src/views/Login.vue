<template>
  <div class="Login">
    <Login-form></Login-form>
  </div>
</template>

<script>
import LoginForm from '../components/LoginForm';
import { mapGetters } from 'vuex';


export default {
  name: 'Login',
  components: {
    LoginForm,
  },
  computed: {
    ...mapGetters({
      access_token: 'access_token',
    }),
  },
  watch: {
    access_token(value, oldValue) {
      if (value == null || value == '' || value == undefined) {
      } else {
        if (value && value.length > 4) {
          this.$router.replace('/');
        }
      }
    },
  },
  created() {
    if (
      this.access_token == '' &&
      this.access_token == undefined &&
      this.access_token == null
    ) {
      console.log('no access_token', this.access_token);
    } else {
      console.log('access_token', this.access_token);
    }
  },
};
</script>

<style lang="css" scoped>
.Login {
  width: 100%;
  height: 100%;
  background: url(../assets/images/background.gif) no-repeat;
  background-size: 100% 100%;
  text-align: center;
  position: absolute;
}
</style>
