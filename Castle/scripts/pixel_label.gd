class_name PixelLabel
extends Label
## Text drawn like DIV's write(): `anchor` is the DIV (x, y) and `align_code` is DIV's alignment code
## (0 top-left, 1 top-centre, 2 top-right, 3 middle-left, 4 centre, 5 middle-right, 6 bottom-left,
## 7 bottom-centre, 8 bottom-right). Uses the converted bitmap font (font 1 = Castle.fnt) 1:1.

var anchor := Vector2.ZERO
var align_code: int = 0

static var _font: Font = null


static func create(text_value: String, x: float, y: float, align: int = 0) -> PixelLabel:
	var l := PixelLabel.new()
	if _font == null:
		_font = load(Gfx.FONT_PATH)
	l.add_theme_font_override(&"font", _font)
	l.add_theme_font_size_override(&"font_size", Gfx.FONT_SIZE)
	l.add_theme_color_override(&"font_color", Color.WHITE)  # fonts are multicolour bitmaps
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.anchor = Vector2(x, y)
	l.align_code = align
	l.text = text_value
	l._reposition()
	return l


func set_value(value: String) -> void:
	if text != value:
		text = value
		_reposition()


func _reposition() -> void:
	var min_size := get_minimum_size()
	size = min_size
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (anchor - Vector2(min_size.x * column * 0.5, min_size.y * row * 0.5)).floor()
