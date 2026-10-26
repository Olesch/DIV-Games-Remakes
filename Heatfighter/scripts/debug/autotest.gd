class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest` on the command line.
## Plays a match (computer vs computer, or with `--scripted` a scripted player 1 that walks in and
## fires every kind of attack and special move against the computer), counts what happened,
## optionally saves a screenshot (`--screenshot=<path>` at tick `--shot-tick=N`), prints a
## summary and quits.
##   godot --headless --fixed-fps 2 --path . -- --autotest --chars=2,3 --ticks=6000 [--scripted]
## (`--fixed-fps 2` + the raised step limit below simulates 30 ticks per rendered frame.)

var _tick := 0
var _max_ticks := 6000
var _scripted := false
var _screenshot_path := ""
var _shot_tick := 600
var _arena: Arena
var _state_counts: Array[Dictionary] = [{}, {}]
var _last_life: Array[int] = [Defs.START_LIFE, Defs.START_LIFE]
var _hits_taken: Array[int] = [0, 0]
var _max_pause := 0
var _max_shots := 0
var _specials_started := [0, 0]
var _last_state := [0, 0]
var _script_step := 0


func _ready() -> void:
	Engine.max_physics_steps_per_frame = 1000
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
		elif arg.begins_with("--ticks="):
			_max_ticks = int(arg.substr("--ticks=".length()))
		elif arg.begins_with("--shot-tick="):
			_shot_tick = int(arg.substr("--shot-tick=".length()))
		elif arg == "--scripted":
			_scripted = true
	_arena = get_parent() as Arena
	print("AUTOTEST start: chars=", Game.characters, " cpu=", Game.is_cpu, " scripted=", _scripted)


func _physics_process(_delta: float) -> void:
	_tick += 1
	var fighters := _arena.fighters
	if _scripted:
		_drive_player_one(fighters[0])
	for i in 2:
		var f := fighters[i]
		_state_counts[i][f.state] = int(_state_counts[i].get(f.state, 0)) + 1
		if f.life < _last_life[i]:
			_hits_taken[i] += 1
		_last_life[i] = f.life
		if f.state != _last_state[i] and (f.state == Defs.State.SPECIAL_1 or f.state == Defs.State.SPECIAL_2):
			_specials_started[i] += 1
		_last_state[i] = f.state
	_max_pause = maxi(_max_pause, Game.hit_pause)
	_max_shots = maxi(_max_shots, get_tree().get_nodes_in_group(&"shots").size())

	if _screenshot_path != "" and _tick == _shot_tick:
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path)
	if _tick >= _max_ticks or (_arena.round_over and _tick > 600):
		_report()
		get_tree().quit()


## Scripted human: alternates between walking towards the enemy and trying every move.
func _drive_player_one(f: Fighter) -> void:
	for action in [&"p1_left", &"p1_right", &"p1_up", &"p1_down", &"p1_light", &"p1_heavy"]:
		Input.action_release(action)
	var cycle := _tick % 900
	var towards := &"p1_right" if f.opponent.x > f.x else &"p1_left"
	var away := &"p1_left" if towards == &"p1_right" else &"p1_right"
	if cycle < 120:
		Input.action_press(towards)
	elif cycle < 124 and cycle >= 120:
		Input.action_press(&"p1_light")
	elif cycle >= 150 and cycle < 154:
		Input.action_press(&"p1_heavy")
	elif cycle >= 180 and cycle < 200:
		Input.action_press(&"p1_up")
		if cycle >= 190:
			Input.action_press(&"p1_light")
	elif cycle >= 230 and cycle < 260:
		Input.action_press(&"p1_down")
		if cycle >= 240 and cycle < 244:
			Input.action_press(&"p1_light")
		if cycle >= 250 and cycle < 254:
			Input.action_press(&"p1_heavy")
	elif cycle >= 300 and cycle < 330:
		# jump and strike from the air (hold up to exercise Eigen's hover)
		Input.action_press(&"p1_up")
		if cycle >= 312 and cycle < 316:
			Input.action_press(&"p1_heavy")
	elif cycle >= 400 and cycle < 412:
		_special_one_motion(f, cycle - 400, towards, away)
	elif cycle >= 500 and cycle < 512:
		_special_two_motion(f, cycle - 500, towards, away)
	elif cycle >= 600 and cycle < 700:
		Input.action_press(away)
		Input.action_press(&"p1_down")


## Template/Chain: down, back, light.  Eigen: down, forward, light.
func _special_one_motion(f: Fighter, t: int, towards: StringName, away: StringName) -> void:
	var direction := away if f.profile.kind == FighterProfile.Kind.TEMPLATE else towards
	if t < 3:
		Input.action_press(&"p1_down")
	elif t < 6:
		Input.action_press(direction)
	elif t < 9:
		Input.action_press(&"p1_light")


## Eigen: back, down, forward + strong.
func _special_two_motion(_f: Fighter, t: int, towards: StringName, away: StringName) -> void:
	if t < 2:
		Input.action_press(away)
	elif t < 4:
		Input.action_press(&"p1_down")
	elif t < 6:
		Input.action_press(towards)
	elif t < 9:
		Input.action_press(&"p1_heavy")


func _report() -> void:
	var names := Defs.State.keys()
	for i in 2:
		var states := []
		for s: int in _state_counts[i]:
			states.append("%s=%d" % [names[Defs.State.values().find(s)], _state_counts[i][s]])
		var f := _arena.fighters[i]
		print("P%d %s life=%d mana=%d hits_taken=%d specials=%d states: %s" % [
			i + 1, Defs.CHARACTER_NAMES[Game.characters[i]], f.life, f.mana, _hits_taken[i],
			_specials_started[i], ", ".join(states)])
	print("AUTOTEST done: ticks=", _tick, " max_hit_pause=", _max_pause, " max_shots=", _max_shots,
		" round_over=", _arena.round_over)
