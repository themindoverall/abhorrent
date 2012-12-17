class Game.VictoryScreen
	constructor: () ->
		@canvas = $('canvas#game').get(0)
		@ctx = @canvas.getContext('2d')
		@ctx.imageSmoothingEnabled = false
		@ctx.mozImageSmoothingEnabled = false
		@ctx.webkitImageSmoothingEnabled = false

		@ss = new jaws.SpriteSheet(image: 'villain.png', frame_size: [16,16], scale_image: 4, orientation: 'right')
		@sprite = new jaws.Sprite(image: @ss.frames[9], x: 30, y: 20)
		console.log @ss, @sprite

		@dialog = new Game.UI.DialogueBox('The End', {x: 280, y: 170}, 640)
	update: () ->
	draw: () ->
		jaws.clear()
		@sprite.draw()
		@ctx.clearRect(0,0,@canvas.width,@canvas.height)
		@ctx.drawImage(jaws.canvas, 0, 0, @canvas.width, @canvas.height)
		@dialog.draw(@ctx)
