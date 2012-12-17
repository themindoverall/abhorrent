class Game.CutsceneController extends Game.Platformer.Controller
	constructor: (@voice) ->
		super
		@queue = []
		@action = null
		@actionTime = 0
		@paused = false
	update: (elapsed) ->
		return if @paused
		if !@action
			if @queue.length > 0
				@action = @queue.shift()
				@actionTime = 0
			else
				return

		switch @action.type
			when 'stand'
				@jump = false
				@movement.x = 0
			when 'move'
				@movement.x = @action.dir
			when 'jump'
				@jump = 'new'
			when 'say'
				if !@action.done
					@sprite.session.say("<s class='#{@voice}'>#{@action.text}</s>", @action.pos, @action.time)
					@action.done = true
			when 'pause'
				@paused = true
				@action = null
			when 'cb'
				@action.cb()
				@action = null
		if @action and @actionTime > @action.time
			@action = null
		@actionTime += elapsed
	doAction: (action) ->
		@queue.push(action)
		this
	move: (dir, time) ->
		time ||= 1
		this.doAction({type: 'move', dir: dir, time: time})
	stand: (time) ->
		time ||= 1
		this.doAction({type: 'stand', time: time})
	doJump: (time) ->
		time ||= 1
		this.doAction({type: 'jump', time: time})
	say: (text, pos, time) ->
		this.doAction({type: 'say', text: text, pos: pos, time: time})
	then: (cb) ->
		this.doAction({type: 'cb', cb: cb, time: 0})
	pause: () ->
		this.doAction({type: 'pause'})
	unpause: () ->
		this.paused = false
	and: (obj) ->
		obj.pause()
		this.then(->
			obj.unpause()
		)
		obj

class Game.PlayerController extends Game.Platformer.Controller
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

class Game.DumbAIController extends Game.Platformer.Controller
	constructor: (@player) ->
		super
		@multiplier = 1
		@lockin = false
		this.resetTimer()
	update: (elapsed) ->
		super
		@timer -= elapsed

		if @sprite.sensors.left.hit or @sprite.sensors.right.hit
			@movement.x *= -1

		if @timer <= 0
			this.resetTimer()
			@decision = Math.floor((Math.random()*7))
			switch @decision
				when 0
					@movement.x = -1
				when 1
					@movement.x = 1
				when 2
					@movement.x = 0
					@multiplier = 0.5
				when 3
					@jump = 'new'
				when 4
					@jump = false
				when 5
					@lockin = true
					@multiplier = 0.5
				when 6
					@lockin = false
					@multiplier = 0.3
		if @lockin
			if @player.y - @sprite.y < 0
				@jump = 'new'
			else
				@jump = false
			@movement.x = @player.x - @sprite.x
			if Math.abs(@movement.x) < 16
				@lockin = false
			@movement.x = @movement.x / Math.abs(@movement.x)
	resetTimer: () ->
		@timer = (0.1 + (Math.random() * 0.4)) * @multiplier
		@multiplier = 1