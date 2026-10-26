class_name AutoTest
extends Node
## Headless smoke test, only active with `-- --autotest` on the command line  (added by Main). Plays three attempts: one with pumping, one without, one that
## swings round to the forced release; optionally saves a screenshot (`--screenshot=<path>`),
## prints a summary and quits.

var _main: Main
var _ticks := 0
var _screenshot_path := ""
var _attempt := 0
var _results: Array[int] = []
var _errors := 0
var _left_next := true


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	Game.persist = false
	_main = get_parent() as Main
	_main.throw_finished.connect(_on_throw_finished)
	print("AUTOTEST start")


func _tap(action: StringName) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _main.phase == Main.Phase.WINDUP:
		match _attempt:
			0, 1:
				# stage 1 at tick 10, stage 2 at tick 30, release at tick 40 (+ pumping in attempt 0)
				if _ticks == 10 or _ticks == 30 or _ticks == 40:
					_tap(&"stage_advance")
				if _attempt == 0 and Game.stage > 0 and _ticks % 2 == 0:
					_tap(&"pump_left" if _left_next else &"pump_right")
					_left_next = not _left_next
			2:
				if _ticks == 10:
					_tap(&"stage_advance")  # then just wait for the arm to swing round (angle < 0)
	if _ticks > 3000:
		push_error("AUTOTEST timeout")
		get_tree().quit(1)


func _on_throw_finished(distance: int, record: bool) -> void:
	print("attempt ", _attempt, ": distance=", distance, " record=", record, " hiscore=", Game.hiscore,
			" stage=", Game.stage, " movement=", Game.movement)
	_results.append(distance)
	if _attempt == 0 and _screenshot_path != "":
		await get_tree().create_timer(0.3).timeout
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)
	_attempt += 1
	if _attempt >= 3:
		print("AUTOTEST done, results=", _results, " errors=", _errors)
		get_tree().quit(0 if _errors == 0 else 1)
		return
	await get_tree().create_timer(0.5).timeout
	_ticks = 0
	_tap(&"stage_advance")  # restart
	await get_tree().create_timer(0.5).timeout
	_ticks = 0
