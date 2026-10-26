class_name Hud
extends CanvasLayer
## New (the original shows no text at all): life of both tanks in the top corners and the
## winner message at the round end, in the DIV system font. Not shown in the sandbox.

const SHADOW := Color8(0, 40, 0)  # palette colour 32, the darkest grass green

var _life_labels: Array[Label] = []
var _banner: Label
var _prompt: Label


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = Game.make_theme()
	add_child(root)
	for i in 2:
		var label := _make_label(root, 1)
		label.position = Vector2(8, 8) if i == 0 else Vector2(Game.SCREEN_SIZE.x - 8 - 320, 8)
		label.size = Vector2(320, 16)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if i == 0 else HORIZONTAL_ALIGNMENT_RIGHT
		_life_labels.append(label)
	_banner = _make_label(root, 3)
	_banner.position = Vector2(0, 330)
	_prompt = _make_label(root, 1)
	_prompt.position = Vector2(0, 410)
	for label in [_banner, _prompt]:
		label.size = Vector2(Game.SCREEN_SIZE.x, 0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.visible = false


func show_life(player: int, life: int) -> void:
	_life_labels[player].text = "PLAYER %d   LIFE %d" % [player + 1, maxi(life, 0)]


func show_winner(text: String) -> void:
	_banner.text = text
	_prompt.text = "ENTER = NEW ROUND     ESC = OPTIONS"
	_banner.visible = true
	_prompt.visible = true


func winner_text() -> String:
	return _banner.text if _banner.visible else ""


## Label in the system font at `size_factor` x the normal 2x scale, with a dark green shadow.
func _make_label(parent: Control, size_factor: int) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override(&"font_size", 8 * Game.FONT_SCALE * size_factor)
	label.add_theme_color_override(&"font_shadow_color", SHADOW)
	label.add_theme_constant_override(&"shadow_offset_x", Game.FONT_SCALE * size_factor)
	label.add_theme_constant_override(&"shadow_offset_y", Game.FONT_SCALE * size_factor)
	parent.add_child(label)
	return label
