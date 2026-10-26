class_name PixelLabel
extends Label
## Text drawn like DIV's write() with the built-in system font (font 0): `place()` takes the DIV
## anchor and `align_code` is the DIV alignment (0 top-left, 1 top-centre, ... 4 centre, ... 8 bottom-right).
## `pixel_scale` enlarges the 6x8 font by an integer factor (only the new options screen uses it).

@export_range(0, 8) var align_code: int = 4
@export_range(1, 8) var pixel_scale: int = 1

var anchor := Vector2.ZERO


func _ready() -> void:
	add_theme_font_override(&"font", load("res://assets/fnt/system/font_bmfont.fnt"))
	add_theme_font_size_override(&"font_size", 8)
	set_colour(Color.WHITE)


func set_colour(colour: Color) -> void:
	add_theme_color_override(&"font_color", colour)


func place(at: Vector2, value: String) -> void:
	anchor = at
	set_value(value)


## Changes the text, keeping the DIV anchor and alignment.
func set_value(value: String) -> void:
	text = value
	scale = Vector2.ONE * pixel_scale
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (anchor - Vector2(min_size.x * column, min_size.y * row) * 0.5 * pixel_scale).floor()
