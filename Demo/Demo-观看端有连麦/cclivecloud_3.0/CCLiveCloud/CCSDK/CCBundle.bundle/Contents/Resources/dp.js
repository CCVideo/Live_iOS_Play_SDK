/**
 * dp
 *
 * Version 0.1.5
 *
 * Created by shanglt on 2018/05/21.
 */
!(function (window) {

  window.TRIGGERED_ANIMATION_STEP = -1
  window.ANIMATIONSTEPSCOUNT = -1
  window.registerFunList = ['cacheAndDraw', 'draw', 'resetWithMeta', 'cacheHistoryDraws', 'pageChange', 'animationChange', 'showAnimationPage', 'showDefaultPage', 'resize']

  var timeIntervalId = -1
  var Dp = function () {

    if (window.isSupportCanvas) {
      // 当前翻页信息
      this.pc = new PC()

      this.db = new DrawingBoard()

      this.pc.db = this.db
      this.db.pc = this.pc

      this.currentAnimationData = {
        totalSteps: -1,
        currentStepIndex: -1,
        currentSlideIndex: -1,
        hasNextAnimationStep: false
      }
      //this.pc.showDefaultPageChange();
    } else {
      this.f = new F()
    }
    this.setShowImageType = function (t) {
      this.pc.showImageType = t
    }
    this.pageChange = function (v) {
      var dp = this
      this.isEnd = false
      if (window.isSupportCanvas) {
        dp.currentAnimationData = {
          totalSteps: -1,
          currentStepIndex: -1,
          currentSlideIndex: -1,
          hasNextAnimationStep: false
        }

        window.TRIGGERED_ANIMATION_STEP = -1
        window.ANIMATIONSTEPSCOUNT = -1

        dp.pc.pageChange(v)

        window.scrollTo(0, 0)

        Utils.pmToParent({
          action: 'resize_from_dp',
          width: document.getElementById('drawingBoard').style.width,
          height: document.getElementById('drawingBoard').style.height
        })
      } else {
        dp.f.pageChange(v)
      }
    }

    this.animation = function (v) {
      var dp = this
      if (window.isSupportCanvas) {
        dp.pc.animation(v)
      } else {
        dp.f.animation(v)
      }
    }

    this.animationCallback = function (data) {
      data.action = 'animation_change_from_dp'

      Utils.pmToParent(data)

      dp.currentAnimationData = {
        totalSteps: data.totalSteps,
        currentStepIndex: data.currentStepIndex,
        currentSlideIndex: data.currentSlideIndex,
        hasNextAnimationStep: data.hasNextAnimationStep
      }

      window.TRIGGERED_ANIMATION_STEP = dp.currentAnimationData.currentStepIndex
      window.ANIMATIONSTEPSCOUNT = dp.currentAnimationData.totalSteps

      dp.pc.animationCallback(data)
    }

    this.width = document.documentElement.clientWidth
    this.height = document.documentElement.clientHeight
    //this.isEnd = false;//是否推流结束
    this.resize = function (w, h) {
      if (window.isSupportCanvas) {
        if (this.width == w && this.height == h) {
          return
        }

        var wid = w ? w : window.innerWidth;
        var hei = h ? h : window.innerHeight;
        this.width = wid
        this.height = hei

        dp.pc.resize(wid, hei)
      } else {
        this.f.resize()
      }
    }
    this.setDocCss = function (data) {
      if (window.isSupportCanvas) {
        this.pc.setDocCss(data)
      } else {

      }

    }
    this.draw = function (data) {
      if (window.isSupportCanvas) {
        this.db.draw(data)
      } else {
        this.f.draw(data)
      }
    }
    this.drawNoCacheV2 = function (data) {
      if (window.isSupportCanvas) {
        this.db.drawNoCacheV2(data)
      } else {
      }
    }
    this.cacheAndDraw = function (data) {
      if (window.isSupportCanvas) {
        this.db.cacheAndDraw(data)
      } else {
        this.f.cacheAndDraw(data)
      }
    }

    this.cacheHistoryDraws = function (data) {
      if (window.isSupportCanvas) {
        this.db.cacheHistoryDraws(data)
      } else {
        this.f.cacheHistoryDraws(data)
      }
    }

    this.clear = function () {
      if (window.isSupportCanvas) {
        this.pc.clear()
        this.db.clear()
        //this.pc.showDefaultPageChange();
      } else {
        this.f.clear()
      }
      this.isEnd = true
    }
    //初始化弹幕插件
    this.bulletCurtainInit = function (line) {
      if (window.isSupportCanvas) {
        if (!this.bulletCont) {
          this.bulletCont = new BulletContainer()
          this.bulletCont.init(line)
          this.isAddBullet = true
          return
        }
        this.bulletCont.startToRun()
      } else {
        this.f.appendBulletPlugin()
      }
    }
    //添加弹幕
    this.appendBullet = function (val) {
      if (window.isSupportCanvas) {
        if (this.isAddBullet) {
          this.bulletCont.push(val)
        }
      } else {
        this.f.appendBullet(val.content)
      }

    }
    this.closeBarrage = function () {
      if (window.isSupportCanvas) {
        if (this.bulletCont) {
          this.bulletCont.close()
        }
      } else {

      }
    }
    this.creatMarquee = function (data) {
      if (window.isSupportCanvas) {
        if (this.marquee) {
          this.marquee.startTimerToRun()
        } else {
          this.marquee = new MarqueePlugin()
          this.marquee.init(data.value)
        }
      } else {
        this.f.appendMarquee(data.value)
      }
    }
    this.closeMarquee = function () {
      if (window.isSupportCanvas) {
        if (!this.marquee) {
          return
        }
        this.marquee.close()
      } else {
        this.f.closeMaruee()
      }
    }
  }

  //进行缓存对象
  window.preloadSource = function (u) {
    var ifr = document.getElementById('preload_iframe')
    ifr.src = ''
    ifr.src = u
  }

  // 实例化画板对象
  window.dp = new Dp()
  /**
   * 仅触发画笔操作，不进行缓存
   * */
  window.draw = function (data) {
    dp.draw(Utils.refactorDrawData(data))
  }
  /**
   * 缓存并触发画笔操作
   * */
  window.cacheAndDraw = function (data) {
    var ifo = Utils.toJson(data)
    if (!ifo.value || !ifo.value.version) {  //没有版本号走老接口
      dp.cacheAndDraw(Utils.refactorDrawData(data))
      if (ifo.version === '2.0') {
        dp.drawNoCacheV2(Utils.resolveDrawData(data))
      }
    } else {
      if (ifo.value.version === '2.0') {
        dp.drawNoCacheV2(Utils.resolveDrawData(data))
        // console.log('111111');
      }
    }
  }
  /**
   * 根据元数据重置文档
   * meta = {
   *      pageChange: [],
   *      animation: [],
   *      draw: []
   *  }
   * */
  window.resetWithMeta = function (meta) {
    meta = Utils.toJson(meta)
    var pageChanges = meta.pageChange
    var animations = meta.animation
    var draws = meta.draw

    if (pageChanges.length) {
      var lastPageChange = pageChanges.pop()
      if (lastPageChange) {
        dp.pageChange(Utils.refactorPageChangeData(lastPageChange))

        // TODO 数据整理
        if (animations.length) {
          var latestAnimationChange = animations.pop()
          latestAnimationChange = Utils.toJson(latestAnimationChange)
          lastPageChange = Utils.toJson(lastPageChange)
          if (lastPageChange.docid == latestAnimationChange.docid
            && lastPageChange.pageNum == latestAnimationChange.pageNum
            && lastPageChange.time <= latestAnimationChange.time) {
            dp.animation(Utils.refactorAnimationChangeData(latestAnimationChange))
          }
        }
      }
    }

    if (draws.length) {
      // var ndraws = [];
      // for (var i = 0; i < draws.length; i++) {
      //     ndraws.push(Utils.refactorDrawData(draws[i]));
      // }
      // window.cacheHistoryDraws(draws);

      var hdds = []
      for (var i = 0; i < draws.length; i++) {
        hdds.push(Utils.refactorDrawData(draws[i]))
      }
      dp.cacheHistoryDraws(hdds)
    }
  }

  /**
   * 缓存画笔数据
   * */
  window.cacheHistoryDraws = function (data) {
    var hdds = []
    for (var i = 0; i < data.length; i++) {
      hdds.push(Utils.refactorDrawData(data[i]))
    }
    dp.cacheHistoryDraws(hdds)
  }
  /**
   * 翻页
   * */
  window.pageChange = function (data) {
    dp.pageChange(Utils.refactorPageChangeData(data))
  }

  /**
   * 触发动画
   * */
  window.animationChange = function (data) {
    dp.animation(Utils.refactorAnimationChangeData(data))
  }
  /**
   * 设置dp文档背景颜色
   *
   */
  window.setDocCss = function (data) {
    if (!data) return
    dp.setDocCss(data)
  }
  /**
   * 清空所有数据，包括缓存数据
   * */
  window.clear = function () {
    dp.clear()
  }
  //各个端主动调用resize 则不触发resize监听
  window.dpResize = function (e) {
    dp.resize()
  }

  if (window.addEventListener) {
    window.addEventListener('resize', window.dpResize)
  } else {
    window.attachEvent('onresize', window.dpResize)
  }
  /**
   * 重置文档大小
   * */
  window.resize = function (w, h) {
    window.removeEventListener('resize', window.dpResize)
    if (timeIntervalId != -1) {
      clearInterval(timeIntervalId)
    }
    dp.resize(w, h)
    Utils.pmToParent({
      action: 'resize_from_dp',
      width: window.outerWidth,
      height: window.outerHeight
    })
  }

  window.animationChangedCallback = function (data) {
    dp.animationCallback(data)
  }

  /**添加插件接口**/
  window.appendMarqueePlugin = function (data) {
    dp.creatMarquee(data)
  }
  //初始化弹幕信息参数 l 为弹幕行数（默认弹幕为4行）
  window.appendBulletPlugin = function (l) {
    dp.bulletCurtainInit(l)
  }
  window.closeMarquee = function () {
    dp.closeMarquee()
  }
  window.closeBarrage = function () {
    dp.closeBarrage()
  }
  window.controlImageShowType = function (t) {
    dp.setShowImageType(t)
  }
  window.appendBullet = function (data) {
    if (!data) return
    if (data.length && data.length > 0) {
      for (var i = 0; i < data.length; i++) {
        var bullet
        if (typeof data[i] == 'string') {
          try {
            bullet = JSON.parse(data[i])
          } catch (e) {
            continue
          }
        } else {
          bullet = data[i]
        }
        dp.appendBullet(bullet)
      }
    } else {
      dp.appendBullet(data)
    }
  }
  window.showDefaultPage = function () {
    dp.showDefaultImage()
  }
  window.setPlayMode = function (m) {
    dp.playMode = m
  }
  window.showAnimationPage = function (v) {
    dp.pc.showAnimationPage(v)
  }
  window.sliderChangeFrome_dpa = function (l) {
    dp.pc.sliderChange(l)
  }
  window.dpMessage = function (event) {
    var data = Utils.toJson(event.data)
    var action = data.action
    if (!action) {
      return
    }
    switch (action) {
      case 'page_change_from_dpc':
        window.pageChange(data.value)
        break
      case 'animation_change_from_dpc':
        window.animationChange(data.value)
        break
      case 'draw_from_dpc_nocache':
        window.draw(data.value)
        break
      case 'draw_from_dpc':
        window.cacheAndDraw(data.value)
        break
      case 'animation_change':
        window.animationChangedCallback(data)
        break
      case 'reset_with_meta_from_dpc':
        window.resetWithMeta(data.value)
        break
      case 'clear_from_dpc':
        window.clear()
        break
      case 'cacheHistoryDraws_from_dpc':
        window.cacheHistoryDraws(data.value)
        break
      case 'resize_from_dpc':
        dp.resize()
        break
      case 'add_plugin_marquee':
        window.appendMarqueePlugin(data)
        break
      case 'add_plugin_bullet':
        window.appendBulletPlugin(data.value)
        break
      case 'append_bullet':
        window.appendBullet(data.value)
        break
      case 'show_default_page':
        window.showDefaultPage()
        break
      case 'close_plugin_marquee':
        window.closeMarquee()
        break
      case 'close_plugin_barrage':
        window.closeBarrage()
        break
      case 'show_animation_page_from_dpa':
        window.showAnimationPage(data)
        break
      case 'show_animation_sldier_change_frome_dpa':
        window.sliderChangeFrome_dpa(data.currentSlideIndex)
        break
      case 'resize_from_dpc_doc':
        window.resize(data.value.w, data.value.h)
        break
    }
  }

  if (window.attachEvent) {
    // window.attachEvent("onresize", window.resize, false);
    window.attachEvent('onmessage', window.dpMessage, false)
  } else {
    // window.addEventListener("resize", window.resize, false);
    window.addEventListener('message', window.dpMessage, false)

    // window.addEventListener("onorientationchange" in window ? "orientationchange" : "resize", function () {
    //     setTimeout(function () {
    //         window.resize();
    //     });
    // }, false);
  }


  timeIntervalId = setInterval(function () {
    if (!window.dp) {
      return
    }

    if (window.isSupportCanvas) {
      if (dp.width == window.innerWidth &&
        dp.height == window.innerHeight) {
        return
      }
      dp.resize()
    }
  }, 100)


  window.dpDblClick = function () {
    // //console.log('双击之后值--->' + dp.playMode);
    // if (dp.playMode === 'live') {
    //     //console.log('进入全屏--->' + dp.playMode);
    //     if (window.navigator.userAgent.indexOf('MSIE ') != -1) {
    //         Utils.pmToParent({
    //             action: 'dpdblclick_from_dp'
    //         });
    //         return;
    //     }
    //     var currentParentElement = document.getElementById('dp');
    //     enterFullscreen(currentParentElement);
    //
    // } else {
    //     Utils.pmToParent({
    //         action: 'dpdblclick_from_dp'
    //     });
    // }
  }

  // var isfull = false;
  // //解决postMessage 在firfox QQ ie等浏览器下不全屏问题
  // function enterFullscreen(ele) {//进入全屏
  //     if (isfull) {
  //         if (document.exitFullscreen) {
  //             isfull = false;
  //             document.exitFullscreen();
  //         } else if (document.msExitFullscreen) {
  //             isfull = false;
  //             document.msExitFullscreen();
  //         } else if (document.mozCancelFullScreen) {
  //             isfull = false;
  //             document.mozCancelFullScreen();


  //         } else if (document.webkitExitFullscreen) {
  //             isfull = false;
  //             document.webkitExitFullscreen();
  //         }
  //     } else {
  //         if (ele.requestFullscreen) {
  //             isfull = true;
  //             ele.requestFullscreen();
  //         } else if (ele.mozRequestFullScreen) {
  //             isfull = true;
  //             ele.mozRequestFullScreen();
  //         } else if (ele.msRequestFullscreen) {
  //             isfull = true;
  //             ele.msRequestFullscreen();
  //         } else if (ele.webkitRequestFullscreen) {
  //             isfull = true;
  //             ele.webkitRequestFullScreen();
  //         }
  //     }
  // }


})(window, undefined)
