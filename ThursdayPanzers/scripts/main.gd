extends Node
## Match setup (DIV: main program) and the two scroll-window cameras.
## Two SubViewports share one World2D; each has its own Camera2D that follows a player's tank.

const TANK_SCENE := preload("res://scenes/tank.tscn")
const SETUP_SCENE := "res://scenes/setup.tscn"

@onready var _view_a: SubViewport = $LeftContainer/LeftView
@onready var _view_b: SubViewport = $RightContainer/RightView
@onready var _world: Node2D = $LeftContainer/LeftView/World
@onready var _ground: Sprite2D = $LeftContainer/LeftView/World/Ground
@onready var _cameras: Array[Camera2D] = [null, $LeftContainer/LeftView/Camera, $RightContainer/RightView/Camera]

var _followed: Array[Node2D] = [null, null, null]  # tank each camera is following
var _reinforcement_wait := 0  # ticks until the next reinforcement pair (DIV: FRAME(2400))


func _ready() -> void:
	process_physics_priority = 100  # run after the tanks so the cameras do not lag a tick behind
	_view_b.world_2d = _view_a.world_2d
	for cam: Camera2D in _cameras.slice(1):
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = int(Game.WORLD_SIZE.x)
		cam.limit_bottom = int(Game.WORLD_SIZE.y)
	_make_ground()
	_spawn_tanks()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _physics_process(_delta: float) -> void:
	if Options.reinforcements:
		_reinforce()
	for player in [1, 2]:
		var tank := Game.player_tank[player]
		if is_instance_valid(tank):
			_cameras[player].position = tank.position  # DIV: scroll[n].camera = id
			if tank != _followed[player]:
				# first frame or control handed to another tank after a death: cut, don't pan there
				_followed[player] = tank
				_cameras[player].reset_physics_interpolation()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart"):
		Game.reset()
		get_tree().change_scene_to_file(SETUP_SCENE)


## DIV: Draw(1) paints every map pixel with a random palette colour 34..37.
func _make_ground() -> void:
	var size := Vector2i(Game.WORLD_SIZE)
	var noise := Crypto.new().generate_random_bytes(size.x * size.y)
	_ground.texture = ImageTexture.create_from_image(Image.create_from_data(size.x, size.y, false, Image.FORMAT_R8, noise))


func _spawn_tanks() -> void:
	# DIV: Panzer(x, y, life, power, velo, player, team); values from the setup screen
	# (defaults: players 300/10/40, computer tanks 200/5/30, rows every 80 / 60 px).
	_spawn(Vector2(0, 0), Options.get_value(&"player_life", 1), Options.get_value(&"player_power", 1),
			Options.get_value(&"player_velo", 1), 1, 1)
	# The original passes player 0 here (so team 2 had no human); the intent is clearly player 2.
	_spawn(Game.WORLD_SIZE, Options.get_value(&"player_life", 2), Options.get_value(&"player_power", 2),
			Options.get_value(&"player_velo", 2), 2, 2)
	for team in [1, 2]:
		for x in Options.row_xs(team):
			_spawn(Vector2(x + randi_range(-10, 10), Options.ROW_Y[team] + randi_range(-15, 15)),
					Options.get_value(&"ai_life", team), Options.get_value(&"ai_power", team),
					Options.get_value(&"ai_velo", team), 0, team)


## Optional "reinforcements" (DIV, commented out at the end of the main program): from the start,
## once per second one weak computer tank for team 2, then one for team 1, anywhere on the map.
## New: stops once a team has won.
func _reinforce() -> void:
	_reinforcement_wait -= 1
	if _reinforcement_wait > 0 or Game.winner != 0:
		return
	_reinforcement_wait = Options.REINFORCEMENT_TICKS
	for team in [2, 1]:
		var pos := Vector2(randi_range(0, int(Game.WORLD_SIZE.x)), randi_range(0, int(Game.WORLD_SIZE.y)))
		_spawn(pos, Options.REINFORCEMENT_LIFE, Options.REINFORCEMENT_POWER, Options.REINFORCEMENT_VELO, 0, team)


func _spawn(pos: Vector2, life: int, power: int, velo: int, player: int, team: int) -> void:
	var tank := TANK_SCENE.instantiate() as Tank
	tank.setup(pos, life, power, velo, player, team)
	_world.add_child(tank)
