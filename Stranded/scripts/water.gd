extends Node2D
## DIV: scroll background (graphic 55, a 20x20 water tile) drifting via WaterMove:
## x1 += 2 and y1 += 1 every two frames, i.e. 24 px/s right and 12 px/s down at 24 fps.

const DRIFT := Vector2(2.0, 1.0) / 2.0 * 24.0
const TILE := 20
const SIZE := Vector2(800 + 20, 600 + 20)

var _texture: Texture2D = preload("res://assets/fpg/stranded/55.png")
var _offset := Vector2.ZERO


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	_offset += DRIFT * delta
	_offset = Vector2(fposmod(_offset.x, TILE), fposmod(_offset.y, TILE))
	position = -_offset.floor()


func _draw() -> void:
	draw_texture_rect(_texture, Rect2(Vector2.ZERO, SIZE), true)
