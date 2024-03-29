class Game.LevelController
	constructor: (@session, @level) ->
	start: () ->
	update: (elapsed) ->

Game.LevelControllers = {}
Game.Objects = {}

class Game.Level
	constructor: (@session, @map) ->
		options =
			cell_size: [16, 16]
			size: [@map.width, @map.height]
			orientation: 'right'

		@layers = []
		tilesets = []

		getFrame = (gid) ->
			for i in tilesets
				if gid >= i.firstgid and gid < i.firstgid + i.sheet.frames.length
					return i.sheet.frames[gid - i.firstgid]

		for ts in @map.tilesets
			if ts.properties.load == 'false'
				continue
			spritesheet = new jaws.SpriteSheet(image: ts.image, orientation: 'right', frame_size: [ts.tilewidth, ts.tileheight])
			tilesets.push(sheet: spritesheet, firstgid: ts.firstgid)
		
		for l in @map.layers
			if l.type == 'objectgroup'
				this.addObjects(l)
				continue
			layer = new jaws.TileMap(options)
			tiles = new jaws.SpriteList()
			i = 0
			collision = l.name == 'Collision'
			for d in l.data
				if d > 0
					y = Math.floor(i / @map.width)
					x = i - (y * @map.width)
					if collision
						t = new jaws.Rect(x * 16, y * 16, 16, 16)
						layer.push(t)
					else
						t = new jaws.Sprite(image: getFrame(d), x: x * 16, y: y * 16)
						tiles.push(t)
				i++
			if collision
				@collisionMap = layer
			else
				layer.push(tiles)
				@layers.push(layer)
		if @map.properties.controller
			@controller = new Game.LevelControllers[@map.properties.controller](@session, this)
	start: () ->
		@controller.start() if @controller
	update: (elapsed) ->
		@controller.update(elapsed) if @controller
	addObjects: (group) ->
		for o in group.objects
			clazz = Game.Objects[o.type]
			obj = new clazz(@session, {x: o.x, y: o.y})
			@session.addObject(o.name, obj)
	draw: (viewport) ->
		for l in @layers
			viewport.drawTileMap(l)
