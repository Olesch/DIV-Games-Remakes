class_name PixelLabel
extends Label
## Text drawn like DIV write(): the node's design-time position is the DIV anchor (x, y) and
## `align_code` is DIV's alignment code (0 top-left, 2 top-right, 8 bottom-right ...).
## Uses the converted digit font (DIV font 1) at 1:1 size.

const FONT_PATH := "res://assets/fnt/ballkill/font_bmfont.fnt"
const LINE_HEIGHT := 41

@export_range(0, 8) var align_code: int = 0

var _anchor := Vector2.ZERO


func _ready() -> void:
	add_theme_font_override(&"font", load(FONT_PATH))
	add_theme_font_size_override(&"font_size", LINE_HEIGHT)
	add_theme_color_override(&"font_color", Color.WHITE)  # multicolour bitmap font
	_anchor = position
	_reposition()


func set_value(value: int) -> void:
	text = str(value)
	_reposition()


func _reposition() -> void:
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (_anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5)).floor()
