//= require jquery
//= require jaws
//= require game/game

$ ->
  jaws.unpack()
  jaws.preventDefaultKeys( ["space", "up", "down", "left", "right", "z", "x"] )
  jaws.assets.root = "assets/"
  jaws.assets.add([
      "fonts/secombe-20.font.png",
      "castleset.png",
      "darkforce.png",
      "hellset.png",
      "shadowoverlay.png",
      "swordhero.png",
      "villain.png",
      "castle.json"
  ])

  innerCanvas = document.createElement('CANVAS')
  innerCanvas.width = 320
  innerCanvas.height = 160
  jaws.start(Game.Session, {canvas: innerCanvas} )