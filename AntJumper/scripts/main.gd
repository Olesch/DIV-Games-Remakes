extends Node2D
## AntJumper main scene (DIV: the main code). Shows the picture at x/y with a zoom size,
## lets the player move/zoom it, starts the ants and restarts when the options change.

const ANT_SCENE := preload("res://scenes/ant.tscn")

const DIV_FPS := 18.0                     # no set_fps in ANT.PRG -> DIV default
const PAN_SPEED := 5.0 * DIV_FPS          # DIV: x/y += 5 per frame
const ZOOM_SPEED := 10.0 * DIV_FPS        # DIV: size += 10 per frame (percent)
const WHEEL_FACTOR := 1.15
const MIN_SIZE := 10.0                    # new: DIV let size run to 0 and below (picture vanishes)
const MAX_SIZE := 3200.0
const START_POSITION := Vector2(512, 384) # DIV: x=512; y=384;

## Start cells and directions. Ant 1 is the original's Ant(512,384,0); ants 2-5 use the
## commented-out calls Ant(508,384,0) .. Ant(512,380,3) (whose last value was meant as the
## direction, but went to `priority`); 6-9 fill the diagonals.
const ANT_STARTS: Array[Vector3i] = [
	Vector3i(512, 384, 0),
	Vector3i(508, 384, 0), Vector3i(516, 384, 1), Vector3i(512, 388, 2), Vector3i(512, 380, 3),
	Vector3i(508, 380, 1), Vector3i(516, 380, 2), Vector3i(516, 388, 3), Vector3i(508, 388, 0),
]

## DIV: size (percent) of the main process showing the picture.
var size_percent: float = 100.0:
	set(value):
		size_percent = clampf(value, MIN_SIZE, MAX_SIZE)
		canvas.scale = Vector2.ONE * size_percent / 100.0

@onready var canvas: AntCanvas = $AntCanvas
@onready var ants: Node = $AntCanvas/Ants
@onready var options: OptionsPanel = $UI/Root/OptionsPanel
@onready var hud: Hud = $UI/Root/Hud


func _ready() -> void:
	Settings.restart_requested.connect(restart)
	Settings.live_changed.connect(_apply_live_settings)
	_apply_live_settings()
	restart()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func restart() -> void:
	for ant in ants.get_children():
		ants.remove_child(ant)
		ant.queue_free()
	var rule := AntRule.from_setting(Settings.rule_text)
	canvas.reset(rule, Settings.start_canvas)
	for i in Settings.ant_count:
		var start := ANT_STARTS[i]
		var ant := ANT_SCENE.instantiate() as Ant
		ant.cell = Vector2i(start.x, start.y)
		ant.direction = start.z
		ants.add_child(ant)


func reset_view() -> void:
	canvas.position = START_POSITION
	size_percent = 100.0


func is_paused() -> bool:
	return ants.process_mode == Node.PROCESS_MODE_DISABLED


func set_paused(paused: bool) -> void:
	ants.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT


func _apply_live_settings() -> void:
	canvas.wrap_edges = Settings.wrap_edges


func _process(delta: float) -> void:
	hud.show_status(canvas.rule.label, ants.get_child_count(), Settings.steps_per_frame,
		canvas.total_steps, size_percent, is_paused())
	if _keyboard_in_ui():
		return
	# W moves the picture down, i.e. the view goes up (DIV: key(_w) y+=5 ...)
	var pan := Input.get_vector(&"pan_left", &"pan_right", &"pan_up", &"pan_down")
	canvas.position -= pan * PAN_SPEED * delta
	var zoom := Input.get_axis(&"zoom_out", &"zoom_in")
	if zoom != 0.0:
		size_percent += zoom * ZOOM_SPEED * delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_options"):
		options.toggle()
	elif event.is_action_pressed(&"restart"):
		restart()
	elif event.is_action_pressed(&"toggle_pause"):
		set_paused(not is_paused())
	elif event.is_action_pressed(&"view_reset"):
		reset_view()
	elif event.is_action_pressed(&"toggle_help"):
		hud.visible = not hud.visible
	elif event is InputEventMouseButton and event.pressed:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_WHEEL_UP:
			size_percent *= WHEEL_FACTOR
		elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			size_percent /= WHEEL_FACTOR
	elif event is InputEventMouseMotion and (event as InputEventMouseMotion).button_mask & MOUSE_BUTTON_MASK_LEFT:
		canvas.position += (event as InputEventMouseMotion).relative
	else:
		return
	get_viewport().set_input_as_handled()


## True while a control of the options panel has the keyboard (keys then go to the panel).
func _keyboard_in_ui() -> bool:
	return get_viewport().gui_get_focus_owner() != null
