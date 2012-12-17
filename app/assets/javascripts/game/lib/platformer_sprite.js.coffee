PPM = 16
GRAVITY = 36.0 * PPM

Game.Platformer = {}

class Game.Platformer.State
	constructor: (@sprite) ->
	enter: () ->
	execute: (elapsed) ->
		null
	exit: () ->

class Game.Platformer.GroundState extends Game.Platformer.State
	enter: () ->
		@sprite.hasGravity = false
		@sprite.vy = 0
		@sprite.y = @sprite.sensors.bottom.hit.y
		@sprite.sensors.bottom.enabled = true
	exit: () ->
		@sprite.sensors.bottom.enabled = false
	execute: () ->
		if @sprite.controller
			@sprite.vx = @sprite.stats.moveSpeed * @sprite.controller.movement.x

			if @sprite.controller.movement.x == 0
				@sprite.anim = 'idle'
			else
				@sprite.anim = 'run'
				@sprite.flipped = @sprite.controller.movement.x < 0

			return 'jump' if @sprite.controller.jump == 'new'

		@sprite.checkWalls()

		return 'air' unless @sprite.sensors.bottom.hit
		null
class Game.Platformer.AirState extends Game.Platformer.State
	enter: () ->
		@sprite.hasGravity = true
		@sprite.anim = 'air' unless @sprite.anim == 'jump'
		@sprite.sensors.bottom.enabled = true
		@sprite.sensors.top.enabled = true
	exit: () ->
		@sprite.sensors.bottom.enabled = false
		@sprite.sensors.top.enabled = false
	execute: (elapsed) ->
		@sprite.airMovement(elapsed)

		if @sprite.anim == 'jump' and @sprite.vy > 0
			@sprite.anim = 'air'

		if @sprite.vx > 0
			@sprite.sensors.left.enabled = false
			@sprite.sensors.right.enabled = true
		else if @sprite.vx < 0
			@sprite.sensors.left.enabled = true
			@sprite.sensors.right.enabled = false

		if @sprite.vy > @sprite.stats.fallSpeed
			@sprite.vy = @sprite.stats.fallSpeed
		
		if @sprite.sensors.top.hit && @sprite.vy < 0
			@sprite.y = @sprite.sensors.top.hit.bottom + @sprite.height
			@sprite.vy = 0

		leftwallhit = @sprite.sensors.left.hit && @sprite.vx < 0
		rightwallhit = @sprite.sensors.right.hit && @sprite.vx > 0
		if @sprite.controller && (leftwallhit && @sprite.controller.movement.x < 0) || (rightwallhit && @sprite.controller.movement.x > 0)
			return 'wallride'
		else if leftwallhit || rightwallhit
			@sprite.checkWalls(elapsed)

		if @sprite.sensors.bottom.hit
			return 'ground'
		null
class Game.Platformer.JumpState extends Game.Platformer.State
	enter: () ->
		@sprite.hasGravity = false
		@sprite.vy = -@sprite.stats.jumpSpeed
		@timer = @sprite.stats.jumpTime
		@sprite.anim = 'jump'
		@sprite.sensors.top.enabled = true
	exit: () ->
		@sprite.sensors.top.enabled = false
	execute: (elapsed) ->
		@sprite.airMovement(elapsed)
		@sprite.checkWalls(elapsed)
		jump = true
		if @sprite.controller
			jump = @sprite.controller.jump
		@timer -= elapsed
		if @sprite.sensors.top.hit && @sprite.vy < 0
			@sprite.y = @sprite.sensors.top.hit.bottom + @sprite.height
			@sprite.vy = 0
			return 'air'
		if !jump or @timer <= 0
			return 'air'
		null
class Game.Platformer.WallrideState extends Game.Platformer.State
	enter: () ->
		@sprite.hasGravity = false
		@sprite.anim = 'wallride'
		@sprite.vx = 0
		@sprite.vy = @sprite.stats.wallrideSpeed
		@sprite.sensors.bottom.enabled = true
		if @sprite.sensors.left.hit
			@dir = -1
			@sensor = @sprite.sensors.left
			@sprite.flipped = true
			@sprite.x = @sprite.sensors.left.hit.right + @sprite.width * 0.5
		else
			@dir = 1
			@sensor = @sprite.sensors.right
			@sprite.flipped = false
			@sprite.x = @sprite.sensors.right.hit.x - @sprite.width * 0.5
		@timer = 0
	exit: () ->
		@sprite.sensors.bottom.enabled = false
	execute: (elapsed) ->
		if @sprite.controller
			if @sprite.controller.movement.x / @dir <= 0
				@timer += elapsed
			else
				@timer = 0
			if @sprite.controller.jump == 'new'
				return 'walljump'
			if @timer > @sprite.stats.wallJumpWindow or !@sensor.hit
				return 'air'
		if @sprite.sensors.bottom.hit
			return 'ground'
		null

