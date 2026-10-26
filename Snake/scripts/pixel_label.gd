class_name PixelLabel
extends Label
## Text drawn like DIV's write(font 0, x, y, align 0, ...): top-left anchored, 6x8 system bitmap font at 1:1.

func _ready() -> void:
	add_theme_font_override(&"font", load("res://assets/fnt/system/font_bmfont.fnt"))
	add_theme_font_size_override(&"font_size", 8)
	add_theme_color_override(&"font_color", Color.WHITE)  # bitmap font is already coloured


func set_value(value: int) -> void:
	text = str(value)
