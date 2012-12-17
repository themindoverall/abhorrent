class Game.UI.Healthbar extends Game.UI.Box
	constructor: (@player) ->
		super
	getMaxSize: () ->
		[300, 16]
	draw: (rect, ctx) ->
		ctx.strokeStyle = '#fff'
		ctx.strokeRect(rect.x, rect.y, rect.w, rect.h)
		ctx.fillStyle = '#fff'
		ctx.fillRect(rect.x, rect.y, rect.w * (@player.health / @player.maxHealth), rect.h)