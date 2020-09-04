<template>
  <div class="teacher-label">
    <img class="photo" :src="info.teacher_picture" alt="">
    <span class="name">{{ info.teacher_name }}</span>
    <div class="point"></div>
    <span class="label">{{ info.teacher_label}}</span>
  </div>
</template>
<script>
export default {
  name: 'TeacherLabel',
  props: {
    info: {
      type: Object
    }
  }
}
</script>
<style lang="css" scoped>
.teacher-label {
  display: flex;
  height: 22px;
  width: fit-content;
  border-radius: 11px;
  background: #F6F6F6;
}
.teacher-label span {
  margin: 0px 5px;
}
.photo {
  border-radius: 11px;
  width: 22px;
  height: 22px;
}
.point {
  width: 3px;
  height: 3px;
  border-radius: 1.5px;
  background: #656565;
  display: inline-block;
  margin: auto 5px;
}
.teacher-label span {
  display: inline-block;
  color: #656565;
  font-size: 12px;
  padding-top: 2px;
}
.teacher-label .name {
  margin: 0px 3px 0px 6px;
}
.teacher-label .label {
  margin: 0px 10px 0px 3px;
}
</style>