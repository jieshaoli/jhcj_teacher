import Vue from "vue";
import VueRouter from "vue-router";
import Home from "../views/Home.vue";
import Live from "../views/Live.vue";
import QuestionList from "../views/QuestionList.vue";

const original = VueRouter.prototype.push;
VueRouter.prototype.push = function push(location) {
  return original.call(this, location).catch(err => err);
}
Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    redirect: "/Live"
  },
  {
    path: "/",
    name: "Home",
    component: Home,
    children: [
      {
        path: "/Live",
        name: "Live",
        component: Live
      },
      {
        path: "/QuestionList",
        name: "QuestionList",
        component: QuestionList
      }
    ]
  },
  {
    path: "/ChatRoom",
    name: "ChatRoom",
    component: () => import("../views/ChatRoom.vue"),
    meta: {
      keepAlive: false
    }
  },
  {
    path: "/QuestionDetail",
    name: "QuestionDetail",
    component: () => import("../views/QuestionDetail.vue"),
    meta: {
      keepAlive: true
    }
  },
  {
    path: "/AnswerQuestion",
    name: "AnswerQuestion",
    component: () => import("../views/AnswerQuestion.vue"),
    meta: {
      keepAlive: true
    }
  },
  {
    path: "/videoPlay",
    name: 'videoPlay',
    component: () => import("../views/VideoPlayRoom.vue"),
    meta: {
      keepAlive: false
    }
  },
  {
    path: "/Login",
    name: "Login",
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () =>
      import(/* webpackChunkName: "login" */ "../views/Login.vue"),
    meta: {
      keepAlive: false
    }
  }
];

const router = new VueRouter({
  mode: "history",
  base: process.env.BASE_URL,
  routes
});

export default router;
