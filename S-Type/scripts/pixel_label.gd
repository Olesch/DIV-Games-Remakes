class_name PixelLabel
extends Label
## Text drawn like DIV's write(): `anchor` is the DIV (x, y) and `align_code` DIV's alignment code
## (0 top-left, 1 top-centre, 2 top-right, 3 middle-left, 4 centre, 5 middle-right,
## 6 bottom-left, 7 bottom-centre, 8 bottom-right). Bitmap fonts are drawn 1:1.

## DIV font number (order of load_fnt; 0 = system font) -> [BMFont file, line height]
const FONTS := {
	0: ["res://assets/fnt/system/font_bmfont.fnt", 8],
	1: ["res://assets/fnt/s-type/font_bmfont.fnt", 27],
	2: ["res://assets/fnt/s-type2/font_bmfont.fnt", 23],
	3: ["res://assets/fnt/s-type3/font_bmfont.fnt", 23],
	4: ["res://assets/fnt/s-type4/font_bmfont.fnt", 23],
}

var anchor := Vector2.ZERO
var align_code := 0


## write(font, x, y, align, text)
static func make(parent: Node, font: int, x: float, y: float, align: int, value: String) -> PixelLabel:
	var l := PixelLabel.new()
	var def: Array = FONTS[font]
	l.add_theme_font_override(&"font", load(def[0]))
	l.add_theme_font_size_override(&"font_size", def[1])
	l.add_theme_color_override(&"font_color", Color.WHITE)  # fonts are multicolour bitmaps
	l.anchor = Vector2(x, y)
	l.align_code = align
	l.text = value
	parent.add_child(l)
	l.reposition()
	return l


func set_value(value: String) -> void:
	if value != text:
		text = value
		reposition()


func reposition() -> void:
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5)).floor()
