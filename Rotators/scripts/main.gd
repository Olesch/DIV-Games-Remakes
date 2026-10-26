extends Node2D
## Rotators (DIV: PROGRAM Tutorial_1, SPACE2.PRG). Starts the chain of rotators in the screen
## centre, owns the trail canvas and the HUD, and restarts the pattern when options change.

const CENTRE := Vector2(512, 384)  # DIV: Dreher1(512,384,...)
const FONT_PATH := "res://assets/fnt/system/font_bmfont.fnt"
const FONT_SCALE := 2              # DIV system font is 6x8; drawn at 2x on the 1024x768 screen

## Options that only change how things look; everything else rebuilds the pattern.
const LIVE_OPTIONS: Array[StringName] = [&"trails", &"trail_colour", &"show_rotators", &"fps"]

var paused := false:
	set(value):
		paused = value
		_pattern.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
		_update_info()

var _first: Rotator

@onready var _canvas: TrailCanvas = $Canvas
@onready var _pattern: Node2D = $Pattern
@onready var _hud_root: Control = %HudRoot
@onready var _info: Label = %Info
@onready var _help: Label = %Help
@onready var _options_panel: OptionsPanel = %OptionsPanel


func _ready() -> void:
	_hud_root.theme = _make_theme()
	if OS.has_feature("web"):
		_help.text = _help.text.replace("  ESC quit", "")  # never quit the web page
	_options_panel.restart_requested.connect(restart)
	_options_panel.close_requested.connect(_set_options_visible.bind(false))
	Options.changed.connect(_on_option_changed)
	restart()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_options"):
		_set_options_visible(not _options_panel.visible)
	elif event.is_action_pressed(&"close"):
		if _options_panel.visible:
			_set_options_visible(false)
		elif not OS.has_feature("web"):
			get_tree().quit()
	elif event.is_action_pressed(&"pause"):
		paused = not paused
	elif event.is_action_pressed(&"clear_trails"):
		_canvas.clear()
	elif event.is_action_pressed(&"restart"):
		restart()
	elif event.is_action_pressed(&"randomise"):
		Options.randomise()
	elif event.is_action_pressed(&"original"):
		Options.reset_to_original()
	elif event.is_action_pressed(&"toggle_text"):
		_info.visible = not _info.visible
		_help.visible = _info.visible
	else:
		return
	get_viewport().set_input_as_handled()


## Clear the screen and build a new chain (DIV: the main code creating Dreher1).
func restart() -> void:
	if _first:
		_first.free()
	_canvas.clear()
	_first = Rotator.SCENE.instantiate() as Rotator
	_first.kind = Rotator.Kind.FIRST
	_first.index = 0
	_first.spin = Options.rotator_speed(0)
	_first.canvas = _canvas
	_first.position = CENTRE
	_pattern.add_child(_first)  # creates the whole chain
	_update_info()


func rotator_count() -> int:
	return _pattern.find_children("*", "Rotator", true, false).size()


func dots_drawn() -> int:
	return _canvas.dots_drawn


func options_panel() -> OptionsPanel:
	return _options_panel


func _set_options_visible(on: bool) -> void:
	_options_panel.visible = on


func _on_option_changed(key: StringName) -> void:
	if key == &"show_rotators":
		_first.set_sprite_visible(Options.get_value(&"show_rotators"))
	if key in LIVE_OPTIONS:
		_update_info()
	else:
		restart()


func _update_info() -> void:
	if not is_node_ready():
		return
	var mode: String = Options.format_value(&"speed_mode")
	var text := "ROTATORS (Dreher)   %d rotators, %s speeds" % [Options.rotator_count(), mode.to_lower()]
	if int(Options.get_value(&"speed_mode")) == Options.SpeedMode.COUNTED:
		text += " %s %s" % [Options.format_value(&"first_speed").get_slice(" ", 0),
			Options.format_value(&"speed_step").get_slice(" ", 0)]
	text += "   " + ("original settings" if Options.is_default() else "custom settings")
	if paused:
		text += "   PAUSED"
	_info.text = text


func _make_theme() -> Theme:
	var font := load(FONT_PATH) as FontFile
	font.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	var theme := Theme.new()
	theme.default_font = font
	theme.default_font_size = 8 * FONT_SCALE
	return theme
