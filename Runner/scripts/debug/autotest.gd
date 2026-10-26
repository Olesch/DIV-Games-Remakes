class_name AutoTest
extends Node
## Smoke test, active with `-- --autotest` (optionally `--screenshot=<path>`).
## Player 1 false-starts, player 2 waits for LOS and then alternates A/D until the finish.

var _tick := 0
var _screenshot_path := ""
var _shot_done := false
var _game: Node
var _p2_left := true


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_game = get_tree().current_scene
	print("AUTOTEST start")


func _press(action: StringName, down: bool) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = down
	Input.parse_input_event(ev)


func _physics_process(_delta: float) -> void:
	_tick += 1
	var p1: Runner = _game.get_node("RunnerRight")
	var p2: Runner = _game.get_node("RunnerLeft")
	if _tick == 10:
		_press(&"p1_left", true)  # false start
	if _tick == 14:
		_press(&"p1_left", false)
	if _game.phase >= 2 and _tick % 2 == 0:  # alternate keys every other tick
		_press(&"p2_left" if _p2_left else &"p2_right", true)
		_press(&"p2_right" if _p2_left else &"p2_left", false)
		_p2_left = not _p2_left
	if _screenshot_path != "" and not _shot_done and _tick == 150:
		_shot_done = true
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)
	if _game.finished or _tick > 1500:
		print("AUTOTEST done: tick=", _tick, " p1 foul=", p1.is_foul, " x=", p1.position.x,
			" p2 won=", p2.has_won, " x=", p2.position.x, " time=", _game.seconds, ":", _game.ticks)
		var ok: bool = p1.is_foul and p1.position.x == 40.0 and p2.has_won
		print("AUTOTEST ", "PASS" if ok else "FAIL")
		get_tree().quit(0 if ok else 1)
