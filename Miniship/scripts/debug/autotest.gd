class_name AutoTest
extends Node
## Headless smoke test, active with `-- --autotest` (start the menu scene; this node then drives it).
## Plays several computer-only matches (all laser types, play types, particle settings, asteroids),
## presses the human input actions once, prints a summary and quits.
## godot --headless --fixed-fps 30 --path . -- --autotest

const WORLD_SCENE := "res://scenes/world.tscn"

# [name, ship modes, play_type, laser, load, particles, asteroids, gravity, max_energy, ticks]
var _scenarios: Array[Dictionary] = [
	{"name": "standard laser, 4 PCs, asteroids", "modes": [2, 3, 4, 5], "play": 0, "laser": 0, "load": 2, "particles": 2, "asteroids": 6, "gravity": 8000, "energy": 1000, "ticks": 1500},
	{"name": "simple, lasershot", "modes": [5, 5, 0, 0], "play": 1, "laser": 2, "load": 3, "particles": 1, "asteroids": 3, "gravity": 12000, "energy": 600, "ticks": 900},
	{"name": "flag game, machine laser", "modes": [3, 4, 5, 2], "play": 2, "laser": 3, "load": 2, "particles": 1, "asteroids": 2, "gravity": 8000, "energy": 800, "ticks": 2400},
	{"name": "spreader, no particles", "modes": [5, 2, 0, 0], "play": 0, "laser": 4, "load": 4, "particles": 0, "asteroids": 0, "gravity": 3000, "energy": 3000, "ticks": 900},
	{"name": "sniper", "modes": [5, 5, 5, 0], "play": 0, "laser": 5, "load": 1, "particles": 1, "asteroids": 9, "gravity": 16000, "energy": 200, "ticks": 900},
	{"name": "gravit laser, durable", "modes": [4, 4, 0, 0], "play": 0, "laser": 6, "load": 0, "particles": 2, "asteroids": 1, "gravity": 8000, "energy": 1000, "ticks": 600},
	{"name": "durable laser", "modes": [5, 5, 0, 0], "play": 0, "laser": 1, "load": 2, "particles": 1, "asteroids": 0, "gravity": 8000, "energy": 1000, "ticks": 600},
	{"name": "human keys", "modes": [1, 1, 0, 0], "play": 0, "laser": 0, "load": 3, "particles": 1, "asteroids": 2, "gravity": 8000, "energy": 1000, "ticks": 400, "human": true},
]

var _index := -1
var _ticks := 0
var _limit := 0
var _human := false
var _waiting_for_world := false
var _stats := {"shots": 0, "rockets": 0, "max_particles": 0, "shielded": 0, "teleports": 0, "points": 0,
	"deaths": 0, "carriers": 0, "asteroid_hits": 0}
var _prev_alive := 0
var _last_pos := {}
var _errors := 0


func _ready() -> void:
	Engine.max_fps = 0
	print("AUTOTEST start")
	_input_check()
	_next_scenario()


func _input_check() -> void:
	# Right shift must fire player 0 only, left shift player 1 only
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_SHIFT
	ev.location = KEY_LOCATION_RIGHT
	ev.pressed = true
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	print("input: right shift -> p0_fire=", Input.is_action_pressed(&"p0_fire"), " p1_fire=", Input.is_action_pressed(&"p1_fire"))
	ev = ev.duplicate()
	ev.pressed = false
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	ev = ev.duplicate()
	ev.location = KEY_LOCATION_LEFT
	ev.pressed = true
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	print("input: left shift -> p0_fire=", Input.is_action_pressed(&"p0_fire"), " p1_fire=", Input.is_action_pressed(&"p1_fire"))
	ev = ev.duplicate()
	ev.pressed = false
	Input.parse_input_event(ev)
	Input.flush_buffered_events()


func _next_scenario() -> void:
	_index += 1
	if _index >= _scenarios.size():
		_finish()
		return
	var sc := _scenarios[_index]
	for i in 4:
		Game.ship_mode[i] = sc["modes"][i]
	Game.play_type = sc["play"]
	Game.laser_type = sc["laser"]
	Game.load_type = sc["load"]
	Game.particles = sc["particles"]
	Game.asteroids = sc["asteroids"]
	Game.gravity = sc["gravity"]
	Game.max_energy = sc["energy"]
	_limit = sc["ticks"]
	_human = sc.get("human", false)
	_ticks = 0
	_prev_alive = 0
	_last_pos.clear()
	_waiting_for_world = true
	print("-- scenario ", _index, ": ", sc["name"])
	get_tree().change_scene_to_file(WORLD_SCENE)


func _physics_process(_delta: float) -> void:
	if _index >= _scenarios.size():
		return
	var world := get_tree().current_scene as World
	if world == null or not is_instance_valid(Game.planet):
		return
	_waiting_for_world = false
	_ticks += 1
	_sample(world)
	if _human:
		_drive_human()
	if _ticks >= _limit:
		if _human:
			_release_human()
		print("   ticks=", _ticks, " points=", Game.points, " alive=", Game.alive_ships().size(), " phase=", world.phase)
		_next_scenario()


func _sample(world: World) -> void:
	_stats["shots"] = maxi(_stats["shots"], get_tree().get_nodes_in_group(&"shots").size())
	_stats["rockets"] = maxi(_stats["rockets"], get_tree().get_nodes_in_group(&"rockets").size())
	if Game.effects:
		_stats["max_particles"] = maxi(_stats["max_particles"], Game.effects.particle_count())
	for ship in Game.alive_ships():
		if ship.shielded:
			_stats["shielded"] += 1
		if _last_pos.has(ship.player):
			var d: Vector2 = Vector2(ship.px, ship.py) - _last_pos[ship.player]
			if d.length() > 20000.0 and absf(d.x) < 70000.0 and absf(d.y) < 50000.0:
				_stats["teleports"] += 1
		_last_pos[ship.player] = Vector2(ship.px, ship.py)
	if is_instance_valid(Game.follow):
		_stats["carriers"] += 1
	var alive := Game.alive_ships().size()
	if alive < _prev_alive:
		_stats["deaths"] += _prev_alive - alive
	_prev_alive = alive
	_stats["points"] = maxi(_stats["points"], Game.points.reduce(func(a, b): return a + b, 0))
	if world.phase == World.Phase.PLAYING and _ticks % 300 == 0:
		print("   t=", _ticks, " alive=", alive, " points=", Game.points, " energy=", Game.alive_ships().map(func(s): return s.energy))


func _drive_human() -> void:
	# tick phases: thrust, turn, shield (both turn keys), rocket (shield + fire), laser
	var t := _ticks % 100
	_hold(&"p0_thrust", t < 60)
	_hold(&"p0_right", t >= 20 and t < 40 or t >= 70 and t < 90)
	_hold(&"p0_left", t >= 70 and t < 90)
	_hold(&"p0_fire", t >= 5 and t < 15 or t >= 75 and t < 85)
	_hold(&"p1_thrust", t < 30)
	_hold(&"p1_left", t >= 50 and t < 60)
	_hold(&"p1_fire", t >= 40 and t < 50)


func _release_human() -> void:
	for p in 2:
		for a in ["thrust", "right", "left", "fire"]:
			Input.action_release(StringName("p%d_%s" % [p, a]))


func _hold(action: StringName, on: bool) -> void:
	if on:
		Input.action_press(action)
	else:
		Input.action_release(action)


func _finish() -> void:
	print("AUTOTEST summary: ", _stats)
	print("AUTOTEST done")
	get_tree().quit()
