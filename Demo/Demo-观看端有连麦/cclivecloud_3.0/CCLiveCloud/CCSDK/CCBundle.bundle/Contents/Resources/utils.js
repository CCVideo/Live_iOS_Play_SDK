/**
 * utils
 *
 * Version 0.0.1
 *
 * Created by shanglt on 2018/05/21.
 */
!(function (window, document) {
  var twoPm14 = Math.pow(2, -14)
  if (!window.console) {
    window.console = {
      log: function () {

      }
    }
  }
  var Utils = {

    getosType: function () {
      var u = navigator.userAgent
      var app = navigator.appVersion
      var isAndroid = u.indexOf('Android') > -1 || u.indexOf('Adr') > -1 //android
      var isiOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/) //ios终端
      var isWin = (navigator.platform == "Win32") || (navigator.platform == "Windows");
      if(isWin){
        return "windows";
      }
      if (isAndroid) {
        return 'android'
      }
      if (isiOS) {
        return 'ios'
      }
      return 'pc'
    },
    isDOMContains:function(parentEle,ele){
      //parentEle: 要判断节点的父级节点
      //ele:要判断的子节点
      //container : 二者的父级节点

      //如果parentEle h和ele传的值一样，那么两个节点相同
      if(parentEle == ele){
        return true
      }
      if(!ele || !ele.nodeType || ele.nodeType != 1){
        return false;
      }
      //如果浏览器支持contains
      if(parentEle.contains){
        return parentEle.contains(ele)
      }
      //火狐支持
      if(parentEle.compareDocumentPosition){
        return !!(parentEle.compareDocumentPosition(ele)&16);
      }

      //获取ele的父节点
      var parEle = ele.parentNode;
      while(parEle){
        if(parEle == parentEle){
          return true;
        }
        parEle = parEle.parentNode;
      }
      return false;
    },
    ajax:function(obj) {
      var xhr
      var m = obj.method ? obj.method : "GET";
      var timeout = 6000;
      var isTimeout = true;
      if (window.XMLHttpRequest) {
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function (e) {
          if (parseInt(xhr.readyState, 10) === 4) {
            if (xhr.status == 200) {
              obj.success && obj.success(xhr.responseText);
            } else {
              obj.fail && obj.fail(xhr.status)
            }
            isTimeout = false;
          }
        }
        xhr.onerror = function (e) {
          obj.fail && obj.fail(e)
          isTimeout = false;
        }
        xhr.ontimeout = function () {
          obj.timeout && obj.timeout();
        }
        if(xhr.timeout){
          xhr.timeout = timeout;
        }
        xhr.open(m, obj.url, true);
        xhr.send();
      }
    },

    // 获取URL的参数
    getURLParameter: function (name) {
      return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) || null
    },
    getTerminalType: function () {
      var u = navigator.userAgent, app = navigator.appVersion
      var isAndroid = u.indexOf('Android') > -1 || u.indexOf('Linux') > -1 //g
      var isIOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)
      if (isIOS) {
        return 'ios'
      }
      if (isAndroid) {
        return 'android'
      }
      return ''
    },
    // 如果参数为string，转换为json
    toJson: function (j) {
      if (!j) {
        return {}
      }

      if (typeof j === 'string') {
        try{
          j = JSON.parse(j)
        }catch (e) {
          j= j.replace(/[\n|\t|\s|\r|\f]/g,"");
          j = JSON.parse(j)
          console.log("数据格式错误")
        }
      }
      return j
    },

    pmToIfr: function (data) {
      if (typeof data != 'string') {
        data = JSON.stringify(data)
      }

      var df = document.getElementById('ifr')
      if (df && df.contentWindow) {
        df.contentWindow.postMessage(data, '*')
      } else {
        console.error('dpc', 'df is null')
      }
    },

    pmToParent: function (data) {
      if (typeof data != 'string') {
        data = JSON.stringify(data)
      }

      var wp = window.parent
      if (wp && wp.postMessage) {
        wp.postMessage(data, '*')
      }
    },

    getHexRGB: function (o) {
      var h = parseInt(o, 10).toString(16).toUpperCase()
      var hl = h.length
      for (var i = 0; i < 6 - hl; i++) {
        h = '0' + h
      }
      return '#' + h
    },

    getDrawId: function (data) {
      return data.drawid
    },

    // 是否支持Canvas
    isSupportCanvas: function () {
      try {
        return !!document.createElement('canvas').getContext
      } catch (e) {
        return false
      }
    },

    getPageChangeCompleteURI: function (pc) {
      if (pc.isWhiteBorad) {
        return pc.url
      }

      var u = pc.url

      if (window.isHttps) {
        u = u.replace(/http:/g, 'https:')
      } else {
        u = u.replace(/https:/g, 'http:')
      }

      // 图片
      if (pc.isJpg) {
        return u
      }

      // 动画

      // 极速模式
      if (pc.isAnimationFastestMode) {
        if (pc.pageNum == 0) {
          return u.replace(/[0-9]+.jpg/ig, 'index.html')
        } else {
          return u.replace(/[0-9]+.jpg/ig, 'index.html?startSlide=' + pc.pageNum)
        }
      }

      // 非极速模式
      return u.replace('.jpg', '/index.html')
    },

    refactorPageChangeData: function (data) {
      data = Utils.toJson(data)
      var pc = {}
      if (data.action === 'page_change') { // 通过pusher传递的翻页信息
        pc.docId = data.value.docid
        pc.docName = data.value.fileName
        pc.docTotalPage = data.value.totalPage
        pc.width = data.value.width
        pc.height = data.value.height
        pc.useSDK = data.value.useSDK
        pc.pageTitle = data.value.pageTitle
        pc.pageNum = data.value.page
        pc.url = data.value.url
        pc.mode = data.value.mode
        pc.time = data.time

      } else { // 翻页的历史数据
        pc.docId = data.docId
        pc.docName = data.docName
        pc.docTotalPage = data.docTotalPage
        pc.width = data.width
        pc.height = data.height
        pc.useSDK = data.useSDK
        pc.pageTitle = data.pageTitle
        pc.pageNum = data.pageNum
        pc.url = data.url
        pc.time = data.time
        pc.mode = data.mode
      }

      if (pc.mode === undefined || pc.mode === null) {
        if (pc.useSDK) {
          pc.mode = 1
        } else {
          pc.mode = 0
        }
      }

      // 更新数据
      // 翻页唯一key
      pc.key = pc.docId + '_' + pc.pageNum
      // 白板
      pc.isWhiteBorad = (pc.url === '#' && pc.docName === 'WhiteBorad')
      // 图片
      pc.isJpg = (!pc.isWhiteBorad && pc.mode == 0)
      // 动画（极速模式和非极速模式）
      pc.isAnimation = (pc.mode == 1 || pc.mode == 2)
      // 动画极速模式
      pc.isAnimationFastestMode = (pc.mode == 2)
      // 动画非极速模式
      pc.isAnimationSlowMode = (pc.mode == 1)
      // 完整的翻页地址
      pc.completeURI = Utils.getPageChangeCompleteURI(pc)

      return pc
    },

    refactorAnimationChangeData: function (data) {
      data = Utils.toJson(data)
      var ac = {}
      if (data.action === 'animation_change') {
        ac.docId = data.value.docid
        ac.pageNum = data.value.page
        ac.step = data.value.step
        ac.time = data.time
      } else {
        ac.docId = data.docId
        ac.pageNum = data.pageNum
        ac.step = data.step
        ac.time = data.time
      }

      return ac
    },
    refactorDrawData: function (data) {
      data = Utils.toJson(data)

      var d = {}
      if (data.action === 'draw') {
        if (!data.value) {
          return d
        }
        var dv = Utils.toJson(data.value)
        var dvData = Utils.toJson(dv.data)

        d.originalData = dvData
        d.docId = dvData.docid
        d.docName = dv.fileName
        d.docPageIndex = dv.page
        d.docHeight = dvData.height
        d.docWidth = dvData.width
        d.docKey = d.docId + '_' + d.docPageIndex
        d.drawAlpha = dvData.alpha
        d.drawColor = Utils.getHexRGB(dvData.color)
        d.drawId = dvData.drawid
        d.drawData = dvData.draw
        d.drawTriggerTime = data.time
        d.drawDuration = dvData.drawtime
        d.drawLineWidth = dvData.thickness
        d.drawType = dvData.type

      } else {
        var dataD = Utils.toJson(data.data)
        d.originalData = dataD
        d.docId = dataD.docid
        d.docName = data.docName
        d.docPageIndex = dataD.page
        d.docHeight = dataD.height
        d.docWidth = dataD.width
        d.docKey = d.docId + '_' + d.docPageIndex
        d.drawAlpha = dataD.alpha
        d.drawColor = Utils.getHexRGB(dataD.color)
        d.drawId = dataD.drawid
        d.drawData = dataD.draw
        d.drawTriggerTime = data.time
        d.drawDuration = dataD.drawtime
        d.drawLineWidth = dataD.thickness
        d.drawType = dataD.type
      }

      d.isRealTimeDraw = d.drawDuration > 0

      return d
    },
    resolveDrawData: function (data) {//激光笔数据
      data = Utils.toJson(data)
      var newObj = {}
      if (data.action === 'draw') {
        if (!data.value) {
          return d
        }

        var vObj = data.value
        var dObj = vObj.data
        newObj.version = vObj.version
        newObj.drawTriggerTime = data.time
        newObj.drawType = dObj.type
        newObj.docName = data.docName
        newObj.docHeight = dObj.height
        newObj.docWidth = dObj.width
        newObj.docId = dObj.docid
        newObj.docKey = dObj.docid + '_' + dObj.page
        newObj.drawDuration = dObj.duration
        newObj.drawAlpha = dObj.alpha
        newObj.drawColor = Utils.getHexRGB(dObj.color)
        newObj.drawLineWidth = dObj.thickness
        newObj.drawId = dObj.drawid
        var infoList = []
        var len = dObj.pos.length
        for (var i = 0; i < len; i++) {
          var d = {}
          d.x = this.half2num((dObj.pos[i] & 0x0000ffff))
          d.y = this.half2num(((dObj.pos[i] & 0xffff0000) >> 16))
          infoList.push(d)
        }
        newObj.drawData = infoList
        newObj.playType = 'live'
      } else {
        var dObj = Utils.toJson(data.data)
        newObj.version = data.version
        newObj.drawTriggerTime = data.time
        newObj.drawType = dObj.type
        newObj.docName = data.docName
        newObj.docHeight = dObj.height
        newObj.docWidth = dObj.width
        newObj.docId = dObj.docid
        newObj.docKey = dObj.docid + '_' + dObj.page
        newObj.drawDuration = dObj.duration
        newObj.drawAlpha = dObj.alpha
        newObj.drawColor = Utils.getHexRGB(dObj.color)
        newObj.drawLineWidth = dObj.thickness
        newObj.drawId = dObj.drawid
        var infoList = []
        var len = dObj.pos.length
        for (var i = 0; i < len; i++) {
          var d = {}
          d.x = this.half2num((dObj.pos[i] & 0x0000ffff))
          d.y = this.half2num(((dObj.pos[i] & 0xffff0000) >> 16))
          infoList.push(d)
        }
        newObj.drawData = infoList
        newObj.playType = 'callback'
      }
      return newObj
    },
    half2num: function (n) {
      var sign = 1 - ((n & 0x8000) >> 14)
      var exponent = (n & 0x7c00) >> 10
      var mantissa = (n & 0x03ff)

      if (exponent === 0) {
        if (mantissa !== 0) {
          return sign * twoPm14 * (mantissa / 1024)
        }
        else {
          return sign * 0
        }
      }
      else if (exponent < 31) {
        return sign * Math.pow(2, exponent - 15) * (1 + mantissa / 1024)
      }
      else {
        if (mantissa === 0) {
          return sign * Infinity
        }
        else {
          return NaN
        }
      }
    }

  }

  window.Utils = Utils

})(window, document, undefined)
