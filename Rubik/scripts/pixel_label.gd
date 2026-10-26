class_name PixelLabel
extends Label
## Text drawn like DIV's write() with the built-in system font (font 0): `anchor` is the DIV (x, y)
## and `align_code` is DIV's alignment code (0 top-left, 1 top-centre, 2 top-right, 3 middle-left,
## 4 centre, 5 middle-right, 6 bottom-left, 7 bottom-centre, 8 bottom-right).

const FONT_PATH := "res://assets/fnt/system/font_bmfont.fnt"
const FONT_SIZE := 8

var anchor := Vector2.ZERO
var align_code := 0


static func make(parent: Node, text_value: String, x: int, y: int, align: int) -> PixelLabel:
	var l := PixelLabel.new()
	l.anchor = Vector2(x, y)
	l.align_code = align
	l.text = text_value
	parent.add_child(l)
	return l


func _ready() -> void:
	add_theme_font_override(&"font", load(FONT_PATH))
	add_theme_font_size_override(&"font_size", FONT_SIZE)
	add_theme_color_override(&"font_color", Color.WHITE)
	_reposition()


func set_value(value: String) -> void:
	text = value
	_reposition()


func _reposition() -> void:
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5)).floor()
