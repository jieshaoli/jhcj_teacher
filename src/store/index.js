import Vue from 'vue';
import Vuex from 'vuex';
// import { reject, resolve } from 'core-js/fn/promise';
import { login, getTeacherInfoByTheAccount } from '../api/userApi';

Vue.use(Vuex);

export default new Vuex.Store({
	state: {
		user: {
			user_id: '',
			user_name: '',
			user_photo: '',
			user_role: 1,
			user_label: '',
		},
		access_token: '',
		refresh_token: '',
	},
	mutations: {
		SET_ACCESS_TOKEN(state, msg) {
			state.access_token = msg;
		},
		SET_REFRESH_TOKEN(state, msg) {
			state.refresh_token = msg;
		},
		SET_USER(state, msg) {
			state.user = {
        user_id: msg.id,
        user_name: msg.teacher_name,
        user_photo: msg.teacher_picture
			};
		},
	},
	actions: {
		Login({ commit }, info) {
			return new Promise((resolve, reject) => {
				login(info).then(res => {
          const tokenStr = res.access_token;
          const refreshTokenStr = res.refresh_token;
          commit('SET_ACCESS_TOKEN', tokenStr);
          commit('SET_REFRESH_TOKEN', refreshTokenStr);
          localStorage.setItem('access_token', tokenStr);
          localStorage.setItem('refresh_token', refreshTokenStr);
          resolve(res);
        }).catch(error => {
          reject(error);
        });
			});
    },
    Logout({ commit }) {
      commit('SET_ACCESS_TOKEN', '');
      commit('SET_REFRESH_TOKEN', '');
      localStorage.removeItem('access_token');
      localStorage.removeItem('refresh_token');
    },
    GetTeacherInfo({ commit }) {
      return new Promise((resolve, reject) => {
        getTeacherInfoByTheAccount().then(res => {
          commit('SET_USER', res.result);
          localStorage.setItem('user', JSON.stringify(res.result));
          resolve(res);
        }).catch(error => {
          reject(error);
        })
      }) 
    }
	},
	getters: {
		user: (state) => state.user,
		access_token: (state) => state.access_token,
		refresh_token: (state) => state.refresh_token,
	},
});
