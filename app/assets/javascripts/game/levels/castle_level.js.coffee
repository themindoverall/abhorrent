class Game.LevelControllers.CastleLevel extends Game.LevelController
	start: () ->
		@player = @session.get('player')
		#pc = new Game.PlayerController()
		#pc.control(@player)
		@pc = new Game.CutsceneController('player')
		@pc.control(@player)

		@hero = @session.get('swordhero1')
		@hc = new Game.CutsceneController('hero')
		@hc.control(@hero)
		@hc.move(-1, 0.05).stand()

		@pc.move(-1, 5.50)
			.doJump(0.05)
			.stand(0.3)
			.move(1, 0.1)
			.stand(0.5)
			.say('Well what do we have here?', {x: 100, y: 20}, 3)
			.and(@hc)
			.move(-1, 0.05)
			.stand()
			.say('I will defeat you, evil wretch!', {x: 200, y: 45}, 3)
			.and(@pc)
			.say('Hahaha... we shall see.', {x: 100, y: 70}, 3)
			.then(=>
				pc = new Game.PlayerController()
				pc.control(@player)
				ai = new Game.DumbAIController(@player)
				ai.control(@hero)
			)
	update: (elapsed) ->
		if @player.health <= 0
			jaws.switchGameState(Game.VictoryScreen)