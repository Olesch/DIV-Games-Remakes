extends Node2D
## Main code of MANDBROT.PRG: reads the keys once per DIV frame (18 fps, the physics tick)
## and turns them into view changes and draw requests on the FractalCanvas.
## Keys work while held, like DIV's key(): holding an arrow keeps moving 100 px per frame,
## holding + keeps zooming by 1.5x per frame.

const PAN_STEP := 100              # DIV: xshi/yshi +-100
const PREVIEW_STEP := 5            # DIV: Draw(x,y,5,6) after WASD / 1 / Q
const PREVIEW_DIVISOR := 6

@onready var _canvas: FractalCanvas = $FractalCanvas
@onready var _hint: Control = $HintLayer/Hint

## DIV: malen - keys 3/4 change it, but the formula that used it is commented out in the
## original, so it has no visible effect. Kept for completeness.
var color_mode := 1


func _ready() -> void:
	_register_input_actions()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/debug/autotest.gd").new())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_hint"):
		_hint.visible = not _hint.visible
		get_viewport().set_input_as_handled()


## One call = one DIV frame of the main LOOP (same order of checks as the original).
func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed(&"draw_full"):        # F1: Draw(x,y,1,1)
		_canvas.request_draw(1, 1)
	if Input.is_action_pressed(&"draw_preview_half"):  # F2: Draw(x,y,5,2)
		_canvas.request_draw(5, 2)
	if Input.is_action_pressed(&"draw_preview_third"):  # F3: Draw(x,y,10,3)
		_canvas.request_draw(10, 3)
	if Input.is_action_pressed(&"clear_screen"):     # F4: put(0,over,512,384)
		_canvas.stamp_overlay()

	# arrows, +, -: change the view only (redraw with F1/F2/F3)
	if Input.is_action_pressed(&"move_up"):
		_canvas.pan(0, -PAN_STEP)
	if Input.is_action_pressed(&"move_down"):
		_canvas.pan(0, PAN_STEP)
	if Input.is_action_pressed(&"move_left"):
		_canvas.pan(-PAN_STEP, 0)
	if Input.is_action_pressed(&"move_right"):
		_canvas.pan(PAN_STEP, 0)
	if Input.is_action_pressed(&"zoom_in"):
		_canvas.zoom_in()
	if Input.is_action_pressed(&"zoom_out"):
		_canvas.zoom_out()

	# W/S/A/D, 1, Q: change the view and draw a small preview of the screen centre
	if Input.is_action_pressed(&"preview_up"):
		_canvas.pan(0, -PAN_STEP)
		_preview()
	if Input.is_action_pressed(&"preview_down"):
		_canvas.pan(0, PAN_STEP)
		_preview()
	if Input.is_action_pressed(&"preview_left"):
		_canvas.pan(-PAN_STEP, 0)
		_preview()
	if Input.is_action_pressed(&"preview_right"):
		_canvas.pan(PAN_STEP, 0)
		_preview()
	if Input.is_action_pressed(&"preview_zoom_in"):
		_canvas.zoom_in()
		_preview()
	if Input.is_action_pressed(&"preview_zoom_out"):
		_canvas.zoom_out()
		_preview()

	if Input.is_action_pressed(&"color_mode_up"):    # 3: malen++
		color_mode += 1
	if Input.is_action_pressed(&"color_mode_down") and color_mode > 1:  # 4: malen--
		color_mode -= 1


func _preview() -> void:
	_canvas.request_draw(PREVIEW_STEP, PREVIEW_DIVISOR)


# ----------------------------------------------------------------- input map

func _register_input_actions() -> void:
	_add_keys(&"draw_full", [KEY_F1])
	_add_keys(&"draw_preview_half", [KEY_F2])
	_add_keys(&"draw_preview_third", [KEY_F3])
	_add_keys(&"clear_screen", [KEY_F4])
	_add_keys(&"move_up", [KEY_UP])          # DIV: _up (also keypad 8 with Num Lock off)
	_add_keys(&"move_down", [KEY_DOWN])
	_add_keys(&"move_left", [KEY_LEFT])
	_add_keys(&"move_right", [KEY_RIGHT])
	_add_keys(&"zoom_in", [KEY_EQUAL, KEY_KP_ADD])         # DIV: _plus (+ keypad +, new)
	_add_keys(&"zoom_out", [KEY_MINUS, KEY_KP_SUBTRACT])   # DIV: _minus (+ keypad -, new)
	_add_keys(&"preview_up", [KEY_W])
	_add_keys(&"preview_down", [KEY_S])
	_add_keys(&"preview_left", [KEY_A])
	_add_keys(&"preview_right", [KEY_D])
	_add_keys(&"preview_zoom_in", [KEY_1])
	_add_keys(&"preview_zoom_out", [KEY_Q])
	_add_keys(&"color_mode_up", [KEY_3])
	_add_keys(&"color_mode_down", [KEY_4])
	_add_keys(&"toggle_hint", [KEY_H])       # new: hide the key hint line


func _add_keys(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key: int in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key as Key
		InputMap.action_add_event(action, event)