class Game.Platformer.WalljumpState extends Game.Platformer.State
	enter: () ->
		@sprite.hasGravity = false
		@sprite.anim = 'jump'
		if @sprite.sensors.left.hit
			@dir = -1
		else
			@dir = 1
		@sprite.vx = -@dir * @sprite.stats.wallJumpSpeed
		@sprite.vy = -@sprite.stats.wallJumpSpeed
		@timer = @sprite.stats.jumpTime
		@sprite.anim = 'jump'
		@sprite.sensors.top.enabled = true
		@jump = true
	exit: () ->
		@sprite.sensors.top.enabled = false
	execute: (elapsed) ->
		@sprite.checkWalls(elapsed)

		@timer -= elapsed
		if @jump && @timer > 0
			@jump = @sprite.controller.jump
		else
			@sprite.vx = -@dir * @sprite.stats.wallJumpSpeed * 0.9
			@sprite.hasGravity = true

		if @sprite.sensors.top.hit
			@sprite.y = @sprite.sensors.top.hit.bottom + @sprite.height
			@sprite.vy = 0
			return 'air'

		if @sprite.vy > 0
			return 'air'
		null
class Game.Platformer.Controller
	constructor: () ->
		@movement = {x: 0, y: 0}
		@jump = false
	update: (elapsed) ->
	control: (sprite) ->
		@sprite = sprite
		sprite.controller = this

class Game.Platformer.Sensor
	constructor: (@sprite, @dir) ->
		@enabled = false
		@rect = new jaws.Rect(0,0,1,1)
		@hit = false
	update: (elapsed) ->
		@hit = false
		return unless @enabled
		rect = @rect
		timescale = Math.min(elapsed, 0.05) * 3
		vx = Math.max(timescale * @sprite.vx, 1)
		vy = Math.max(timescale * @sprite.vy, 1)
		switch @dir
			when 'left'
				rect.moveTo(@sprite.x - @sprite.width*0.5 - vx,
										@sprite.y - @sprite.height + 3)
				rect.resizeTo(vx, @sprite.height - 6)
			when 'right'
				rect.moveTo(@sprite.x + @sprite.width*0.5,
										@sprite.y - @sprite.height + 3)
				rect.resizeTo(vx, @sprite.height - 6)
			when 'top'
				rect.moveTo(@sprite.x - @sprite.width*0.5 + 3,
										@sprite.y - @sprite.height - vy)
				rect.resizeTo(@sprite.width - 6, vy)
			when 'bottom'
				rect.moveTo(@sprite.x - @sprite.width*0.5 + 3,
										@sprite.y)
				rect.resizeTo(@sprite.width - 6, vy)
		@hit = @sprite.session.collideRect(rect)

class Game.Platformer.Sprite extends jaws.Sprite
	stats:
		moveSpeed: 20
		jumpSpeed: 24
		jumpTime: 0.6
		airSpeed: 20
		airAgility: 32
		airDrag: 10
		wallrideSpeed: 16
		wallJumpSpeed: 240
		wallJumpWindow: 0.5
		fallSpeed: 100
	constructor: (@session, options) ->
		super(options)
		@hasGravity = true
		@vx = 0
		@vy = 0
		this.anchor('bottom_center')
		this.setupStates()
		this.setupSensors()
		this.setState('air')
		@anim = 'air'
	setupStates: () ->
		@states =
			ground: new Game.Platformer.GroundState(this)
			air: new Game.Platformer.AirState(this)
			jump: new Game.Platformer.JumpState(this)
			wallride: new Game.Platformer.WallrideState(this)
			walljump: new Game.Platformer.WalljumpState(this)
	setupSensors: () ->
		@sensors =
			bottom: new Game.Platformer.Sensor(this, 'bottom')
			left: new Game.Platformer.Sensor(this, 'left')
			right: new Game.Platformer.Sensor(this, 'right')
			top: new Game.Platformer.Sensor(this, 'top')
	update: (elapsed) ->
		@controller.update(elapsed) if @controller
		this.setState(@stateObject.execute(elapsed))
		for n, s of @sensors
			s.update(elapsed)
		if @hasGravity
			@vy += GRAVITY * elapsed
		this.move(@vx * elapsed, @vy * elapsed)
	setState: (state) ->
		return if state == null or state == @state or !@states[state]
		@stateObject.exit() if @state
		@state = state
		@stateObject = @states[state]
		@stateObject.enter()
	checkWalls: () ->
		if @vx > 0
			@sensors.left.enabled = false
			@sensors.right.enabled = true
		else if @vx < 0
			@sensors.left.enabled = true
			@sensors.right.enabled = false
		if @sensors.right.hit && @vx > 0
			@vx = 0
			@x = @sensors.right.hit.x - @width * 0.5
		else if @sensors.left.hit && @vx < 0
			@vx = 0
			@x = @sensors.left.hit.right + @width * 0.5
	airMovement: (elapsed) ->
		moveX = 0
		if @controller
			moveX = @stats.airAgility * @controller.movement.x
			@flipped = @controller.movement.x < 0 if @controller.movement.x != 0
		
		if moveX == 0 and @vx != 0
			lv = @vx / Math.abs(@vx)
			@vx += -lv * @stats.airDrag * elapsed
		else
			@vx += moveX * elapsed

		@vx = Math.min(Math.max(@vx, -@stats.airSpeed), @stats.airSpeed)
