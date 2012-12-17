class Game.Objects.Swordhero extends Game.Platformer.Sprite
	stats:
		moveSpeed: 198
		jumpSpeed: 200
		jumpTime: 0.275
		airSpeed: 240
		airAgility: 480
		airDrag: 75
		wallrideSpeed: 25
		wallJumpSpeed: 100
		wallJumpWindow: 0.3
		fallSpeed: 100
	constructor: () ->
		super

		@animObject = new jaws.Animation(
			sprite_sheet: "swordhero.png"
			frame_size: [16,16]
			frame_duration: 100
			orientation: 'right'
		)

		@anims =
			idle: @animObject.slice(0, 1)
			run: @animObject.slice(1, 3)
			jump: @animObject.slice(0, 1)
			air: @animObject.slice(3,4)
			wallride: @animObject.slice(0,1)
			shoot: @animObject.slice(1,3)
			knockout: @animObject.slice(0,1)
		@anim = 'idle'
	update: (elapsed) ->
		super
		this.setImage(@anims[@anim].next())