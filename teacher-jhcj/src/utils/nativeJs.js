const NativeJSMixin = {
  methods: {
    js2native(param) {
      if (/(iPhone|iPad|iPod|iOS)/i.test(navigator.userAgent)) {
        window.webkit.messageHandlers.js2native.postMessage(param);
      } else if (/(Android|Adr)/i.test(navigator.userAgent)) {
        window.CanvasRenderingContext2D.jsToandroid(param);
      }
    },
    native2js(param){

    }
  }
};

export default NativeJSMixin;
