#= require ./box
#= require ./fonts

class Game.UI.DialogueBox extends Game.UI.Box
  @ALIGN:
    LEFT: 0
    RIGHT: 1
    CENTER: 2
  constructor: (text, width) ->
    @lineHeight = 30
    @border = {width: width, height: 10000} 
    @align = DialogueBox.ALIGN.LEFT
    @maxSize = [@border.width, @border.height]
    this._loadStyles()
    this.setText(text)
    @cached = document.createElement('CANVAS')
    @cached.setAttribute('width', @border.width)
    @cached.setAttribute('height', @border.height)
    ctx = @cached.getContext('2d')
    this.drawBox({x: 0, y: 0, width: @border.width, height: @border.height}, ctx)
  draw: (rect, ctx) ->
    ctx.drawImage(@cached, rect.x, rect.y, @border.width, @border.height)
  drawBox: (rect, ctx) ->
    x = rect.x
    y = rect.y
    #ctx.drawImage(@border, x, y)
    ox = Math.floor(x) + 10
    oy = Math.floor(y) + 5
    x = ox
    y = oy

    """
        if @align is DialogueBox.ALIGN.RIGHT or @align is DialogueBox.ALIGN.CENTER
          width = 0
          for i in [0..@text.length-1]
            c = @text.charCodeAt(i)
            width += @widthMap[c - @firstChar] + 1
          x -= if @align is DialogueBox.ALIGN.RIGHT then width * 0.5 else width
    """
    stack = ['default']
    for bit in @compiled
      if bit.style?
        stack.unshift(bit.style)
      else if bit.pop?
        stack.shift()
      else
        words = bit.split(' ')
        f = true
        for w in words
          if f
            f = false
            if w is ''
              continue
          else
            w = ' ' + w
          wwidth = @styles[stack[0]].widthForString(w)
          if x - ox + wwidth > @border.width - (10 * 2)
            x = ox
            y += @lineHeight
          for i in [0..w.length-1]
            c = w.charCodeAt(i)
            if c is 10
              x = ox
              y += @lineHeight
            if c isnt 10
              x += @styles[stack[0]].drawChar(ctx, c, x, y)

  setText: (text) ->
    @text = text
    @compiled = this._compileText(text)
  _loadStyles: () ->
    font = new Game.UI.Font('fonts/secombe-20.font.png', '#fff', -10)
    @styles =
      default: font
      player: font.atColor('#976A97')
      ###
      header: new Game.UI.Font('fonts/museoslab700.font.png', '#bbb', 2)
      em: new Game.UI.Font('fonts/museoslab900.font.png', '#fff', 2)
      place: new Game.UI.Font('fonts/museoslab700.font.png', '#94ff90', 2)
      item: new Game.UI.Font('fonts/museoslab700.font.png', '#81cffa', 2)
      person: new Game.UI.Font('fonts/museoslab700.font.png', '#bf88ff', 2)
      idea: new Game.UI.Font('fonts/museoslab700.font.png', '#fff38b', 2)
      enemy: new Game.UI.Font('fonts/museoslab700.font.png', '#ee878c', 2)
      event: new Game.UI.Font('fonts/museoslab700.font.png', '#ffa957', 2)
      ###

  _compileText: (text) ->
    result = []
    $tree = $.parseXML('<text>' + text + '</text>')
    parsify = (nodes) ->
      $.each(nodes, (idx, ele) ->
        if ele.tagName?
          $node = $(this)
          if ele.tagName is 's'
            result.push({style: $node.attr('class')})
            parsify(ele.childNodes)
            result.push({pop:true})
        else
          result.push(ele.data)
      )
      1
    parsify($tree.childNodes[0].childNodes)
    return result
