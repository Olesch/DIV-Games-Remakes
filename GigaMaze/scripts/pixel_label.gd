class_name PixelLabel
extends Label
## Text drawn like DIV write() with the converted Gigamaze font (DIV font 1, line height 12).
## `anchor` is the DIV x,y and `align_code` the DIV alignment (3 middle-left, 5 middle-right ...).

const FONT_PATH := "res://assets/fnt/gigamaze/font_bmfont.fnt"
const LINE_HEIGHT := 12

var anchor := Vector2.ZERO
var align_code := 0


func _ready() -> void:
	add_theme_font_override(&"font", load(FONT_PATH))
	add_theme_font_size_override(&"font_size", LINE_HEIGHT)
	add_theme_color_override(&"font_color", Color.WHITE)
	set_value(text)


func set_value(value: String) -> void:
	text = value
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5)).floor()
