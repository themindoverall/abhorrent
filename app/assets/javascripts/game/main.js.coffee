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
		@dialog = new Game.UI.DialogueBox('It\'s just a line break,\nBro!!', 640)
		@player = new Game.Player(x:110, y:120, anchor: "center")

	update: () ->
		elapsed = jaws.game_loop.tick_duration * 0.001
		@player.update(elapsed)
	draw: () ->
		jaws.clear()
		@player.draw()
		tmp = @canvas.width
		@ctx.clearRect(0,0,@canvas.width,@canvas.height)
		@ctx.drawImage(jaws.canvas, 0, 0, @canvas.width, @canvas.height)
		@dialog.draw({x: 0, y:jaws.height - 100 - 10}, @ctx)
