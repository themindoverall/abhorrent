class KnockOutState extends Game.Platformer.State
	enter: () ->
		@sprite.hasGravity = true
		@sprite.anim = 'knockout'
		@timer = 1
		@sprite.vy = -150 - (Math.random() * 100)
		@sprite.vx = -200 + Math.random() * 400
		@sprite.sensors.bottom.enabled = true
		@sprite.health -= 1
	exit: () ->
		@sprite.sensors.bottom.enabled = false
	execute: (elapsed) ->
		@sprite.checkWalls()
		@timer -= elapsed
		if @timer <= 0
			return 'air'

		if @sprite.sensors.bottom.hit && @sprite.vy > 0
			return 'ground'
		null

class Game.Objects.Player extends Game.Platformer.Sprite
	stats:
		moveSpeed: 108
		jumpSpeed: 175
		jumpTime: 0.275
		airSpeed: 128
		airAgility: 480
		airDrag: 150
		wallrideSpeed: 16
		wallJumpSpeed: 140
		wallJumpWindow: 0.3
		fallSpeed: 200
	constructor: () ->
		super
		@health = 5
		@maxHealth = 5
		@healthbar = new Game.UI.Healthbar(this)
		@session.ui.add(@healthbar, @session.ui.LocDefs.top)

		@animObject = new jaws.Animation(
			sprite_sheet: "villain.png"
			frame_size: [16,16]
			frame_duration: 100
			orientation: 'right'
		)

		@anims =
			idle: @animObject.slice(0, 1)
			run: @animObject.slice(1, 4)
			jump: @animObject.slice(4,5)
			air: @animObject.slice(5,6)
			wallride: @animObject.slice(6,7)
			shoot: @animObject.slice(7,8)
			knockout: @animObject.slice(9,10)
		@anims.run.bounce = true
		@anim = 'idle'
	setupStates: () ->
		super
		@states.knockout = new KnockOutState(this)
	freeze: (save) ->
	defrost: (save) ->

	update: (elapsed) ->
		super
		this.setImage(@anims[@anim].next())
		cols = jaws.collideOneWithMany(this, @session.enemyGameObjects(this))
		if cols.length > 0
			this.setState('knockout')