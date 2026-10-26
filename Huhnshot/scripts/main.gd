extends Node2D
## DIV: the main code of Huhnshot - sets up the panorama, spawns birds and targets, runs the
## once-per-second clock (spawn chance, bonuses), the combo bar and the end of the round.

const BIRD_SCENE := preload("res://scenes/bird.tscn")
const SPECIAL_SCENE := preload("res://scenes/special_item.tscn")
const RESTART_DELAY_MS := 800

@onready var world: Node2D = $World
@onready var clock: Timer = $SecondTimer
@onready var hud: Hud = $Hud

var _over_since_ms: int = 0


func _ready() -> void:
	Game.reset()
	clock.timeout.connect(_on_second)
	for i in 4:
		spawn_bird(randi_range(0, 24000), randi_range(0, 6000), randi_range(0, 1))
	for i in Game.flowers:
		spawn_item(randi_range(0, 2400), randi_range(435, 600), randi_range(111, 114), randi_range(5, 15), -51, 0)
	spawn_item(1834, 232, 110, 100, -1, 3)    # castle towers
	spawn_item(1922, 235, 110, 100, -1, 3)
	spawn_item(1840, 280, 117, 100, -1, 5)    # castle gate
	spawn_item(1850, 250, 118, 100, -1, 8)    # castle top
	spawn_item(700, 200, 116, 500, -1, 15)    # hills
	spawn_item(0, 60, 115, 500, -1, 20)
	if "--autotest" in OS.get_cmdline_user_args():
		var test := AutoTest.new()
		test.name = "AutoTest"
		add_child(test)


func spawn_bird(x10: int, y10: int, flags: int) -> void:
	var bird := BIRD_SCENE.instantiate() as Bird
	bird.setup(x10, y10, flags)
	world.add_child(bird)


func spawn_item(x: int, y: int, graph: int, points: int, z: int, life: int) -> void:
	var item := SPECIAL_SCENE.instantiate() as SpecialItem
	item.setup(x, y, graph, points, z, life)
	world.add_child(item)


func _physics_process(_delta: float) -> void:
	if Game.over:
		return
	world.position.x = -Game.scroll_x0          # manual scroll, DIV: scroll[0].x0
	_update_combo_bar()
	if Game.time < 0:
		_end_round()


func _unhandled_input(event: InputEvent) -> void:
	if Game.over and Time.get_ticks_msec() - _over_since_ms > RESTART_DELAY_MS \
			and (event.is_action_pressed(&"fire") or event.is_action_pressed(&"restart")):
		get_tree().reload_current_scene()


## DIV: PROCESS COMBER - the combo bar drains every frame and pays score above 100.
@warning_ignore("integer_division")
func _update_combo_bar() -> void:
	Game.combo_bar -= 1
	if Game.combo_bar > 100:
		Game.add_score((Game.combo_bar - 100) / 10)
		Game.combo_bar -= 1
	if Game.combo_bar > 250:
		Game.combo_bar = 250
		if Game.combo_bonus == 0:
			Game.popup_screen("500", Vector2(400, 300))
			Game.popup_screen("Combobonus!!", Vector2(400, 250))
			Game.add_score(500)
			Game.time += 10
			Game.combo_bonus = -1
			Game.max_ammo += 1
	if Game.combo_bar < 0:
		Game.combo_bar = 0


## DIV: PROCESS SCORER - show the final score.
func _end_round() -> void:
	Game.over = true
	Game.final_score = Game.score
	_over_since_ms = Time.get_ticks_msec()
	clock.stop()
	world.process_mode = Node.PROCESS_MODE_DISABLED
	hud.show_game_over()


## One game second (DIV: FRAME(2400) in the main loop).
func _on_second() -> void:
	if randi_range(0, Game.shots + 20) < Game.hits + 5:
		if randi_range(0, 1) == 0:
			spawn_bird(randi_range(0, 24000), 6000, randi_range(0, 1))
		elif randi_range(0, 1) == 0:
			spawn_bird(0, randi_range(0, 6000), 1)
		else:
			spawn_bird(24000, randi_range(0, 6000), 0)
	Game.time -= 1
	if Game.flowers == 0:
		Game.popup_screen("500", Vector2(400, 300))
		Game.popup_screen("Flowerbonus", Vector2(400, 250))
		Game.flowers = -1
		Game.add_score(500)
		Game.time += 10
		Game.max_ammo += 1
	if Game.hills == 0:
		Game.popup_screen("LAWINE!!", Vector2(400, 250))
		Game.time += 10
		for i in 4:
			spawn_bird(randi_range(0, 24000), 6000, randi_range(0, 1))
		for i in 2:
			spawn_bird(0, randi_range(0, 6000), 1)
		for i in 2:
			spawn_bird(24000, randi_range(0, 6000), 0)
		Game.hills = -1
		Game.max_ammo += 1
	if Game.castle == 0:
		Game.popup_screen("500", Vector2(400, 300))
		Game.popup_screen("Burgruine", Vector2(400, 250))
		Game.add_score(500)
		Game.time += 10
		Game.castle = -1
		Game.max_ammo += 1
	if Game.castle == -1 and randi_range(0, 3) == 0:
		spawn_bird(18680, 3130, randi_range(0, 1))     # birds fly out of the ruin
	if Game.combo_bonus == -1 and Game.time_bonus == -1 and Game.castle == -1 and Game.hills == -1 \
			and Game.flowers == -1 and Game.dead_bird_bonus == 1 and Game.bonus_master == 0:
		Game.popup_screen("500", Vector2(400, 200))
		Game.popup_screen("ALL", Vector2(300, 350))
		Game.popup_screen("BONUSES", Vector2(400, 400))
		Game.popup_screen("FOUND!!!", Vector2(500, 450))
		Game.popup_screen("HOLD MG FOR MACHINEGUNMODE!!!", Vector2(500, 500))
		Game.add_score(500)
		Game.time += 10
		Game.bonus_master = 1
		Game.max_ammo += 1
