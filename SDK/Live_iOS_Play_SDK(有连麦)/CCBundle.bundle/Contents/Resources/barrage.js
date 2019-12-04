/***
 *弹幕插件
 * Bullet plugin by niuq 2018-08-22;
 * v 0.0.1
 *{'type':'text','content':'ssss','css':{'font':'微软雅黑','size':'12','color':'#000000'}}
 * {'type':'image','src':'img/1.png','css':{'width':100px,'height':100px}}
 *
 * ********/
var checkValue = {
  checkValueIsNull: function (v) {
    return v == null || v == 'undefined' || v == '' || v == undefined
  }
}
var Bullet = function () {
  var info
  var _this = this
  var timeInter = -1
  var xpos = 0
  var ypos = 0

  function getSpeed() {
    var speed = (xpos + _this.node.clientWidth) / _this.moveTime
    var speed2 = Math.floor(speed / 30)
    return speed2
  }
  this.hideNode = function () {
    if (typeof _this.node != 'undefined') {
      _this.node.className = ''
      _this.node.style.display = 'none'
      _this.container.removeChild(_this.node)
    }
  }

  function animateEnd() {
    _this.hideNode()
  }

  this.setPosition = function (x, y) {
    if (typeof _this.node == 'undefined') return
    _this.node = document.getElementById('bullet_' + _this.index)
    if (checkValue.checkValueIsNull(_this.node)) return
    _this.x(x)
    _this.y(y)
    _this.node.className = 'bullet active'
    if (document.attachEvent) {
      _this.node.attachEvent('webkitTransitionEnd', animateEnd)
      _this.node.attachEvent('transitionEnd', animateEnd)
      _this.node.attachEvent('mozTransition', animateEnd)
      _this.node.attachEvent('msTransitionEnd', animateEnd)
      _this.node.attachEvent('oTransitionEnd', animateEnd)
    } else {
      _this.node.addEventListener('webkitTransitionEnd', animateEnd)
      _this.node.addEventListener('transitionEnd', animateEnd)
      _this.node.addEventListener('mozTransition', animateEnd)
      _this.node.addEventListener('msTransitionEnd', animateEnd)
      _this.node.addEventListener('oTransitionEnd', animateEnd)

    }
  }
  this.x = function (x) {
    xpos = x
    //_this.node.style.left =x+'px';
  }
  this.y = function (y) {
    ypos = y
    _this.node.style.top = y + 'px'
  }
  this.width = function () {
    return _this.node.clientWidth
  }
  this.height = function () {
    return _this.node.clientHeight + 5
  }
  this.isRightAdd = function () {
    if (checkValue.checkValueIsNull(_this.node)) return false
    var r = (_this.node.offsetLeft + _this.width()) <= xpos
    return r
  }


  //设置Css
  function setCss(n) {
    n.className = 'bullet'
  }

  function showEm(str) {
    str = str.replace(/\</g, '&lt;')
    str = str.replace(/\>/g, '&gt;')
    str = str.replace(/\n/g, '<br/>')
    str = str.replace(/\[em_([0-9]*)\]/g, '<img src="//static.csslcloud.net/img/em_mobile/$1.gif" border="0" />')
    str = str.replace(/\[em2_([0-9]*)\]/g, '<img src="//static.csslcloud.net/img/em2_mobile/$1.png" border="0" />')
    str = str.replace(/\[uri_(\S{10,200})\]/g, '<a target="_blank" style="color: #2f53ff" href="$1">$1</a>')
    return str
  }

  //创建一个文本弹幕
  function textModel() {
    var div = document.createElement('div')
    var spanCss = info.css || {'color': '#000000', font: 'Arial', size: 16}
    div.innerHTML = '<span style="' + 'color:' + spanCss.color + ';font-family: ' + spanCss.font + ';font-size: ' + spanCss.size + ';"   >' + showEm(info.content || '') + '</span>'
    div.id = 'bullet_' + _this.index
    setCss(div)
    _this.container.appendChild(div)
    return div
  }

  //创建一个图像的弹幕
  function imageModel() {
    var img = document.createElement('img')
    img.src = info.src
    img.id = 'bullet_' + _this.index
    setCss(img)
    _this.container.appendChild(img)
    return img
  }

  function createModel() {
    switch (info.type) {
      case 'text':
        textModel()
        break
      case 'image':
        imageModel()
        break
    }
    _this.node = document.getElementById('bullet_' + _this.index)
  }

  this.init = function (data, container, i) {
    info = data
    _this.container = container
    this.index = i
    createModel()

  }
}

