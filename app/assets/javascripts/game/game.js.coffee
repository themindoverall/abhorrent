#= require_self
#= require_tree ./lib
#= require_tree .

window.Game = {
	UI: {}
	Events: {}
}

jaws.Animation.prototype.cut = (frames) ->
	new jaws.Animation(
		frame_duration: @frame_duration
		loop: @loop
		bounce: @bounce
		on_end: @on_end
		frame_direction: @frame_direction
		frames: (@frames[i] for i in frames)
	)

class Game.Session
	constructor: () ->
		@canvas = $('canvas#game').get(0)
		@ctx = @canvas.getContext('2d')
		@ctx.imageSmoothingEnabled = false
		@ctx.mozImageSmoothingEnabled = false
		@ctx.webkitImageSmoothingEnabled = false
	setup: () ->
		@ui = new Game.UI.PinBox()
		@dialogs = []

		this.reset()
		map = jaws.assets.get('castle.json')
		@level = new Game.Level(this, map)
		@viewport = new jaws.Viewport({})
		@level.start()
		for id, obj of @gameObjects
			obj.start() if obj.start

	update: () ->
		elapsed = jaws.game_loop.tick_duration * 0.001
		elapsed = Math.min(elapsed, 1/30)

		@level.update(elapsed)
		for id, obj of @gameObjects
			obj.update(elapsed)
		@ui.update({x: 0, y: 0, w: jaws.Width, h: jaws.Height}, elapsed)
		for d in @dialogs
			d.update(elapsed)
		#@viewport.centerAround(@player)
	draw: () ->
		jaws.clear()
		@level.draw(@viewport)
		for id, obj of @gameObjects
			@viewport.draw(obj)

		tmp = @canvas.width
		@ctx.clearRect(0,0,@canvas.width,@canvas.height)
		@ctx.drawImage(jaws.canvas, 0, 0, @canvas.width, @canvas.height)
		@ui.draw({x: 0, y: 0, w: jaws.width * 2, h: jaws.height * 2}, @ctx)
		for d in @dialogs
			d.draw(@ctx) if d.visible
	addObject: (id, obj) ->
		if id
			obj.id = id
		else
			obj.id = "obj#{@nextId++}"
		@gameObjects[obj.id] = obj
	get: (id) ->
		@gameObjects[id]
	enemyGameObjects: (obj) ->
		(o for id, o of @gameObjects when obj != o)
	freeze: () ->
		save = {}
		save['game_state'] =
			nextId: @nextId
		@gameObjects.forEach (obj) ->
			obj.freeze(save) if obj.freeze
	defrost: (save) ->
		@gameObjects.deleteIf (obj) ->
			!obj.defrost
		@gameObjects.forEach (obj) ->
			obj.defrost(save)
		@nextId = save['game_state'].nextId
	reset: () ->
		@gameObjects = {}
		@nextId = 1
	say: (text, pos, duration) ->
		d = new Game.UI.DialogueBox(text, pos, 640, duration)
		@dialogs.push(d)
	collideRect: (rect) ->
		tiles = @level.collisionMap.atRect(rect)
		return false if tiles.length == 0
		tiles[0]

		
