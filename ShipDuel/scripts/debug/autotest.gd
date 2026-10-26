class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest` on the command line.
## 1. fires a probe shot at the wall and checks that it bounces (angle mirrored, shot still alive),
## 2. lets all four ships hold their fire keys while turning, uses explosion shots and settings
##    variations, 3. prints a summary and quits. `--screenshot=<path>` saves a picture (optionally
##    `--screenshot-at=<seconds>`), `--keep-running` disables the early exit.

var _ticks := 0
var _shots_fired := 0
var _exploshots_fired := 0
var _deaths := 0
var _max_shots := 0
var _max_explosions := 0
var _probe: Shot
var _probe_start_angle := 0
var _probe_bounced := false
var _failures: Array[String] = []
var _screenshot_path := ""
var _screenshot_at := 6.0
var _screenshot_done := false
var _arena: Node


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
		elif arg.begins_with("--screenshot-at="):
			_screenshot_at = float(arg.substr("--screenshot-at=".length()))
	Engine.time_scale = 3.0 if _screenshot_path == "" else 1.0
	_arena = get_parent()
	for ship: Ship in get_tree().get_nodes_in_group(&"ships"):
		ship.fired.connect(_on_fired)
		ship.died.connect(_on_died)
	print("AUTOTEST start, settings: lives=", Game.max_hits, " shield=", Game.shield_mode)
	# probe: a shot fired to the left from the screen centre, no ship is on that line
	_probe_start_angle = 180000
	_probe = Shot.spawn(_arena.get_node("Shots"), Vector2(400, 240), _probe_start_angle, 0)


func _on_fired(weapon: Defs.Weapon, _origin: Vector2, _angle: int, _owner: int) -> void:
	if weapon == Defs.Weapon.SHOT:
		_shots_fired += 1
	else:
		_exploshots_fired += 1


func _on_died(_owner: int) -> void:
	_deaths += 1


func _physics_process(_delta: float) -> void:
	_ticks += 1
	_max_shots = maxi(_max_shots, get_tree().get_nodes_in_group(&"shots").size())
	_max_explosions = maxi(_max_explosions, get_tree().get_nodes_in_group(&"explosions").size())

	if is_instance_valid(_probe) and not _probe_bounced:
		if _probe.angle != _probe_start_angle:
			_probe_bounced = true
	if _ticks == 90:
		if not _probe_bounced:
			_failures.append("probe shot never touched the wall")
		elif not is_instance_valid(_probe):
			_failures.append("probe shot died on its first wall contact")
		else:
			var reflected := posmod(_probe.angle, 360000)
			if reflected != 0:
				_failures.append("probe angle after bounce = %d, expected 0" % reflected)
			print("probe bounce ok: angle=", _probe.angle, " pos=", _probe._pos)

	# from tick 100 on the ships play: everyone holds the shoot key, ships 1/3 turn right, 2/4 left
	if _ticks == 100:
		for p in [&"p1", &"p2", &"p3", &"p4"]:
			Input.action_press(StringName(str(p) + "_shoot"))
		Input.action_press(&"p1_right")
		Input.action_press(&"p3_right")
		Input.action_press(&"p2_left")
		Input.action_press(&"p4_left")
	if _ticks == 330:
		Input.action_release(&"p2_shoot")
		Input.action_release(&"p4_shoot")
	if _ticks == 400:
		# the "mana" attack for ships 2 and 4 (ships 1/3 keep shooting normally)
		Input.action_press(&"p2_mana")
		Input.action_press(&"p4_mana")
	if _ticks == 420:
		Input.action_release(&"p2_mana")
		Input.action_release(&"p4_mana")

	if _screenshot_path != "" and not _screenshot_done and _ticks >= int(_screenshot_at * Defs.FPS):
		_screenshot_done = true
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path)

	var limit := 1800
	if _ticks >= limit or (_deaths >= 3 and _ticks > 600 and not "--keep-running" in OS.get_cmdline_user_args()):
		_finish()


func _finish() -> void:
	if _shots_fired < 10:
		_failures.append("too few shots fired: %d" % _shots_fired)
	if _exploshots_fired < 1:
		_failures.append("no explosion shot fired")
	print("AUTOTEST done: ticks=", _ticks, " shots_fired=", _shots_fired, " exploshots=", _exploshots_fired,
		" deaths=", _deaths, " max_shots=", _max_shots, " max_explosions=", _max_explosions,
		" ships_left=", get_tree().get_nodes_in_group(&"ships").size(),
		" lives=", get_tree().get_nodes_in_group(&"ships").map(func(s: Ship) -> int: return s.lives))
	if _failures.is_empty():
		print("AUTOTEST PASS")
	else:
		for failure in _failures:
			print("AUTOTEST FAIL: ", failure)
	get_tree().quit()
