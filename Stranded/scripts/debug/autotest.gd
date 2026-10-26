extends Node
## Headless/automated smoke test (`-- --autotest [--screenshot=file.png]`).
## Walks the hero around, searches, takes, eats, plants, combines, sleeps through a night and
## prints a summary. Input goes through InputEventAction so the real input handlers run.

var _screenshot_path := ""
var _elapsed := 0.0
var _step := 0
var _next := 0.5
var _shot_done := false
var _errors := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	if "--tour" in OS.get_cmdline_user_args():
		_tour()
		return
	print("AUTOTEST start; start cell ", Game.hero_cell, " field ", Game.island.get_field(Game.hero_cell))
	# give the hero some stock so every branch runs
	Game.grain = 6
	Game.berries = 2
	Game.herb = 1
	Game.stone = 3
	Game.branch = 2
	Game.vine = 2
	Game.flour = 1


## `--tour`: only walk (right, then down) so that the radar uncovers a trail; for screenshots.
func _tour() -> void:
	set_process(false)
	_press(&"move_up")
	await get_tree().create_timer(6.0).timeout
	_press(&"move_up", false)
	_press(&"move_left")
	await get_tree().create_timer(3.0).timeout
	_press(&"move_left", false)
	Game.say("2 Getreide gefunden!")
	await get_tree().create_timer(0.5).timeout
	get_viewport().get_texture().get_image().save_png(_screenshot_path)
	print("tour screenshot saved at cell ", Game.hero_cell)
	get_tree().quit()


func _press(action: StringName, pressed: bool = true) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	Input.parse_input_event(ev)


func _tap(action: StringName) -> void:
	_press(action, true)
	_press(action, false)


func _check(cond: bool, what: String) -> void:
	if not cond:
		_errors += 1
		print("AUTOTEST FAIL: ", what)


func _process(delta: float) -> void:
	_elapsed += delta
	if _screenshot_path != "" and not _shot_done and _elapsed > 6.0:
		_shot_done = true
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)
	if _elapsed < _next:
		return
	_next = _elapsed + 0.6
	_step += 1
	match _step:
		1:  # walk up onto the spring cell (a spring is directly above the start)
			_press(&"move_up")
			_next = _elapsed + 0.1   # one cell takes 5 frames = 0.21 s: release before the second
		2:
			_press(&"move_up", false)
			_next = _elapsed + 0.4
		3:
			_check(Game.hero_cell == Island.START_CELL + Vector2i(0, -1), "walked onto the spring cell")
			_check(Game.island.get_object(Game.hero_cell) == Island.SPRING, "spring object under hero")
			_tap(&"mode_use")
			_tap(&"item_8")   # flour -> dough at the spring
			_next = _elapsed + 0.3
		4:
			_check(Game.dough == 1 and Game.flour == 0, "dough made at the spring")
			_press(&"item_8", false)
			_tap(&"mode_eat")
			_tap(&"item_9")
			_tap(&"take")     # drink from spring
		5:
			_press(&"move_down")
			_next = _elapsed + 0.15
		6:
			_press(&"move_down", false)
			_next = _elapsed + 0.4
		7:
			_press(&"move_right")
			_next = _elapsed + 0.15
		8:
			_press(&"move_right", false)
			_next = _elapsed + 0.4
		9:
			_tap(&"take")     # grain at right of start
			_next = _elapsed + 0.3
		10:
			_check(Game.grain >= 8, "took grain (+2) cell=%s obj=%d grain=%d" % [Game.hero_cell, Game.island.get_object(Game.hero_cell), Game.grain])
			_tap(&"mode_combine")
			_press(&"item_1")
			_press(&"item_4")
			_next = _elapsed + 0.3
		11:
			_press(&"item_1", false)
			_press(&"item_4", false)
			_check(Game.flour_listed and Game.flour == 1, "flour combined")
			_press(&"item_3")
			_press(&"item_4")
			_press(&"item_6")
			_next = _elapsed + 0.3
		12:
			_press(&"item_3", false)
			_press(&"item_4", false)
			_press(&"item_6", false)
			_check(Game.axe == 1, "axe combined")
			_tap(&"mode_use")
			_tap(&"item_1")   # plant (only on empty grass; harmless otherwise)
			_tap(&"mode_eat")
			_tap(&"item_1")
			_tap(&"item_2")
			_tap(&"item_7")
			_tap(&"search")
			_next = _elapsed + 4.5
		13:
			_check(not Game.searching, "search finished")
			_tap(&"sleep")   # too early at the beginning of the day
		14:
			Game.sun_x = 760   # late in the day
			_tap(&"sleep")
			_next = _elapsed + 0.8
		15:
			_check(Game.night_stop, "night began")
			_next = _elapsed + 2.5
		16:
			_check(not Game.night_stop, "night ended")
			_check(Game.sun_x <= Game.SUN_START + 8, "new day")
			Game.hunger = 0
			Game.thirst = 0
			Game.health = 1
			_next = _elapsed + 4.0
		17:
			print("AUTOTEST done: hunger=", Game.hunger, " thirst=", Game.thirst, " health=", Game.health,
				" grain=", Game.grain, " flour=", Game.flour, " dough=", Game.dough, " axe=", Game.axe,
				" errors=", _errors)
			get_tree().quit(1 if _errors > 0 else 0)
