extends Node
## Autoload "Settings": the values ANT.PRG hard-codes, adjustable in the options panel.
## Defaults are the original's, except the rule: ANT.PRG with its table slip fixed, which is
## Langton's ant "RL" (owner's decision 2026-10-26). Not saved to disk.

## Rule, ant count or start canvas changed: the run starts over.
signal restart_requested
## Steps per frame or edge mode changed: applied to the running simulation.
signal live_changed

enum StartCanvas { PICTURE, RANDOM_DOTS }

const RULE_PRESETS: Array[String] = ["RL", "RLR", "LLRR", "LRRRRRLLR",
		"LLRRRLRLRLLR", "RRLLLRLLLRRR", "RRLRLLRLRR", AntRule.ORIGINAL]
## ANT.PRG with its table slip fixed = Langton's ant (same tables as AntRule.original_fixed()).
const DEFAULT_RULE := "RL"
const STEP_CHOICES: Array[int] = [1, 10, 100, 1000, 3001, 10000, 30000]
## DIV: counter++ ... IF(counter>3000) FRAME(100); -> 3001 steps per ant per frame.
const DEFAULT_STEPS := 3001
const MAX_ANTS := 9

var rule_text: String = DEFAULT_RULE:
	set(value):
		if value != rule_text and AntRule.is_valid(value):
			rule_text = value
			restart_requested.emit()
var ant_count: int = 1:
	set(value):
		value = clampi(value, 1, MAX_ANTS)
		if value != ant_count:
			ant_count = value
			restart_requested.emit()
var start_canvas: StartCanvas = StartCanvas.PICTURE:
	set(value):
		if value != start_canvas:
			start_canvas = value
			restart_requested.emit()
var steps_per_frame: int = DEFAULT_STEPS:
	set(value):
		steps_per_frame = maxi(1, value)
		live_changed.emit()
## Original: the ant walks off the picture and keeps going (reads black, paints nothing).
var wrap_edges: bool = false:
	set(value):
		wrap_edges = value
		live_changed.emit()


func _ready() -> void:
	_register_input_actions()


func reset_to_defaults() -> void:
	steps_per_frame = DEFAULT_STEPS
	wrap_edges = false
	# set the restart-relevant values silently, then restart once
	set_block_signals(true)
	rule_text = DEFAULT_RULE
	ant_count = 1
	start_canvas = StartCanvas.PICTURE
	set_block_signals(false)
	restart_requested.emit()


## Browsers never pass Ctrl+W to the page (it closes the tab), and Ctrl+W is "zoom out + move up"
## in the original, so the web build zooms out with Q / PgDn / - only.
static func ctrl_zoom_available() -> bool:
	return not OS.has_feature("web")


func _register_input_actions() -> void:
	var map := {
		# DIV: key(_w) y+=5 / _s y-=5 / _a x+=5 / _d x-=5 (moves the picture, so W looks up)
		&"pan_up": [KEY_W, KEY_UP],
		&"pan_down": [KEY_S, KEY_DOWN],
		&"pan_left": [KEY_A, KEY_LEFT],
		&"pan_right": [KEY_D, KEY_RIGHT],
		# DIV: key(_alt) size+=10 / key(_control) size-=10
		&"zoom_in": [KEY_ALT, KEY_E, KEY_PAGEUP, KEY_KP_ADD, KEY_EQUAL],
		&"zoom_out": [KEY_Q, KEY_PAGEDOWN, KEY_KP_SUBTRACT, KEY_MINUS],
		&"view_reset": [KEY_HOME],
		&"toggle_pause": [KEY_SPACE],
		&"restart": [KEY_R],
		&"toggle_options": [KEY_O, KEY_ESCAPE],
		&"toggle_help": [KEY_H],
	}
	if ctrl_zoom_available():
		map[&"zoom_out"].push_front(KEY_CTRL)
	for action: StringName in map:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key: Key in map[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
