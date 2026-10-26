class_name PixelLabel
extends Label
## Text drawn like DIV's write(): `position` at design time (or `anchor` when created in code) is the DIV
## anchor (x, y) and `align_code` is DIV's alignment code (0 top-left, 1 top-centre, 2 top-right,
## 3 middle-left, 4 centre, 5 middle-right, 6 bottom-left, 7 bottom-centre, 8 bottom-right).
## Uses the converted bitmap fonts at 1:1 size.

enum FontKind { SYSTEM, MINI1 }

const FONTS := {
	FontKind.SYSTEM: ["res://assets/fnt/system/font_bmfont.fnt", 8],   # DIV font 0
	FontKind.MINI1: ["res://assets/fnt/mini1/font_bmfont.fnt", 46],    # DIV font 1 (Mini1.fnt)
}

@export var font_kind: FontKind = FontKind.SYSTEM
@export_range(0, 8) var align_code: int = 0

var anchor := Vector2.ZERO
var _anchor_set := false


## Create a label from code (DIV write / write_int).
static func make(text_value: String, at: Vector2, align: int = 0, kind: FontKind = FontKind.SYSTEM) -> PixelLabel:
	var label := PixelLabel.new()
	label.font_kind = kind
	label.align_code = align
	label.anchor = at
	label._anchor_set = true
	label.text = text_value
	return label


func _ready() -> void:
	var def: Array = FONTS[font_kind]
	add_theme_font_override(&"font", load(def[0]))
	add_theme_font_size_override(&"font_size", def[1])
	add_theme_color_override(&"font_color", Color.WHITE)  # fonts are multicolour bitmaps
	if not _anchor_set:
		anchor = position
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
