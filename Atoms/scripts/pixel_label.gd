class_name PixelLabel
extends Label
## Text drawn like DIV's write()/write_int(): the position at creation time is the DIV anchor (x, y)
## and `align_code` is DIV's alignment code (0 top-left, 1 top-centre, 2 top-right, 3 middle-left,
## 4 centre, 5 middle-right, 6 bottom-left, 7 bottom-centre, 8 bottom-right).
## With `getter` set it behaves like write_int: the text follows the value every frame.

enum FontKind { SYSTEM, ATOMS }

const FONTS := {
	FontKind.SYSTEM: ["res://assets/fnt/system/font_bmfont.fnt", 8],     # DIV font 0
	FontKind.ATOMS: ["res://assets/fnt/atoms/font_bmfont.fnt", 54],      # DIV font 1 (Atoms.FNT)
}

var font_kind: FontKind = FontKind.ATOMS
var align_code: int = 0
var getter: Callable = Callable()

var _anchor := Vector2.ZERO


func _ready() -> void:
	var def: Array = FONTS[font_kind]
	add_theme_font_override(&"font", load(def[0]))
	add_theme_font_size_override(&"font_size", def[1])
	add_theme_color_override(&"font_color", Color.WHITE)  # fonts are multicolour bitmaps
	_anchor = position
	if getter.is_valid():
		text = str(getter.call())
	_reposition()


func _process(_delta: float) -> void:
	if getter.is_valid():
		var s := str(getter.call())
		if s != text:
			text = s
			_reposition()


func _reposition() -> void:
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (_anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5)).floor()
