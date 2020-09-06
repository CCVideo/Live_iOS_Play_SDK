!(function (window, document) {
  window.isHttps = (window.location.protocol === 'https:')

  window.isSupportCanvas = false
  try {
    window.isSupportCanvas = !!document.createElement('canvas').getContext
  } catch (e) {
  }

  function isSupportFlash() {
    if (navigator.appVersion.indexOf('MSIE') >= 0) {
      try {
        return !!(new ActiveXObject('ShockwaveFlash.ShockwaveFlash'))
      } catch (e) {
        return false
      }
    } else {
      if (!navigator.plugins['Shockwave Flash']) {
        return false
      }
    }

    return true
  }

  window.isSupportFlash = isSupportFlash()

  // 文档显示模式
  // 1 适合窗口
  // 2 适合宽度
  var DisplayMode = function () {
    this.mode = Utils.getURLParameter('displayMode')
    this.vertical = Utils.getURLParameter('vertical')

    this.isVerticalCenter = (this.vertical == '1')
    // 适合窗口
    this.isSuitableForWindow = (this.mode == 1)
    // 适合宽度
    this.isSuitableForWidth = (this.mode != 1)
  }

  window.DisplayMode = DisplayMode

})(window, document, undefined)
