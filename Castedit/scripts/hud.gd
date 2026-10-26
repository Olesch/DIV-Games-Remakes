class_name Hud
extends CanvasLayer
## Editor overlay (new - the original shows nothing but the room): a help panel with the controls
## and the state under the cursor (toggle with H / F1), and short toast messages.

const HELP_TEXT := """CASTEDIT - room editor for Castle
Arrows      move the cursor
Z           floor chooser     X  object chooser
Enter       pick from a chooser / place the brush
            (hold Enter + arrows to draw lines)
Del         floor cell -> plain floor, object -> none
I J K L     room up / left / down / right (6x6 rooms)
Ctrl+S      save to user slot 3 or 4 (sets 1 and 2 are
            read-only; Castle can play the slots)
Ctrl+E      export as a file   Ctrl+O  import a file
H or F1     show / hide this help   Esc  level sets
            (D there: delete slot 3 or 4)"""

var _help_panel: ColorRect
var _help_label: PixelLabel
var _status_label: PixelLabel
var _toast_panel: ColorRect
var _toast_label: PixelLabel
var _toast_timer: Timer


func _ready() -> void:
	_help_panel = ColorRect.new()
	_help_panel.color = Color(0, 0, 0, 0.82)
	_help_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_help_panel.position = Vector2(40, 110)   # below the chooser rows (y 0..80)
	_help_panel.size = Vector2(720, 400)
	add_child(_help_panel)
	_help_label = PixelLabel.create(HELP_TEXT, 16, 14, 0, 2)
	_help_panel.add_child(_help_label)
	_status_label = PixelLabel.create("", 16, 0, 0, 2)
	_status_label.add_theme_color_override(&"font_color", Color(1.0, 0.9, 0.45))
	_help_panel.add_child(_status_label)
	_help_panel.visible = false

	_toast_panel = ColorRect.new()
	_toast_panel.color = Color(0, 0, 0, 0.82)
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.visible = false
	add_child(_toast_panel)
	_toast_label = PixelLabel.create("", 0, 0, 0, 2)
	_toast_panel.add_child(_toast_label)
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.timeout.connect(func() -> void: _toast_panel.visible = false)
	add_child(_toast_timer)


func toggle_help() -> void:
	_help_panel.visible = not _help_panel.visible


func is_help_visible() -> bool:
	return _help_panel.visible


func set_status(text_value: String) -> void:
	_status_label.set_value(text_value)
	_status_label.anchor.y = _help_label.position.y + _help_label.text_size().y * 2 + 18
	_status_label._reposition()
	_help_panel.size.y = _status_label.position.y + _status_label.text_size().y * 2 + 14


func toast(text_value: String, seconds: float) -> void:
	_toast_label.set_value(text_value)
	var w := _toast_label.text_size().x * 2 + 16
	var h := _toast_label.text_size().y * 2 + 10
	_toast_panel.size = Vector2(w, h)
	_toast_panel.position = Vector2(floorf((Game.SCREEN_W - w) / 2.0), Game.SCREEN_H - h - 20)
	_toast_label.anchor = Vector2(8, 5)
	_toast_label._reposition()
	_toast_panel.visible = true
	_toast_timer.start(seconds)


func clear_toast() -> void:
	_toast_timer.stop()
	_toast_panel.visible = false


func toast_text() -> String:
	return _toast_label.text if _toast_panel.visible else ""
