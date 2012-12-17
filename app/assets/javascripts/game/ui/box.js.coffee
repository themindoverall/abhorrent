class Game.UI.Box
  Game.Events.eventDispatcher(this)
  constructor: () ->
    @maxSize = [9999, 9999]
    @visible = true
  initialize: (@view) ->
    @initialized = true
  update: (rect, delta) ->
  draw: (rect, ctx) ->
  getMaxSize: () ->
    @maxSize
  claimTouch: (rect, point) ->
    return null
  loadContent: () ->
    1

class Game.UI.LayoutBox extends Game.UI.Box
  constructor: () ->
    super()
    @items = []
  initialize: (view) ->
    super(view)
    for box in @items
      box.initialize(view)
  update: (rect, delta) ->
    for box in @items
      box.update(@computeRectangle(rect, box), delta)
    1
  add: (box) ->
    @items.push(box)
    box.initialize(@view) if @initialized
  draw: (rect, ctx) ->
    for box in @items
      return if not box.visible
      box.draw(@computeRectangle(rect, box), ctx)
    1
  claimTouch: (rect, point) ->
    touchbox = null
    for i in [@items.length - 1 .. 0] by -1
      box = @items[i]
      touchbox = box.claimTouch(@computeRectangle(rect, box), point)
      break if touchbox?
    return touchbox
  computeRectangle: (rect, box) ->
    throw new Error('Unimplemented computeRectangle')

class Game.UI.PinBox extends Game.UI.LayoutBox
  LocDefs:
    top: 0b0001
    topRight: 0b0011
    right: 0b0010
    bottomRight: 0b0110
    bottom: 0b0100
    bottomLeft: 0b1100
    left: 0b1000
    topLeft: 0b1001
  constructor: () ->
    super()
    @locations = {}
    @padding = 5
    @_nextId = 1
  add: (box, loc) ->
    box._pinbox_id = @_nextId++
    super(box)
    @locations[box._pinbox_id] = loc
  computeRectangle: (rect, box) ->
    result = {}
    loc = @locations[box._pinbox_id]
    boxSize = box.getMaxSize()
    padding = @padding
    if boxSize[0] > rect.w - (padding * 2)
      result.x = rect.x + padding
      result.w = rect.w - (padding * 2) 
    else
      if (loc & @LocDefs.left) != 0
        result.x = rect.x + padding
        result.w = boxSize[0]
      else if (loc & @LocDefs.right) != 0
        result.x = rect.x + rect.w - boxSize[0] - padding
        result.w = boxSize[0]
      else
        result.x = rect.x + (rect.w - boxSize[0]) * 0.5
        result.w = boxSize[0]
    if boxSize[1] > rect.h + padding
      result.y = rect.y + padding
      result.h = rect.h - (padding * 2)
    else
      if (loc & @LocDefs.top) != 0
        result.y = rect.y + padding
        result.h = boxSize[1]
      else if (loc & @LocDefs.bottom) != 0
        result.y = rect.y + rect.h - boxSize[1] - padding
        result.h = boxSize[1]
      else
        console.log loc
        result.y = rect.y + (rect.y - boxSize[1]) * 0.5
        result.h = boxSize[1]
    #console.log 'computed ', result
    result.x += 0.5
    result.y += 0.5
    return result
