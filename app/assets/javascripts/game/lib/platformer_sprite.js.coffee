PPM = 16
GRAVITY = 9.8 * PPM

Game.Platformer = {}

class Game.Platformer.State
	constructor: (@sprite) ->
	enter: () ->
	execute: (elapsed) ->
	exit: () ->

class Game.Platformer.GroundState extends Game.Platformer.State
class Game.Platformer.AirState extends Game.Platformer.State
class Game.Platformer.JumpState extends Game.Platformer.State
class Game.Platformer.WallrideState extends Game.Platformer.State
class Game.Platformer.WalljumpState extends Game.Platformer.State

class Game.Platformer.Sprite extends jaws.Sprite
	constructor: () ->
		super
		@hasGravity = true
		@vx = 0
		@vy = 0
		this.setupStates()
		this.setState('air')
	setupStates: () ->
		@states =
			ground: new Game.Platformer.GroundState(this)
			air: new Game.Platformer.AirState(this)
			jump: new Game.Platformer.JumpState(this)
			wallride: new Game.Platformer.WallrideState(this)
			walljump: new Game.Platformer.WalljumpState(this)
	update: (elapsed) ->
		if @hasGravity
			@vy += GRAVITY * elapsed
		@x += @vx * elapsed
		@y += @vy * elapsed
	setState: (state) ->
		return if state == null or state == @state
		
		@stateObject.exit() if @state
		@state = state
		@stateObject = @states[state]
		@stateObject.enter()
