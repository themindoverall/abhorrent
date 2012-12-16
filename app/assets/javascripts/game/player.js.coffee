class Game.Player extends Game.Platformer.Sprite
	constructor: () ->
		super
		@anim = new jaws.Animation(
			sprite_sheet: "villain.png"
			frame_size: [16,16]
			frame_duration: 100
			orientation: 'right'
		)

		@anims =
			idle: @anim.slice(0, 1)
			run: @anim.slice(1, 4)
			jump: @anim.slice(4,1)
			fall: @anim.slice(5,1)
			wallRide: @anim.slice(6,1)
			shoot: @anim.slice(7,1)
			knockout: @anim.slice(8,1)
		@anims.run.bounce = true
		this.setImage(@anims.run.next())
	update: (elapsed) ->
		super
		this.setImage(@anims.run.next())