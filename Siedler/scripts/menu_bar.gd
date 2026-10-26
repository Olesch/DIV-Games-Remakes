class_name ActionMenu
extends Control
## DIV: KnoepfeEvent - the keyboard menu written in the system font at the bottom-left corner
## (write(0,0,480,6,...)). A small state machine replaces the original's nested LOOPs.
## (A)bbruch always returns to "(M)enu": in the original the A key, still held, also ended
## every enclosing menu loop in the same frame.

enum State { CLOSED, MAIN, POINTS, POINT_WOOD, POINT_CLAY, WORKERS, WORKERS_WOOD, WORKERS_CLAY, BUILD }

const TEXTS := {
	State.CLOSED: "(M)enu",
	State.MAIN: "(S)ammelpunkte setzen  (G)ebaeude bauen  A(r)beiterzahlen setzen  (A)bbruch",
	State.POINTS: "(H)olz  (L)ehm  (A)bbruch",
	State.POINT_WOOD: "Links-Klick: Sammelpunkt setzen fuer Holz  (A)bbruch",
	State.POINT_CLAY: "Links-Klick: Sammelpunkt setzen fuer Lehm  (A)bbruch",
	State.WORKERS: "(H)olzfaeller  (L)ehmsammler  (A)bbruch",
	State.WORKERS_WOOD: "Holzfaeller(+)(-)  (A)bbruch",
	State.WORKERS_CLAY: "Lehmsammler(+)(-)  (A)bbruch",
	State.BUILD: "(H)aus (A)bbruch",
}
const SYSTEM_FONT := "res://assets/fnt/system/font_bmfont.fnt"
const FONT_SIZE := 8

var state: State = State.CLOSED

var _text: Label
var _number: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text = _make_label(480)    # write(0,0,480,6,...)
	_number = _make_label(470)  # write_int(0,0,470,6,OFFSET ...ArbeiterMax)
	Game.worker_max_changed.connect(_refresh)
	_refresh()


func _process(_delta: float) -> void:
	# The click that sets a collection point ends the "Links-Klick" step.
	if state == State.POINT_WOOD and not Game.wood_point_pending:
		_go(State.POINTS)
	elif state == State.POINT_CLAY and not Game.clay_point_pending:
		_go(State.POINTS)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var handled := true
	if event.is_action_pressed(&"menu_abort") and state != State.CLOSED:
		if state == State.BUILD:
			Game.building = false
			Game.house_size = 0
		# Original bug kept: the "Holzsetzen=0" after BREAK is never reached, so an aborted
		# collection point stays armed and the next left click still sets it.
		_go(State.CLOSED)
	else:
		handled = _handle_key(event)
	if handled:
		get_viewport().set_input_as_handled()


func _handle_key(event: InputEvent) -> bool:
	match state:
		State.CLOSED:
			if event.is_action_pressed(&"menu_open"):
				_go(State.MAIN)
				return true
		State.MAIN:
			if event.is_action_pressed(&"menu_points"):
				_go(State.POINTS)
				return true
			if event.is_action_pressed(&"menu_workers"):
				_go(State.WORKERS)
				return true
			if event.is_action_pressed(&"menu_build"):
				_go(State.BUILD)
				return true
		State.POINTS:
			if event.is_action_pressed(&"menu_h"):
				Game.wood_point_pending = true
				_go(State.POINT_WOOD)
				return true
			if event.is_action_pressed(&"menu_l"):
				Game.clay_point_pending = true
				_go(State.POINT_CLAY)
				return true
		State.WORKERS:
			if event.is_action_pressed(&"menu_h"):
				_go(State.WORKERS_WOOD)
				return true
			if event.is_action_pressed(&"menu_l"):
				_go(State.WORKERS_CLAY)
				return true
		State.WORKERS_WOOD, State.WORKERS_CLAY:
			# Original: +-1 every 3 frames while held; here one step per press plus key repeat.
			var step := 0
			if event.is_action_pressed(&"count_up", true):
				step = 1
			elif event.is_action_pressed(&"count_down", true):
				step = -1
			if step != 0:
				if state == State.WORKERS_WOOD:
					Game.wood_workers_max += step
				else:
					Game.clay_workers_max += step
				return true
		State.BUILD:
			if event.is_action_pressed(&"menu_h"):
				if not Game.building:
					Game.building = true
					Game.house_size = Game.HOUSE_3X3
				return true
	return false


func _go(new_state: State) -> void:
	state = new_state
	_refresh()


func _refresh() -> void:
	_set_text(_text, TEXTS[state])
	match state:
		State.WORKERS_WOOD:
			_set_text(_number, str(Game.wood_workers_max))
		State.WORKERS_CLAY:
			_set_text(_number, str(Game.clay_workers_max))
		_:
			_set_text(_number, "")


func _make_label(bottom: float) -> Label:
	var label := Label.new()
	label.add_theme_font_override(&"font", load(SYSTEM_FONT))
	label.add_theme_font_size_override(&"font_size", FONT_SIZE)
	label.add_theme_color_override(&"font_color", Color.WHITE)
	label.set_meta(&"bottom", bottom)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


## Alignment code 6 (bottom-left): the anchor (0, bottom) is the text's lower-left corner.
func _set_text(label: Label, value: String) -> void:
	label.text = value
	label.size = label.get_minimum_size()
	label.position = Vector2(0, float(label.get_meta(&"bottom")) - label.size.y)
