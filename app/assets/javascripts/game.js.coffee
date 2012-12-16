//= require jquery
//= require jaws
//= require game/main

$ ->
  jaws.unpack()
  jaws.assets.root = "assets/"
  jaws.assets.add([
      "fonts/secombe-20.font.png",
      "castleset.png",
      "darkforce.png",
      "hellset.png",
      "shadowoverlay.png",
      "swordhero.png",
      "villain.png"
  ])

  innerCanvas = document.createElement('CANVAS')
  innerCanvas.width = 320
  innerCanvas.height = 160
  jaws.start(Game.Session, {canvas: innerCanvas} )