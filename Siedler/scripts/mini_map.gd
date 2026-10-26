class_name MiniMap
extends TextureRect
## DIV: HelpMap / HelpMapb. The original simply shows the LogicMap graphic (one pixel per cell,
## coloured by the settler's job) inside the "Rahmen" frame in the bottom-right corner - the
## minimap is the simulation's own working memory.

@export var colony: Colony

var _image := Image.create_empty(Game.MAP_W, Game.MAP_H, false, Image.FORMAT_RGBA8)
var _texture: ImageTexture


func _ready() -> void:
	_texture = ImageTexture.create_from_image(_image)
	texture = _texture
	colony.ticked.connect(_refresh)


func _refresh() -> void:
	_image.fill(Color.TRANSPARENT)
	for i: int in colony.sprites:
		var job := colony.logic[i]
		if job != 0:
			@warning_ignore("integer_division")
			_image.set_pixel(i % Game.MAP_W, i / Game.MAP_W, Gfx.palette_color(job))
	_texture.update(_image)