var BulletContainer = function () {
  var container
  var cacheList = []//缓存数组
  var useList = []
  var timeintervalId = -1
  var _this = this
  var moveInterval = -1//弹幕移动定时器
  var index = 0
  var totalBulletIndex = 0
  var lineList = []
  var ll = 4
  var style
  this.init = function (l) {
    container = document.getElementById('bulletContainer')
    if (typeof container == 'undefined' || typeof container == 'null') return
    if (l) {
      ll = l
    }
    for (var i = 0; i < ll; i++) {
      lineList.push([])
    }

    cacheList = []
    useList = []
    timeintervalId = -1
    this.startToRun()
    startToShow()//开始显示弹幕
    creatStyle()//创建CSS文档;
    appendStyle(getCss())//添加样式;
  }

  function getCss() {
    var css = '.bullet{' +
      'margin:0px;' +
      'padding:0px;' +
      'position:absolute;' +
      'left:' + _this.clienW + 'px;' +
      'transition:left 10s;' +

      'white-space: nowrap;' +
      '-webkit-transition: left 10s linear 0s;' +
      '-moz-transition: left 10s linear 0s;' +
      '-ms-transition: left 10s linear 0s;' +
      '-o-transition: left 10s linear 0s;' +
      '}\n' +
      '.active{' +
      'left:-200px;' +
      '}'
    return css
  }
   this.close = function() {
    if (moveInterval != -1) {
      clearInterval(moveInterval)
    }
    if (timeintervalId != -1) {
      clearInterval(timeintervalId)
    }
    cacheList = []
    useList = []
    container.style.display = 'none'

  }
  //添加Css 样式
  function creatStyle() {
    style = document.createElement('style')
    var head = document.head || document.getElementsByTagName('head')[0]
    style.type = 'text/css'
    head.appendChild(style)
  }

  function appendStyle(cssText) {
    if (typeof style == 'undefined') return
    if (style.stylesheet) {
      function addCSS() {
        try {
          style.stylesheet.cssText = cssText
        } catch (e) {
          alert('css添加过多' + e)
        }
      }

      if (style.styleSheet.disabled) {
        setTimeout(addCSS, 10)
      } else {
        addCSS()
      }
    } else {
      var textNode = document.createTextNode(cssText)
      style.appendChild(textNode)
    }

  }
  //存放如的数组;
  this.push = function (val) {
    if (cacheList.length > 5000) return
    if (checkValue.checkValueIsNull(val.type)) return
    cacheList.push(val)

  }
  this.startToRun = function () {
    if (!container) {
      return
    }
    container.style.display = 'block'

    function getList() {
      if (cacheList.length >= 10) {
        useList = cacheList.slice(0, 10)
        cacheList.splice(0, 10)
      } else {
        useList = cacheList.slice(0, cacheList.length)
        cacheList.splice(0, cacheList.length)

      }

      return useList
    }
    this.clienW = container.offsetWidth
    this.clienH = container.offsetWidth
    timeintervalId = setInterval(function () {
      useList = getList()
    }, 1000)

  }

  function chooseLine(_bullet) {
    var curentIdex = 0
    var isAdd = false
    for (var i = 0; i < ll; i++) {
      var liLen = lineList[i].length
      if (liLen == 0) {
        if (typeof _bullet != 'undefined') {
          lineList[i].push(_bullet)
          curentIdex = i
        }
        isAdd = true
        break
      } else {
        var node = lineList[i][liLen - 1]
        if (node.isRightAdd()) {
          if (typeof _bullet != 'undefined') {
            lineList[i].push(_bullet)
            curentIdex = i
            lineList[i].shift()
          }
          isAdd = true
          break
        }
      }

    }
    if (isAdd)
      return curentIdex
    return isAdd
  }

  function creatBullet(da) {
    var bullet = new Bullet()
    bullet.init(da, container, totalBulletIndex)
    var llindex = chooseLine(bullet)
    //console.log('当前宽度是->'+_this.clienW);
    bullet.setPosition(_this.clienW, bullet.height() * llindex)
    index = llindex
    totalBulletIndex += 1
    // console.log('当前的当初-->' +cacheList.length);
  }



  function startToShow() {
    if (moveInterval != -1) return
    moveInterval = setInterval(function () {
      if (useList.length < 1) return
      var result = chooseLine().toString()
      if (result == 'false') {
        return
      }
      var obj = useList.shift()
      //console.log('当前对象的长度-->' +cacheList.length)
      creatBullet(obj)
    }, 30)
  }


  //获取容器宽
  function getBoxW() {
    return container.clientWidth
  }

  //获取容器高
  function getBoxH() {
    return container.clientHeight
  }

}
