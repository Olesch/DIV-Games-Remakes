class_name World
extends Node2D
## The game scene (DIV: the main code after the menu): background, buy line, ships, HUD and the
## level timeline. Entities are added to `entities`.

@onready var entities: Node2D = $Entities
@onready var hud: Hud = $Hud

var level: LevelScript
var _ending := false
var _snake_cheat_wait := 0


func _ready() -> void:
	Game.world = self
	RenderingServer.set_default_clear_color(Color.BLACK)
	var count := Game.player_count
	var starts := 5 if Game.shared_lives == 0 else count * 5
	for i in count:
		var ps := Game.players[i]
		var center := Scenes.CENTER_POINT.instantiate() as CenterPoint
		center.index = i
		center.position = Vector2(-50, -50)
		entities.add_child(center)
		ps.center = center
		var chooser := Scenes.BUY_CHOOSER.instantiate()
		chooser.set("index", i)
		$BuyLine.add_child(chooser)
		var ship := Scenes.SHIP.instantiate() as Ship
		ship.index = i
		ship.position = Vector2(100, 150 + i * 100)  # DIV: x=10000, y=15000+nummer*10000
		ps.ship = ship
		entities.add_child(ship)
	if Game.shared_lives == 1:
		Game.players[0].lives = starts  # DIV: Player[0].lives=(Playersnummer+1)*5
	hud.setup_lives()
	level = LevelScript.new()
	level.hud = hud
	level.finished.connect(_on_level_finished)
	add_child(level)
	level.start()
	if Game.autotest:
		var t := AutoTest.new()
		add_child(t)


func _physics_process(_delta: float) -> void:
	# DIV: IF(key(_a) AND key(_l) AND key(_e) AND key(_x)) two snake colonies, then FRAME(800)
	if _snake_cheat_wait > 0:
		_snake_cheat_wait -= 1
	elif Input.is_action_pressed(&"cheat_a") and Input.is_action_pressed(&"cheat_l") \
			and Input.is_action_pressed(&"cheat_e") and Input.is_action_pressed(&"cheat_x"):
		Snake.spawn(80000, 10000, 500, 500, 5, 1, 2, 5, 200, 25)
		Snake.spawn(80000, 55000, 500, 500, 5, 1, 2, 5, 200, 25)
		_snake_cheat_wait = 8


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):  # new: Esc returns to the start menu
		Game.go_menu()


## DIV: "GAME OVER" text (+ big explosion when lives are not shared), fade, back to the start.
func game_over(pos: Vector2, with_blast: bool) -> void:
	if _ending:
		return
	_ending = true
	level.queue_free()
	hud.say("GAME OVER", 400, 300, 4)
	if with_blast:
		Explosion.spawn(pos, 250, 5)
	_end_after(50.0 / Game.FPS)


func _on_level_finished() -> void:
	# the original simply kept running after the last level; here the game returns to the menu
	if not _ending:
		_ending = true
		_end_after(6.0)


func _end_after(seconds: float) -> void:
	get_tree().create_timer(seconds).timeout.connect(func() -> void: hud.fade_out(Game.go_menu))
