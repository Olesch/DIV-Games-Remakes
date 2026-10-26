class_name PixelLabel
extends Label
## Text drawn like DIV's write(): `anchor` is the DIV (x, y) and `align_code` DIV's alignment
## (0 top-left, 1 top-centre, 2 top-right, 3 middle-left, 4 centre, 5 middle-right,
## 6 bottom-left, 7 bottom-centre, 8 bottom-right). Uses the converted 6x8 system font at an
## integer scale.

@warning_ignore_start("integer_division")

const FONT := "res://assets/fnt/system/font_bmfont.fnt"

var anchor := Vector2.ZERO
var align_code := 0
var pixel_scale := 1


static func make(parent: Node, value: String, at: Vector2, align: int = 0, scale_factor: int = 1) -> PixelLabel:
	var label := PixelLabel.new()
	label.anchor = at
	label.align_code = align
	label.pixel_scale = scale_factor
	label.add_theme_font_override(&"font", load(FONT))
	label.add_theme_font_size_override(&"font_size", 8)
	label.add_theme_color_override(&"font_color", Color.WHITE)
	label.text = value
	parent.add_child(label)
	label._reposition()
	return label


func set_value(value: String) -> void:
	if text == value:
		return
	text = value
	_reposition()


func _reposition() -> void:
	scale = Vector2.ONE * pixel_scale
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := align_code / 3
	position = (anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5) * pixel_scale).floor()
