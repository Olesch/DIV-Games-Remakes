class_name PixelLabel
extends Label
## Text drawn like DIV's write(): `anchor` is the DIV (x, y) and `align_code` is DIV's alignment code
## (0 top-left, 1 top-centre, 2 top-right, 3 middle-left, 4 centre, 5 middle-right, 6.. bottom).

enum FontKind { SYSTEM, LOMMINGS }

const FONTS := {
	FontKind.SYSTEM: ["res://assets/fnt/system/font_bmfont.fnt", 8],
	FontKind.LOMMINGS: ["res://assets/fnt/lommings/font_bmfont.fnt", 16],  # DIV font 1
}

@export var font_kind: FontKind = FontKind.LOMMINGS
@export_range(0, 8) var align_code: int = 4

@export var anchor := Vector2.ZERO


func _ready() -> void:
	var def: Array = FONTS[font_kind]
	add_theme_font_override(&"font", load(def[0]))
	add_theme_font_size_override(&"font_size", def[1])
	add_theme_color_override(&"font_color", Color.WHITE)  # bitmap fonts are multicolour
	_reposition()


func set_value(value: String) -> void:
	if value == text:
		return
	text = value
	_reposition()


func place(at: Vector2) -> void:
	anchor = at
	_reposition()


func _reposition() -> void:
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5)).floor()
