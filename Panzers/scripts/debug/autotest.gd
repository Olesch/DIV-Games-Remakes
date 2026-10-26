class_name AutoTest
extends Node
## Automated smoke test, only active with `-- --autotest`. Drives both tanks with simulated key
## presses, checks movement/shots, optionally saves a screenshot (`--screenshot=<path>`), prints a
## summary and quits (desktop only). The game never writes anything to user://.

var _elapsed := 0.0
var _screenshot_path := ""
var _screenshot_done := false
var _tanks: Array[Tank] = []
var _start_pos: Array[Vector2] = []
var _failures: PackedStringArray = []
var _max_shots := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	for n in get_parent().get_children():
		if n is Tank:
			_tanks.append(n)
			_start_pos.append(n.position)
	print("AUTOTEST start, tanks=", _tanks.size())


func _physics_process(delta: float) -> void:
	_elapsed += delta
	for p in ["p1", "p2"]:
		# drive at first and at the end (so the screenshot at 2.5 s still shows both tanks)
		if _elapsed < 1.0 or _elapsed > 4.0:
			Input.action_press(StringName(p + "_forward"))
		else:
			Input.action_release(StringName(p + "_forward"))
		Input.action_press(StringName(p + "_fire"))
		# p1 turns right (down the screen), p2 turns left (up) for half a second
		var turn_action := "_right" if p == "p1" else "_left"
		if _elapsed < 0.5:
			Input.action_press(StringName(p + turn_action))
		else:
			Input.action_release(StringName(p + turn_action))
		if int(_elapsed * 2.0) % 2 == 0:
			Input.action_press(StringName(p + "_turret_right"))
			Input.action_release(StringName(p + "_turret_left"))
		else:
			Input.action_release(StringName(p + "_turret_right"))
			Input.action_press(StringName(p + "_turret_left"))
	_max_shots = maxi(_max_shots, get_tree().get_nodes_in_group(&"shots").size())

	if _screenshot_path != "" and not _screenshot_done and _elapsed > 2.5:
		_screenshot_done = true
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path)
	if _elapsed > 6.0:
		_finish()


func _finish() -> void:
	set_physics_process(false)
	for i in _tanks.size():
		if _tanks[i].position.distance_to(_start_pos[i]) < 100.0:
			_failures.append("tank %d did not move" % i)
		if _tanks[i].shots_fired < 20:
			_failures.append("tank %d fired only %d shots" % [i, _tanks[i].shots_fired])
	if _tanks.size() != 2:
		_failures.append("expected 2 tanks")
	if _max_shots < 5:
		_failures.append("too few live shots (%d)" % _max_shots)
	print("AUTOTEST done: tanks=", _tanks.size(), " fired=", _tanks.map(func(t: Tank) -> int: return t.shots_fired),
		" max live shots=", _max_shots, " live now=", get_tree().get_nodes_in_group(&"shots").size())
	if _failures.is_empty():
		print("AUTOTEST PASS")
	else:
		print("AUTOTEST FAIL: ", ", ".join(_failures))
	for p in ["p1", "p2"]:
		for a in ["left", "right", "forward", "fire", "turret_left", "turret_right"]:
			Input.action_release(StringName(p + "_" + a))
	Game.quit_game()
