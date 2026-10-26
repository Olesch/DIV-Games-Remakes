class_name AutoTest
extends Node
## Smoke test, active with `-- --autotest`. Drives all three ships (spin, thrust, charged shots),
## checks damage / death, optional `--screenshot=<path>`, prints a summary and quits.

var _ticks := 0
var _shot_path := ""
var _ships: Array[Ship] = []
var _max_shots := 0
var _errors := 0
var _b_life_before := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_shot_path = arg.substr("--screenshot=".length())
	for n in ["ShipA", "ShipB", "ShipC"]:
		_ships.append(get_parent().get_node(n) as Ship)
	print("AUTOTEST start")


func _physics_process(_delta: float) -> void:
	_ticks += 1
	# everybody turns right and thrusts; fire taps of different lengths
	var phase := _ticks % 60
	for p in ["p1", "p2", "p3"]:
		Input.action_press(p + "_right")
		Input.action_press(p + "_up")
		if phase < 35:
			Input.action_press(p + "_fire")
		else:
			Input.action_release(p + "_fire")
	_max_shots = maxi(_max_shots, get_tree().get_nodes_in_group(&"shots").size())
	if _ticks == 20:
		_ships[0].take_damage(30)
	if _ticks == 25 and _ships[0].life > 70:
		_errors += 1
		print("FAIL: damage")
	if _shot_path != "" and _ticks == 100:
		get_viewport().get_texture().get_image().save_png(_shot_path)
		print("screenshot saved: ", _shot_path)
	if _ticks == 130:
		_b_life_before = _ships[1].life
		var shot := load("res://scenes/shot.tscn").instantiate() as Shot
		shot.setup(_ships[1].position, 0.0, _ships[0], 3)
		add_child(shot)
	if _ticks == 140 and _ships[1].life > _b_life_before - 3:
		_errors += 1
		print("FAIL: shot did not hurt ship B ", _b_life_before, " -> ", _ships[1].life)
	if _ticks == 120:
		_ships[2].take_damage(500)  # kill ship C
	if _ticks > 240:
		var alive := get_tree().get_nodes_in_group(&"ships").size()
		if alive != 2:
			_errors += 1
		print("AUTOTEST done: ships alive=", alive, " life A=", _ships[0].life, " max_shots=", _max_shots,
			" errors=", _errors)
		get_tree().quit()
