class_name World
extends Node2D
## The match: round flow (DIV main code after the menu).
## GET READY (18 frames) -> 4 frames -> ships appear -> play until all but one ship are dead
## (Standard / Simple: survivor scores) or forever with respawns (Hold the Flag).

const SHIP_SCENE := preload("res://scenes/ship.tscn")
const ASTEROID_SCENE := preload("res://scenes/asteroid.tscn")
const PLANET_SCENE := preload("res://scenes/planet.tscn")
const FLAG_SCENE := preload("res://scenes/flag.tscn")
const MENU_SCENE := "res://scenes/menu.tscn"

enum Phase { GET_READY, SETTLE, PLAYING, ENDING, RESPAWN }

const READY_FRAMES := 18       # FRAME(1800)
const SETTLE_FRAMES := 4       # FRAME(400)
const ENDING_FRAMES := 4       # FRAME(400) before the survivors score
const RESPAWN_FRAMES := 72     # FRAME(7200), Hold the Flag

@onready var entities: Node2D = $Entities
@onready var effects: Effects = $Effects
@onready var hud: Hud = $Hud
@onready var phase_timer: Timer = $PhaseTimer

var phase := Phase.GET_READY
var _respawn_player := -1


func _ready() -> void:
	Game.entities = entities
	Game.effects = effects
	Game.ships = [null, null, null, null]
	Game.follow = null
	Game.flag = null
	Game.reset_points()
	for i in Game.asteroids:
		var asteroid := ASTEROID_SCENE.instantiate() as Asteroid
		asteroid.setup(randi_range(0, Game.WORLD_W), randi_range(0, Game.WORLD_H))
		entities.add_child(asteroid)
	var planet := PLANET_SCENE.instantiate() as Planet
	planet.setup(Game.WORLD_W / 2, Game.WORLD_H / 2, Game.gravity)
	entities.add_child(planet)
	Game.planet = planet
	phase_timer.timeout.connect(_on_phase_timer_timeout)
	_begin_get_ready()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"back"):
		# DIV: Backspace returns to the menu (Esc quit the program)
		get_tree().change_scene_to_file(MENU_SCENE)


func _physics_process(_delta: float) -> void:
	match phase:
		Phase.PLAYING:
			if Game.play_type == 2:
				_check_respawn()
			else:
				var dead := 0
				for i in 4:
					if not is_instance_valid(Game.ships[i]):
						dead += 1
				if dead >= 3:
					phase = Phase.ENDING
					_start_timer(ENDING_FRAMES)


func _begin_get_ready() -> void:
	phase = Phase.GET_READY
	get_tree().call_group(&"round_entities", &"end_round")   # DIV newstart=1
	hud.set_get_ready(true)
	_start_timer(READY_FRAMES)


func _start_timer(frames: int) -> void:
	phase_timer.start(frames / float(Game.FPS))


func _on_phase_timer_timeout() -> void:
	match phase:
		Phase.GET_READY:
			phase = Phase.SETTLE
			_start_timer(SETTLE_FRAMES)
		Phase.SETTLE:
			hud.set_get_ready(false)
			for i in 4:
				_spawn_ship(i)
			if Game.play_type == 2 and Game.flag == null:
				entities.add_child(FLAG_SCENE.instantiate())
			phase = Phase.PLAYING
		Phase.ENDING:
			for i in 4:
				if is_instance_valid(Game.ships[i]):
					Game.add_points(i, 1)
			_begin_get_ready()
		Phase.RESPAWN:
			_spawn_ship(_respawn_player)
			_respawn_player = -1
			phase = Phase.PLAYING
			_check_respawn()


## Hold the Flag: a dead ship returns 72 frames later (one at a time, like the original main loop).
func _check_respawn() -> void:
	for i in 4:
		if Game.ship_mode[i] != 0 and not is_instance_valid(Game.ships[i]):
			_respawn_player = i
			phase = Phase.RESPAWN
			_start_timer(RESPAWN_FRAMES)
			return


func _spawn_ship(player: int) -> void:
	if Game.ship_mode[player] == 0:
		return
	var ship := SHIP_SCENE.instantiate() as Ship
	ship.setup(player)
	entities.add_child(ship)
