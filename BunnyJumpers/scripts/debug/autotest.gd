class_name AutoTest
extends Node
## Headless smoke test, only with `-- --autotest` (optional `--screenshot=<path>`).
## Bunny 1 runs right while jumping, bunny 2 runs left while jumping; checks that both land,
## jump, stay on screen, and reports how often horizontal direction changed (walls / bunny bounces).

var _ticks := 0
var _screenshot_path := ""
var _landed := [false, false]
var _jumped := [false, false]
var _turns := 0
var _bunnies: Array[Bunny] = []
var _last_speed := [0, 0]


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	for prefix in ["p1", "p2"]:  # the player bunnies (extra bunnies, if any, have no prefix)
		for n in get_tree().get_nodes_in_group(&"bunnies"):
			if (n as Bunny).action_prefix == prefix:
				_bunnies.append(n as Bunny)
	print("AUTOTEST start, bunnies=", get_tree().get_nodes_in_group(&"bunnies").size())


func _physics_process(_delta: float) -> void:
	_ticks += 1
	Input.action_press(&"p1_right")
	Input.action_press(&"p1_up")
	Input.action_press(&"p2_left")
	Input.action_press(&"p2_up")
	for i in 2:
		var b := _bunnies[i]
		if b.standing:
			_landed[i] = true
		if b.y_speed <= -20:
			_jumped[i] = true
		if b.x < 0 or b.x > 1024 or b.y < 0 or b.y > 768:
			push_error("bunny %d left the screen at %d,%d" % [i, b.x, b.y])
		if (_last_speed[i] > 0 and b.x_speed < 0) or (_last_speed[i] < 0 and b.x_speed > 0):
			_turns += 1
		_last_speed[i] = b.x_speed
	if _screenshot_path != "" and _ticks == 40:
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path)
	if _ticks >= 24 * 20:
		print("AUTOTEST done: landed=", _landed, " jumped=", _jumped, " direction_changes=", _turns,
			" pos=", [Vector2i(_bunnies[0].x, _bunnies[0].y), Vector2i(_bunnies[1].x, _bunnies[1].y)])
		var ok: bool = _landed[0] and _landed[1] and _jumped[0] and _jumped[1]
		print("AUTOTEST ", "PASS" if ok else "FAIL")
		get_tree().quit(0 if ok else 1)
