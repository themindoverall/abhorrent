class PlayerController extends Game.Platformer.Controller
	update: (elapsed) ->
		super
		right = if jaws.pressed('right') then 1 else 0
		left = if jaws.pressed('left') then 1 else 0
		@movement.x = right - left

		if jaws.pressed('z')
			if @jump
				@jump = true
			else
				@jump = 'new'
		else
			@jump = false

class Game.Player extends Game.Platformer.Sprite
	stats:
		moveSpeed: 96
		jumpSpeed: 130
		jumpTime: 0.4
		airSpeed: 96
		airAgility: 300
		airDrag: 25
		wallrideSpeed: 16
		wallJumpSpeed: 200
		wallJumpWindow: 0.3
		fallSpeed: 175
	constructor: () ->
		super
		ctrl = new PlayerController()
		ctrl.control(this)

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
			knockout: @animObject.slice(8,9)
		@anims.run.bounce = true
		@anim = 'idle'
	update: (elapsed) ->
		super
		this.setImage(@anims[@anim].next())