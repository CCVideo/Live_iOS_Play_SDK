/**
 * dp
 *
 * marquee plugin  by niuq  2018 - 08 -08
 *v 0.0.1
 {
   name:"11",
  type:"text",
  text:"helloworld",
  font:"微软雅黑",
  size:20,
  color:"0xFF0000",
  loopTime:30000,
 actions:[
               {
                    index:0,
                    duration:30000,
                    start:{
                            xpos:0.112,
                            ypos:0.123,
                            alpha:1
                     },
                    end:{
                             xpos:0.812,
                             ypos:0.823,
                             alpha:1
                      }
               }
      ]
}
 * **/

var checkValue = {
  checkValueIsNull: function (v) {
    return v == null || v == 'undefined' || v == '' || v == undefined
  }
}
var marqueeIndex = 0
var MarqueePlugin = function () {

  this.container = null
  this._dom = null
  this.name = ''
  this.boxW = 400
  this.boxH = 300
  this.timer = -1
  this.id = 'marquee_' + marqueeIndex

  this.init = function (_d) {
    this._info = _d
    var type = this._info.type || 'text'
    this.container = document.getElementById('marquee')
    if (typeof this.container == 'undefined') return

    this.name = this._info.name
    this.lastStart = null
    switch (type) {
      case 'image':
        this.createImage(this._info.image_url, this._info.width, this._info.height)
        break
      case 'text':
        this.createText(this._info)
        break
    }
    if (!!this._info.action && this._info.action.length > 0) { //补齐移动轨迹走完时能够走返回路线
      var endObj =
        {
          index: this._info.action.length,
          duration: 5000,
          start: {
            xpos: this._info.action[this._info.action.length - 1].end.xpos,
            ypos: this._info.action[this._info.action.length - 1].end.ypos,
            alpha: 1
          },
          end: {
            xpos: this._info.action[0].start.xpos,
            ypos: this._info.action[0].start.ypos,
            alpha: 1
          }
        }
      this._info.action.push(endObj)
    }
    if (!this._dom) {
      this._dom = document.getElementById(this.id)
      if (this._dom) {
        this.startTimerToRun()

      }
    }
    marqueeIndex++
  }

  // 开始计时 设置初始状态
  this.startTimerToRun = function () {
    var _this = this
    this.lastStart = null
    var currentStyle = _this.tweenType()
    this.container.style.display = 'block'
    var index = 0

    //解析数据且设置初始位置 t=='s'时表示设置开始位置
    function paraseInfo(val, t) {
      var startposL = val.xpos * _this.boxW
      var startpostT = val.ypos * _this.boxH
      if (val.xpos > 1 || val.ypos > 1) {
        startposL = val.xpos
        startpostT = val.ypos
      }

      var startAl = val.alpha
      if (t == 's') {
        setDomPostion(startposL, startpostT, startAl)
      }
      return {l: startposL, t: startpostT, a: startAl}
    }

    //设置要移动dom 元素的位置
    function setDomPostion(l, t, a) {

      _this._dom.style.left = l + 'px'

      _this._dom.style.top = t + 'px'

      _this._dom.style.opacity = a
    }

    //获取随机结束位置
    function getRandomEndpos(s, end) {
      var value = Math.round(Math.random() * end)
      while (Math.abs(value - s) < 50) {
        value = Math.round(Math.random() * end)
      }
      return value
    }

    function resetData(ind) {
      //var index = _this._info.actions[0].index;
      var start
      var end
      var during
      var startInfo
      var endInfo
      _this.boxW = _this.container.offsetWidth - _this._dom.offsetWidth
      _this.boxH = _this.container.offsetHeight - _this._dom.offsetHeight
      //console.log('this._dom.offsetWidth' + _this.container.offsetHeight, _this._dom.offsetHeight);
      if (!!_this._info.action && _this._info.action.length > 0) {

        start = _this._info.action[ind].start
        end = _this._info.action[ind].end
        during = _this._info.action[ind].duration
        //start = {xpos: xpos , ypos: ypos , alpha: 1};
        startInfo = paraseInfo(start, 's')
        endInfo = paraseInfo(end)
      } else {
        if (this.lastStart == null) {
          var xpos = Math.random() * _this.boxW
          var ypos = Math.random() * _this.boxH
          start = {xpos: xpos, ypos: ypos, alpha: 1}
          this.lastStart = start
        }
        //
        startInfo = paraseInfo(this.lastStart, 's')
        var expos = getRandomEndpos(xpos, _this.boxW)
        var eypos = getRandomEndpos(ypos, _this.boxH)
        end = {xpos: expos, ypos: eypos, alpha: 1}
        this.lastStart = end
        during = Math.ceil(Math.random() * 5) * 1000
        endInfo = paraseInfo(end)
      }
      startTimer(startInfo, endInfo, during)
    }

    function startTimer(start, end, during) {
      var timerIndex = 0
      _this.clearTimer()
      _this.timer = setInterval(function () {
        if (timerIndex > during) {
          if (!!_this._info.action && _this._info.action.length > 0) {
            if (index >= _this._info.action.length - 1) {
              _this.clearTimer()
              index = 0
            }
            else {
              index += 1
            }
          }
          timerIndex = 0
          resetData(index)
          return
        }
        timerIndex += 10
        //console.log('当前的l123123123的值-->' +s.l,'-top:'+e.l,d);
        var left = currentStyle(timerIndex, start.l, end.l, during)
        var top = currentStyle(timerIndex, start.t, end.t, during)
        var alpha = currentStyle(timerIndex, start.a, end.a, during)
        setDomPostion(left, top, alpha)
      }, 10)
    }

    resetData(index)
  }
  this.clearTimer = function () {
    if (this.timer != -1) {
      clearInterval(this.timer)
    }

  }
  this.close = function () {
    this.clearTimer()
    this.container.style.display = 'none'
  }

  //创建一个image样式的跑马灯
  this.createImage = function (url, w, h) {
    var img = document.createElement('img')
    img.src = url
    img.width = w
    img.height = h
    img.id = this.id
    img.style.position = 'absolute;'
    img.style.padding = '0'
    img.style.margin = '0'
    img.style.display = 'inline'
    this.container.appendChild(img)
  }
  //创建一个text样式的跑马灯
  this.createText = function (data) {
    var p = document.createElement('span')
    p.id = this.id
    p.innerHTML = data.text.content || 'null'
    p.style['font-family'] = data.text.font || '微软雅黑'
    p.style['font-size'] = (!!data.text.font_size ? data.text.font_size : 15) + 'px'
    p.style['color'] = (data.text.color.replace('0x', '#')) || '#000000'
    p.style.position = 'absolute'
    p.style['white-space'] = 'nowrap'
    p.style.padding = '0'
    p.style.margin = '0'
    p.style.display = 'inline'
    this.container.appendChild(p)
  }
  this.tweenType = function (ty) {
    return function tween(t, s, e, d) {
      return (t / d) * (e - s) + s
    }
  }
}
