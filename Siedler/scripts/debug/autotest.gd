class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest` on the command line.
## Drives the menu with simulated key presses (worker quotas, collection points, building
## sites), lets the colony run for a while at high speed, checks invariants, optionally saves
## a screenshot (`--screenshot=<path>`), prints a summary and quits (never on web).
## Writes nothing to user://.

const RUN_SECONDS := 90.0  # simulated game time

var _steps: Array[Callable] = []
var _wait := 0
var _screenshot_path := ""
var _errors: Array[String] = []
var _start_trees := 0
var _ticks := 0
var _done := false

@onready var _colony: Colony = get_parent().get_node("Colony")
@onready var _cursor: WorldCursor = get_parent().get_node("Cursor")
@onready var _menu: ActionMenu = get_parent().get_node("Hud/MenuBar")


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_start_trees = _colony.trees.size()
	print("AUTOTEST start: settlers=", _colony.settler_count(), " trees=", _start_trees)
	_check(_colony.settler_count() == 10, "expected 10 start settlers")
	_colony.ticked.connect(_on_tick)
	_build_steps()


func _on_tick() -> void:
	_ticks += 1


func _build_steps() -> void:
	# worker quotas: 4 woodcutters, 3 clay diggers
	_keys([KEY_M, KEY_R, KEY_H, KEY_EQUAL, KEY_EQUAL, KEY_EQUAL, KEY_EQUAL, KEY_EQUAL, KEY_MINUS, KEY_A])
	_keys([KEY_M, KEY_R, KEY_L, KEY_KP_ADD, KEY_KP_ADD, KEY_KP_ADD, KEY_A])
	_steps.append(func() -> void:
		_check(Game.wood_workers_max == 4 and Game.clay_workers_max == 3, "worker quotas %d/%d" % [Game.wood_workers_max, Game.clay_workers_max])
		_check(_menu.state == ActionMenu.State.CLOSED, "menu should be closed after (A)bbruch"))
	# aborting a collection point leaves it armed (original bug)
	_keys([KEY_M, KEY_S, KEY_H, KEY_A])
	_steps.append(func() -> void:
		_check(Game.wood_point_pending, "aborted wood point should stay armed (original bug)")
		Game.wood_point_pending = false)
	# wood point in the forest east of the settlers, clay point on the river bank
	_keys([KEY_M, KEY_S, KEY_H])
	_click_at(Vector2i(72, 12))
	_steps.append(func() -> void:
		_check(Game.wood_point == Vector2i(72, 12), "wood point %s" % Game.wood_point)
		_check(_menu.state == ActionMenu.State.POINTS, "menu back at points after click"))
	_keys([KEY_L])
	_click_at(Vector2i(20, 72))
	_keys([KEY_A])
	_steps.append(func() -> void:
		_check(Game.clay_point == Vector2i(20, 72), "clay point %s" % Game.clay_point))
	# two building sites
	_keys([KEY_M, KEY_G, KEY_H])
	_steps.append(func() -> void:
		var c := _free_3x3(Vector2i(60, 16))
		_cursor.position = Vector2(c * Game.CELL) + Vector2(3, 3)
		_cursor.set_held(true))
	_steps.append(func() -> void:
		_cursor.move_by(Vector2(40, 0)))  # dragging paints another site if the ground is free
	_steps.append(func() -> void:
		_cursor.set_held(false)
		_check(Game.houses.size() >= 1, "building site placed")
		_cursor.position = Vector2(150, 120))


func _keys(codes: Array) -> void:
	for code: Key in codes:
		_steps.append(_press.bind(code, true))
		_steps.append(_press.bind(code, false))


func _press(code: Key, pressed: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = pressed
	Input.parse_input_event(ev)


func _click_at(cell: Vector2i) -> void:
	_steps.append(func() -> void:
		_cursor.position = Vector2(cell * Game.CELL) + Vector2(5, 5)
		_cursor.set_held(true))
	_steps.append(func() -> void: _cursor.set_held(false))


func _free_3x3(near: Vector2i) -> Vector2i:
	for r in 30:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var c := near + Vector2i(dx, dy)
				var ok := true
				for y in range(-1, 2):
					for x in range(-1, 2):
						ok = ok and _colony.is_walkable(c + Vector2i(x, y))
				if ok:
					return c
	return near


func _check(ok: bool, what: String) -> void:
	if not ok:
		_errors.append(what)
		push_error("AUTOTEST check failed: " + what)


func _physics_process(_delta: float) -> void:
	if _done:
		return
	if not _steps.is_empty():
		var step: Callable = _steps.pop_front()
		step.call()
		if _steps.is_empty():
			Engine.time_scale = 8.0
			Engine.max_physics_steps_per_frame = 32
		return
	_check_invariants()
	if _ticks * 1.0 / Engine.physics_ticks_per_second >= RUN_SECONDS:
		_finish()


func _check_invariants() -> void:
	var n := _colony.settler_count()
	if n != 10:
		_check(false, "settler count changed to %d at tick %d" % [n, _ticks])
		_done = true


func _finish() -> void:
	_done = true
	Engine.time_scale = 1.0
	var jobs := {}
	for i: int in _colony.sprites:
		var job: int = _colony.logic[i]
		jobs[Colony.Job.find_key(job)] = jobs.get(Colony.Job.find_key(job), 0) + 1
	var felled := _start_trees - _colony.trees.size()
	print("AUTOTEST jobs after %d ticks: %s" % [_ticks, jobs])
	print("AUTOTEST trees felled=", felled, " wood_workers=", Game.wood_workers, " clay_workers=",
		Game.clay_workers, " building sites=", Game.houses.size(), " stop_latch=", Game.stop_latch)
	var t0 := Time.get_ticks_usec()
	for k in 24:
		_colony.sweep()
	print("AUTOTEST avg sweep: %.2f ms" % ((Time.get_ticks_usec() - t0) / 24000.0))
	_check(Game.wood_workers + Game.clay_workers > 0, "some settlers took a job")
	if _screenshot_path != "":
		_keys([KEY_M, KEY_G, KEY_H])
		await _run_steps_now()
		_cursor.position = Vector2(690, 150)
		for i in 10:
			await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path)
	if _errors.is_empty():
		print("AUTOTEST PASSED")
	else:
		print("AUTOTEST FAILED: ", _errors)
	if not OS.has_feature("web"):
		get_tree().quit(0 if _errors.is_empty() else 1)


func _run_steps_now() -> void:
	while not _steps.is_empty():
		var step: Callable = _steps.pop_front()
		step.call()
		await get_tree().physics_frame


## Average position of the settlers (world pixels), for the screenshot framing.
func _colony_center() -> Vector2:
	var sum := Vector2.ZERO
	for i: int in _colony.sprites:
		@warning_ignore("integer_division")
		sum += Vector2(i % Game.MAP_W, i / Game.MAP_W) * Game.CELL
	return sum / maxf(1.0, _colony.sprites.size())
