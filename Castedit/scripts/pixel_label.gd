class_name PixelLabel
extends Label
## Text drawn like DIV's write() with the 6x8 system font (font 0): `anchor` is the DIV (x, y) and
## `align_code` DIV's alignment (0 top-left .. 4 centre .. 8 bottom-right). `zoom` draws it 2x, 3x...

const LINE_SPACING := 2

var anchor := Vector2.ZERO
var align_code: int = 0
var zoom: int = 1

static var _font: Font = null


static func create(text_value: String, x: float, y: float, align: int = 0, zoom_factor: int = 1) -> PixelLabel:
	var l := PixelLabel.new()
	if _font == null:
		_font = load(Gfx.SYSTEM_FONT_PATH)
	l.add_theme_font_override(&"font", _font)
	l.add_theme_font_size_override(&"font_size", Gfx.SYSTEM_FONT_SIZE)
	l.add_theme_color_override(&"font_color", Color.WHITE)
	l.add_theme_constant_override(&"line_spacing", LINE_SPACING)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.anchor = Vector2(x, y)
	l.align_code = align
	l.zoom = zoom_factor
	l.scale = Vector2.ONE * zoom_factor
	l.text = text_value
	l._reposition()
	return l


func set_value(value: String) -> void:
	if text != value:
		text = value
		_reposition()


## The system font is monospaced 6x8 (2 px line spacing here), so the text block size is computed
## directly (Label.get_minimum_size() reports a much taller box for this bitmap font).
func text_size() -> Vector2:
	var lines := text.split("
")
	var longest := 0
	for line in lines:
		longest = maxi(longest, line.length())
	return Vector2(longest * 6, lines.size() * (Gfx.SYSTEM_FONT_SIZE + LINE_SPACING) - LINE_SPACING)


func _reposition() -> void:
	var min_size := text_size()
	size = min_size
	var shown := min_size * zoom
	var column := align_code % 3
	var row := floori(align_code / 3.0)
	position = (anchor - Vector2(shown.x * column * 0.5, shown.y * row * 0.5)).floor()
