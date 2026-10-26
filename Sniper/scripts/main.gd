extends Node2D
## DIV main code: the column of snipers (one lead sniper with a body, 16 more every 50 px),
## and a balloon released once per second (Timer node in the scene). Sniper count, weapon types
## and balloon rate come from the options screen (`Settings`; the defaults are the original).

const SNIPER_SCENE := preload("res://scenes/sniper.tscn")
const BODY_SCENE := preload("res://scenes/sniper_body.tscn")
const BALLOON_SCENE := preload("res://scenes/balloon.tscn")
const OPTIONS_SCENE := "res://scenes/options.tscn"

const SNIPER_X := 95.0
const LEAD_Y := 370.0
const BODY_OFFSET := Vector2(5, 14)  # DIV: Sniper(95,370) + SniperBody(100,384)
const COLUMN_STEP := 50  # DIV FROM x=0 TO 768 STEP 50
## DIV: the commented-out Sniper(95,570,1) / (95,170,1) / (95,470,2) / (95,270,2), used for
## snipers 18-21 (nearest to the lead first).
const EXTRA_SLOTS: Array[float] = [270.0, 470.0, 170.0, 570.0]

@onready var _balloon_timer: Timer = $BalloonTimer


func _ready() -> void:
	var ys := column_heights(Settings.sniper_count)
	var top_down := ys.duplicate()
	top_down.sort()
	var modes := Settings.enabled_modes()
	for i in ys.size():
		var mode: Sniper.Mode = modes[top_down.find(ys[i]) % modes.size()]
		var sniper := spawn_sniper(ys[i], mode)
		# DIV: the lead sniper has a body; so has every minigun / grenade sniper of the
		# commented-out block (SniperBody(100,y+14) after each of them).
		if i == 0 or mode != Sniper.Mode.NORMAL:
			_spawn_body(sniper)
	_balloon_timer.start(1.0 / Settings.balloons_per_second)
	_spawn_balloon()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"release_mouse"):
		# First Esc frees the mouse (browsers do that themselves), the next one opens the options.
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().change_scene_to_file.call_deferred(OPTIONS_SCENE)
		get_viewport().set_input_as_handled()


## Heights of the column in spawn order: the lead first, then the others top-down. With the
## default 17 this is exactly the original: 370, then 0, 50, ... 750. Fewer snipers keep the
## places nearest to the lead; 18-21 add the commented-out places.
static func column_heights(count: int) -> Array[float]:
	var grid: Array[float] = []
	for y in range(0, 768, COLUMN_STEP):
		grid.append(float(y))
	grid.sort_custom(func(a: float, b: float) -> bool:
		var da := absf(a - LEAD_Y)
		var db := absf(b - LEAD_Y)
		return da < db or (da == db and a < b))
	grid.append_array(EXTRA_SLOTS)
	var others := grid.slice(0, count - 1)
	others.sort()
	var heights: Array[float] = [LEAD_Y]
	heights.append_array(others)
	return heights


func spawn_sniper(y: float, mode: Sniper.Mode = Sniper.Mode.NORMAL) -> Sniper:
	var s := SNIPER_SCENE.instantiate() as Sniper
	s.position = Vector2(SNIPER_X, y)
	s.mode = mode
	add_child(s)
	return s


func _spawn_body(leader: Sniper) -> void:
	var body := BODY_SCENE.instantiate() as SniperBody
	body.position = leader.position + BODY_OFFSET
	body.leader = leader
	body.z_index = -1  # DIV z=1: behind
	add_child(body)


func _spawn_balloon() -> void:
	var b := BALLOON_SCENE.instantiate() as Balloon
	b.setup(randi_range(300, 1024), randi_range(15, 50), randi_range(2, 9))
	add_child(b)


func _on_balloon_timer_timeout() -> void:
	_spawn_balloon()
