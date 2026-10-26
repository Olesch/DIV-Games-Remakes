class_name AutoTest
extends Node
## Automated smoke test, only active with `-- --autotest` (Game then also stops writing the topscore file).
## A bot steers the worm to three apples, then the test crashes it into the frame, checks the restart,
## and finally makes it bite itself. Optional `--screenshot=<path>` saves a gameplay image.
## Prints a summary and quits (never on the web build).

enum Phase { EAT, WALL, WAIT_RESTART, SELF_BITE, WAIT_SELF, DONE }

var _phase := Phase.EAT
var _worm: Worm
var _screenshot_path := ""
var _failures := 0
var _crashes := 0
var _eaten_goal := 3
var _start_length := 0
var _ticks := 0
var _timeout := 0.0
var _self_script := [&"move_down", &"move_left", &"move_up"]
var _self_step := 0
var _input_checked := false


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_worm = get_tree().get_first_node_in_group(&"worm") as Worm
	_worm.crashed.connect(func() -> void:
		_crashes += 1)
	Game.worm_length = 20     # a longer worm for the screenshot
	_start_length = Game.worm_length
	print("AUTOTEST start (persist=", Game.persist, ")")
	_input_path_check()


## Real input path: an InputEventAction must reach Worm._unhandled_input.
func _input_path_check() -> void:
	_send_action_event(&"move_down")
	await get_tree().create_timer(0.2).timeout
	if _worm.direction == Vector2i(0, Game.STEP) or _worm.direction.y > 0:
		_check(true, "input action event steers the worm")
	elif DisplayServer.get_name() == "headless":
		_check(false, "input action event steers the worm")
	else:
		print("SKIP input action event check (window not receiving injected events)")
	_worm.steer(Vector2i(Game.STEP, 0))
	_input_checked = true


func _physics_process(delta: float) -> void:
	_timeout += delta
	if _timeout > 60.0:
		_check(false, "timeout in phase " + Phase.keys()[_phase])
		_finish()
		return
	if not _input_checked:
		return
	match _phase:
		Phase.EAT:
			_bot_step()
			if Game.score >= Game.POINTS_PER_APPLE * _eaten_goal:
				_check(Game.score == 60, "score after 3 apples is 60 (got %d)" % Game.score)
				_check(Game.worm_length == _start_length + 3, "length grew by 3")
				_check(Game.apples == 1 or Game.apples == 0, "one apple at a time (apples=%d)" % Game.apples)
				_save_screenshot()
				_phase = Phase.WALL
				# put the head in front of the frame's left wall, heading right
				_worm.head = Vector2i(144, 200) - Game.field_origin()
				_press(&"move_right")
		Phase.WALL:
			if _crashes >= 1:
				_check(true, "crashed into the wall")
				_phase = Phase.WAIT_RESTART
		Phase.WAIT_RESTART:
			if Game.score == 0 and Game.worm_length == Game.START_LENGTH and _worm.active:
				_check(Game.topscore == 60, "topscore kept (%d)" % Game.topscore)
				_check(_worm.head.y == Game.START_CELL.y and _worm.head.x <= Game.START_CELL.x + Game.STEP, "worm restarted at the start cell")
				_phase = Phase.SELF_BITE
				_self_step = 0
				_ticks = 0
				Game.worm_length = 30
		Phase.SELF_BITE:
			# right (initial) -> down -> left -> up: the head returns onto the start cell, which the body occupies
			if _self_step < _self_script.size():
				_press(_self_script[_self_step])
				_self_step += 1
			else:
				_phase = Phase.WAIT_SELF
		Phase.WAIT_SELF:
			if _crashes >= 2:
				_check(true, "bit its own body")
				_phase = Phase.DONE
				_finish()


## Chase the current apple: pick the one of the 8 move actions pointing at it.
func _bot_step() -> void:
	var apples := get_tree().get_nodes_in_group(&"apples")
	# no apple yet (a new one appears next tick): keep going straight, but not into a wall
	var target := _worm.head + _worm.direction
	if not apples.is_empty():
		var apple := apples[0] as Apple
		# without FIT_TO_FRAME some apples lie inside the closed frame, unreachable without dying:
		# move them out into the open (test only)
		if Rect2i(Game.BACKGROUND_POS, Vector2i(320, 200)).has_point(Vector2i(apple.position) + Game.field_origin()) 				and Game.field_origin() == Vector2i.ZERO:
			apple.position = Vector2(randi_range(1, 18) * 8, randi_range(3, 8) * 8)
		target = Vector2i(apple.position)
	var s := Game.STEP
	var best := Vector2i.ZERO
	var best_dist := INF
	# the 8 possible moves, skipping those that kill the worm; take the one closest to the apple
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var cell := _worm.head + Vector2i(dx * s, dy * s)
			if _worm.is_deadly(cell):
				continue
			var dist := Vector2(cell).distance_to(Vector2(target))
			if dist < best_dist:
				best_dist = dist
				best = Vector2i(dx * s, dy * s)
	if best != Vector2i.ZERO:
		_worm.steer(best)


func _press(action: StringName) -> void:
	# direct call: parse_input_event is unreliable in an unfocused window (the real key path is
	# checked headless in _input_path_check)
	var s := Game.STEP
	var dirs := {
		&"move_right": Vector2i(s, 0), &"move_left": Vector2i(-s, 0),
		&"move_down": Vector2i(0, s), &"move_up": Vector2i(0, -s),
		&"move_up_right": Vector2i(s, -s), &"move_up_left": Vector2i(-s, -s),
		&"move_down_left": Vector2i(-s, s), &"move_down_right": Vector2i(s, s),
	}
	_worm.steer(dirs[action])


func _send_action_event(action: StringName) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)


func _check(ok: bool, what: String) -> void:
	print(("PASS " if ok else "FAIL ") + what)
	if not ok:
		_failures += 1


func _save_screenshot() -> void:
	if _screenshot_path == "":
		return
	var image := get_viewport().get_texture().get_image()
	if image:
		image.save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)


func _finish() -> void:
	var leftover := FileAccess.file_exists(Game.SAVE_PATH)
	_check(not leftover, "no save file left in user://")
	print("AUTOTEST done: failures=", _failures)
	if not OS.has_feature("web"):
		get_tree().quit(1 if _failures > 0 else 0)
