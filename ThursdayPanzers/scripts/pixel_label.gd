class_name PixelLabel
extends Label
## Text drawn like DIV's write(): the node's design-time position is the DIV anchor (x, y) and
## `align_code` is DIV's alignment code (0 top-left, 2 top-right, 4 centre ...). Bitmap font 1:1.

enum FontKind { SYSTEM, PANZER }

const FONTS := {
	FontKind.SYSTEM: ["res://assets/fnt/system/font_bmfont.fnt", 8],
	FontKind.PANZER: ["res://assets/fnt/thurpanz/font_bmfont.fnt", 27],  # DIV font 1 (Thurpanz.FNT)
}

@export var font_kind: FontKind = FontKind.PANZER
@export_range(0, 8) var align_code: int = 0

var _anchor := Vector2.ZERO


func _ready() -> void:
	var def: Array = FONTS[font_kind]
	add_theme_font_override(&"font", load(def[0]))
	add_theme_font_size_override(&"font_size", def[1])
	add_theme_color_override(&"font_color", Color.WHITE)  # fonts are multicolour bitmaps
	_anchor = position
	_reposition()


## Create a label in code (scene labels use their editor position as the anchor instead).
static func make(parent: Node, value: String, at: Vector2, align: int = 0,
		kind: FontKind = FontKind.PANZER) -> PixelLabel:
	var label := PixelLabel.new()
	label.font_kind = kind
	label.align_code = align
	label.position = at
	label.text = value
	parent.add_child(label)
	return label


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
