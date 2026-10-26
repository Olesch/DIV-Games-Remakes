class_name PixelLabel
extends Label
## Text drawn like DIV's write() with the built-in 6x8 system font at 1:1 size: the node position is the
## DIV anchor (x, y) and `align_code` is DIV's alignment code (0 top-left, 1 top-centre, 2 top-right,
## 3 middle-left, 4 centre, 5 middle-right, 6 bottom-left, 7 bottom-centre, 8 bottom-right).

@export_range(0, 8) var align_code: int = 0

var _anchor := Vector2.ZERO


func _ready() -> void:
	add_theme_font_override(&"font", load("res://assets/fnt/system/font_bmfont.fnt"))
	add_theme_font_size_override(&"font_size", 8)
	add_theme_color_override(&"font_color", Color.WHITE)  # bitmap font, keep white
	_anchor = position
	_reposition()


func set_value(value: String) -> void:
	if value == text:
		return
	text = value
	_reposition()


func _reposition() -> void:
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (_anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5)).floor()
