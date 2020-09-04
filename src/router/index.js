import Vue from 'vue';
import VueRouter from 'vue-router';
import Home from '../views/Home.vue';
import Live from '../views/Live.vue';
import QuestionList from '../views/QuestionList.vue';

Vue.use(VueRouter);

const routes = [
	{
        path: '/',
        redirect: '/Live'
    },
	{
		path: '/',
		name: 'Home',
		component: Home,
		children: [
			{
				path: '/Live',
				name: 'Live',
				component: Live,
			},
			{
				path: '/QuestionList',
				name: 'QuestionList',
				component: QuestionList,
      },
		],
  },
  {
    path: '/ChatRoom',
    name: 'ChatRoom',
    component: () => import('../views/ChatRoom.vue'),
  },
  {
    path: '/QuestionDetail',
    name: 'QuestionDetail',
    component: () => import('../views/QuestionDetail.vue'),
  },
  {
    path: '/AnswerQuestion',
    name: 'AnswerQuestion',
    component: () => import('../views/AnswerQuestion.vue'),
  },
	{
		path: '/Login',
		name: 'Login',
		// route level code-splitting
		// this generates a separate chunk (about.[hash].js) for this route
		// which is lazy-loaded when the route is visited.
		component: () =>
			import(/* webpackChunkName: "login" */ '../views/Login.vue'),
	},
];

const router = new VueRouter({
	mode: 'history',
	base: process.env.BASE_URL,
	routes,
});

export default router;
