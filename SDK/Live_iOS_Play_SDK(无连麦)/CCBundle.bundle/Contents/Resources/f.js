/**
 * f
 *
 * Version 0.1.3
 *
 * Created by shanglt on 2018/05/21.
 */
!(function (window) {
  var F = function () {

    if (Utils.getURLParameter('displayMode') == 1) {
      this.displayMode = 'auto'
    } else {
      this.displayMode = 'width'
    }

    document.getElementById('drawingBoard').style.display = 'none'
    document.getElementById('fls').style.display = ''

    var swfUrl = '//zeus.csslcloud.net/flash/Player.swf'
    var flashvars = {
      'type': 'drawpanel'
    }
    var params = {
      allowFullscreen: 'true',
      allowScriptAccess: 'always',
      wmode: 'transparent'
    }
    var attributes = {}
    swfobject.embedSWF(swfUrl, 'fls', '100%', '100%',
      '10.0.0', '/flash/expressInstall.swf', flashvars, params, attributes)

    this.pc = undefined
    this.animationData = undefined
    this.tempCaches = []

    this.isReady = false

    if (!window.isSupportFlash) {
      // TODO
    }

    this.resize = function () {
      // console.log('f.js resize');
    }

    this.getF = function () {
      return swfobject.getObjectById('fls')
    }

    this.clear = function (data) {
      // console.log('f.js clear', data);

      if (!this.isReady) {
        return
      }

      swfobject.getObjectById('fls').clear()
    }

    this.draw = function (data) {
      if (!this.isReady) {
        this.tempCaches.push(data)
        return
      }

      this.getF().draw(JSON.stringify(data.originalData))
    }

    this.draws = function (data) {
      var dl = []
      for (var i = 0; i < data.length; i++) {
        // this.draw(data[i]);
        var dd = data[i]
        if ((dd.drawType == 8 || dd.drawType == 0) && i <= 1) {
          continue
        }

        dl.push(JSON.stringify(dd.originalData))
      }

      dp.f.getF().drawList(dl)
    }
    //添加跑马灯
    this.appendMarquee = function (data) {
      if (!dp.f.pluginReady) {
        return
      }
      dp.f.getF().showMarqueeLight(data)
    }
    //关闭跑马灯
    this.closeMaruee = function () {
      if (!dp.f.pluginReady) {
        return
      }
      dp.f.getF().closePluginMarquee()
    }
    //添加弹幕
    this.appendBulletPlugin = function () {
      if (!dp.f.pluginReady) {
        return
      }
      dp.f.getF().showBulletCurtain()
    }
    this.appendBullet = function (data) {
      if (!dp.f.pluginReady) {
        return
      }
      dp.f.getF().addBullet(data)
    }
    this.pageChange = function (data) {
      if (!this.isReady) {
        this.pc = data
        return
      }

      if (data.isAnimationFastestMode) {
        data.useSDK = false
      }

      this.getF().filp(JSON.stringify({
        'fileName': data.docName,
        'totalPage': data.docTotalPage,
        'docid': data.docId,
        'url': data.url,
        'page': data.pageNum,
        'useSDK': data.useSDK
      }), this.displayMode)
    }

    this.animation = function (data) {
      // console.log('f.js animation', data);

      if (!this.isReady) {
        this.animationData = data
        return
      }

      this.getF().animation(JSON.stringify({
        docid: data.docId,
        page: data.pageNum,
        step: data.step
      }))
    }

    this.cacheAndDraw = function (data) {
      if (!this.isReady) {
        this.tempCaches.push(data)
        return
      }

      this.draw(data)
    }

    this.cacheHistoryDraws = function (data) {
      if (!this.isReady) {
        for (var i = 0; i < data.length; i++) {
          this.tempCaches.push(data[i])
        }
        return
      }

      this.draws(data)
    }

    this.clearCaches = function () {
      if (this.pc) {
        this.pageChange(this.pc)
        this.pc = undefined
      }

      if (this.animationData) {
        (function (t) {
          setTimeout(function () {
            t.animation(t.animationData)
            t.animationData = undefined
          }, 1000)
        })(this)
      }

      if (this.tempCaches && this.tempCaches.length) {
        this.draws(this.tempCaches)
        this.tempCaches = []
      }
    }

  }

  window.on_cc_player_pluginready = function () {
    dp.f.pluginReady = true
  }
  window.on_drampanel_ready = function () {
    dp.f.isReady = true
    dp.f.clearCaches()
  }

  window.F = F
})(window, undefined)
