class_name AutoTest
extends Node
## Smoke test, only with `-- --autotest`. Holds fire, moves the column, adds a minigun and a
## grenade sniper, counts popped balloons, optional `--screenshot=<path>`.

var _elapsed := 0.0
var _crosshair: Crosshair
var _shot_path := ""
var _shot_done := false
var _max_shots := 0
var _pops := 0
var _tracked: Dictionary = {}


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_shot_path = arg.substr("--screenshot=".length())
	_crosshair = get_tree().get_first_node_in_group(&"crosshair") as Crosshair
	_crosshair.follow_mouse = false
	var main := get_parent()
	if not "--plain" in OS.get_cmdline_user_args():
		main.spawn_sniper(250.0, Sniper.Mode.MINIGUN)
		main.spawn_sniper(650.0, Sniper.Mode.GRENADE)
	print("AUTOTEST start")


func _physics_process(delta: float) -> void:
	_elapsed += delta
	var balloons := get_tree().get_nodes_in_group(&"balloons")
	_max_shots = maxi(_max_shots, get_tree().get_nodes_in_group(&"shots").size())
	for b: Balloon in balloons:
		_tracked[b.get_instance_id()] = true
	if not balloons.is_empty():
		var target := balloons[0] as Balloon
		_crosshair.pointer = target.position + Vector2(0, -50)
	Input.action_press(&"fire")
	if fmod(_elapsed, 8.0) < 4.0:
		Input.action_press(&"column_up")
	else:
		Input.action_release(&"column_up")
	if fmod(_elapsed, 1.0) < 0.2:
		Input.action_press(&"reload")
	else:
		Input.action_release(&"reload")
	if _shot_path != "" and not _shot_done and _elapsed > 9.0:
		_shot_done = true
		get_viewport().get_texture().get_image().save_png(_shot_path)
		print("screenshot saved: ", _shot_path)
	if _elapsed > 20.0:
		var alive := 0
		for id: int in _tracked:
			if is_instance_id_valid(id):
				alive += 1
		print("AUTOTEST done: balloons_spawned=", _tracked.size(), " alive=", alive,
			" max_shots=", _max_shots, " pointer=", _crosshair.pointer)
		get_tree().quit()
