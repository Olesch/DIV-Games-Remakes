class_name AutoTest
extends Node
## Debug smoke test, only added by the Game autoload when `-- --autotest` is on the command line.
## For every level: loads it, steers with simulated key presses, uses R, then teleports the ball onto a
## win pixel (and on a death pixel where the level has one) and checks results and the saved best times.
## With `--screenshot=<path>` it only plays level 18 for a while, saves a screenshot and quits.
## Prints a summary and quits with exit code 0 (ok) or 1 (failed).

const TICKS_PER_LEVEL := 120

var _tick := 0
var _failures := 0
var _screenshot_path := ""
var _world: World
var _death_levels: Array[int] = []
var _phase_level := 0
var _recall_tested := false


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	if not _screenshot_path.is_empty():
		Game.start_level.call_deferred(Game.DEFAULT_LEVEL_INDEX)
	print("AUTOTEST start")


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("AUTOTEST FAIL: ", what)


func _physics_process(_delta: float) -> void:
	if not _screenshot_path.is_empty():
		_run_screenshot()
	else:
		_run_levels()
	_tick += 1


func _run_screenshot() -> void:
	if _tick == 3:
		Input.action_press(&"move_right")
	elif _tick == 50:
		Input.action_release(&"move_right")
		Input.action_press(&"move_down")
	elif _tick == 75:
		Input.action_release(&"move_down")
	elif _tick == 100:
		_save_screenshot()


func _save_screenshot() -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_screenshot_path)
	print("AUTOTEST screenshot saved ", _screenshot_path)
	get_tree().quit()


func _run_levels() -> void:
	var level_count := Game.LEVELS.size()
	var index := _tick / TICKS_PER_LEVEL
	var local := _tick % TICKS_PER_LEVEL
	if index >= level_count + _death_levels.size():
		_finish()
		return
	var is_death_run := index >= level_count
	var level_index: int = _death_levels[index - level_count] if is_death_run else index
	var info: Dictionary = Game.LEVELS[level_index]
	match local:
		0:
			Game.start_level(level_index)
		5:
			_world = get_tree().current_scene as World
			_check(_world != null, "game scene is a World for level %d" % info["code"])
			if _world == null:
				return
			var t := _world.level
			print("level %d: speedup=%d speedmul=%d yellow=%d gravity=%d friction=%d purple=%d" % [
					info["code"], t.speedup, t.speedmul, t.yellow_strength, t.gravity, t.friction, t.purple_strength])
			if not is_death_run and _find_pixel(t, LevelMap.DEATH) != Vector2i(-1, -1):
				_death_levels.append(level_index)
			Input.action_press(&"move_right")
			Input.action_press(&"move_down")
		105:
			Input.action_release(&"move_right")
			Input.action_release(&"move_down")
			_check(_world.guide.vel != Vector2i.ZERO and _world.time >= 40, "guide moves, time runs (time=%d)" % _world.time)
			print("  after steering: guide=", _world.guide.pos / 100, " ball=", _world.ball.pos / 100, " time=", _world.time)
		106:
			_recall_tested = not is_death_run and not _world.ball.is_finished
			if _recall_tested:
				_phase_level = _world.time
				Input.action_press(&"recall_ball")
		108:
			if _recall_tested:
				Input.action_release(&"recall_ball")
				_check(_world.guide.pos.distance_to(_world.ball.pos) < 3000.0, "recall pulled the guide to the ball")
				_check(_world.time >= _phase_level + 24, "recall costs 24 frames")
		110:
			if _world.ball.is_finished:
				print("  (ball finished by itself: '", _world.result, "'; restarting level)")
				Game.start_level(level_index)
		112:
			_world = get_tree().current_scene as World
			var kind := LevelMap.DEATH if is_death_run else LevelMap.WIN
			var target := _find_pixel(_world.level, kind)
			_check(target != Vector2i(-1, -1), "level %d has a pixel of kind %d" % [info["code"], kind])
			var p := target * 100 + Vector2i(50, 50)
			_world.guide.teleport_to(p)
			_world.ball.pos = p
			_world.ball.vel = Vector2i.ZERO
		116:
			if is_death_run:
				_check(_world.result == "You LOOSE", "death result at level %d (got '%s')" % [info["code"], _world.result])
			else:
				_check(_world.result == "You WIN!", "win result at level %d (got '%s')" % [info["code"], _world.result])
				_check(Game.hi_time(info["code"]) > 0 and Game.hi_time(info["code"]) <= _world.time,
						"best time stored for level %d" % info["code"])
			print("  result='", _world.result, "' time=", _world.time, " best=", Game.hi_time(info["code"]))


func _find_pixel(map: LevelMap, kind: int) -> Vector2i:
	var i := map.data.find(kind, map.width * 2)
	if i < 0:
		return Vector2i(-1, -1)
	return Vector2i(i % map.width, i / map.width)


func _finish() -> void:
	# the save file must contain 31 ints with the new best times
	var f := FileAccess.open(Game.save_path, FileAccess.READ)
	_check(f != null and f.get_length() == Game.HI_TIMES_COUNT * 4, "save file written")
	if f:
		var reloaded := PackedInt32Array()
		for i in Game.HI_TIMES_COUNT:
			reloaded.append(f.get_32())
		_check(reloaded == Game.hi_times, "saved best times match memory")
	print("AUTOTEST done, failures=", _failures)
	get_tree().quit(1 if _failures > 0 else 0)
