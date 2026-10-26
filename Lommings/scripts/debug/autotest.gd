class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest` on the command line.
## Exercises every skill with simulated mouse clicks, the nuke, pause/turbo, level transitions through all
## levels to the end screen. Optional `--screenshot=<path>`; prints a summary and quits.

var _level: Level
var _tick := 0
var _screenshot_path := ""
var _shot_done := false
var _skill := 1
var _levels_seen := {}
var _clicks := 0
var _skills_used := {}


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_level = get_parent() as Level
	print("AUTOTEST start")


func _physics_process(_delta: float) -> void:
	_tick += 1
	_levels_seen[Game.level_counter] = true
	# give plenty of every skill so each one is exercised
	if _tick % 50 == 1:
		for i in range(1, 10):
			Game.skill_counts[i] = maxi(Game.skill_counts[i], 3)
	# every 6 ticks: pick a live lemming, select the next skill, click it (alternating left / right)
	if "--noclick" in OS.get_cmdline_user_args():
		Game.turbo_extra = 4
		if _tick % 100 == 0:
			var st := {}
			for l in _level.lemmings:
				st[Lemming.State.keys()[l.state]] = st.get(Lemming.State.keys()[l.state], 0) + 1
			print("t=", _tick, " time=", Game.time_left, " ", st)
		return
	if _tick % 6 == 0:
		var live: Array[Lemming] = []
		for l in _level.lemmings:
			if l.state != Lemming.State.IDLE and l.state != Lemming.State.DEAD and l.state != Lemming.State.SAVED:
				live.append(l)
		if not live.is_empty():
			var l: Lemming = live[randi() % live.size()]
			Game.selected_skill = _skill as Defs.Skill
			_skill = _skill % 9 + 1
			_level.debug_mouse = Vector2i(l.cell.x + _level.scroll_x, l.cell.y)
			var left := (_tick / 6) % 3 != 0
			if left:
				Input.action_press(&"click_left")
				Input.action_release(&"click_right")
			else:
				Input.action_press(&"click_right")
				Input.action_release(&"click_left")
			_clicks += 1
			_skills_used[Game.selected_skill] = true
	elif _tick % 6 == 3:
		Input.action_release(&"click_left")
		Input.action_release(&"click_right")
	if _tick == 200:
		Game.turbo_extra = 4
	if _tick == 400:
		Game.turbo_extra = 0
		Game.paused = true
	if _tick == 410:
		Game.paused = false
	if _tick == 600:
		Input.action_press(&"nuke")
		Input.action_release(&"nuke")
		var ev := InputEventAction.new()
		ev.action = &"nuke"
		ev.pressed = true
		Input.parse_input_event(ev)
	if _screenshot_path != "" and not _shot_done and _tick == 330:
		_shot_done = true
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path, " err=", image.save_png(_screenshot_path))
		else:
			print("screenshot: no image")
	# after a while hold the O+G cheat for a tick so the level is won and the next one loads
	if _tick > 700 and _tick % 120 == 0 and Game.level_counter < Defs.LEVEL_ORDER.size() - 1:
		Input.action_press(&"turbo")
		Input.action_press(&"cheat_g")
	if _tick > 700 and _tick % 120 == 2:
		Input.action_release(&"turbo")
		Input.action_release(&"cheat_g")
	if Game.level_counter >= Defs.LEVEL_ORDER.size() - 1 and _tick % 10 == 0:
		_finish()
	if _tick > 6000:
		_finish()


func _finish() -> void:
	var states := {}
	for l in _level.lemmings:
		states[Lemming.State.keys()[l.state]] = states.get(Lemming.State.keys()[l.state], 0) + 1
	print("AUTOTEST done: tick=", _tick, " level_counter=", Game.level_counter, " levels_seen=",
		_levels_seen.size(), " clicks=", _clicks, " skills_used=", _skills_used.size(),
		" saved=", Game.saved, " time=", Game.time_left, " states=", states)
	get_tree().quit()
