class_name Cursor
extends Sprite2D
## The mouse pointer (DIV: process Cursor, graph 10 / 11 "MouseOpen" when a lemming is within reach).
## The OS pointer is hidden; the sprite follows the mouse every rendered frame.

var near_lemming := false
var override_position: Variant = null  # debug: fixed position instead of the real mouse


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	centered = true  # graphics 10/11 have no control point -> centre


func _process(_delta: float) -> void:
	texture = Gfx.tex(11 if near_lemming else 10)
	if override_position != null:
		position = override_position
	else:
		position = get_viewport().get_mouse_position().floor()
