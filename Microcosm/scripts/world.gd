extends Node2D
## The playfield (the second part of the DIV main code): starts with three Duks and reacts
## to shop purchases by spawning the matching entities. Cannons, meteor spawner, difficulty
## ramp, HUD and crosshair are child scenes.

const TITLE_SCENE := "res://scenes/title.tscn"
const DUK_SCENE := preload("res://scenes/duk.tscn")
const POTION_SCENE := preload("res://scenes/potion.tscn")
const BIRD_SCENE := preload("res://scenes/bird.tscn")
const ATOM_SCENE := preload("res://scenes/atom.tscn")
const PLAYER_TWO_SCENE := preload("res://scenes/player_two.tscn")

const START_DUKS := 3


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Game.duk_bought.connect(_spawn.bind(DUK_SCENE))
	Game.potion_bought.connect(_spawn.bind(POTION_SCENE))
	Game.bird_bought.connect(_spawn.bind(BIRD_SCENE))
	Game.atom_bought.connect(_spawn.bind(ATOM_SCENE))
	Game.second_player_bought.connect(_spawn.bind(PLAYER_TWO_SCENE))
	for i in START_DUKS:
		_spawn(DUK_SCENE)
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(_delta: float) -> void:
	_check_cheats()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"back_to_title"):
		get_tree().change_scene_to_file(TITLE_SCENE)


func _spawn(scene: PackedScene) -> void:
	add_child(scene.instantiate())


## Hidden cheats of the original; they live in the Duk process, so they only work while a Duk lives.
func _check_cheats() -> void:
	var duks := get_tree().get_nodes_in_group(&"duks")
	if duks.is_empty():
		return
	if Input.is_physical_key_pressed(KEY_S) and Input.is_physical_key_pressed(KEY_U) \
			and Input.is_physical_key_pressed(KEY_P):
		for duk: Duk in duks:
			duk.make_super()
	if Input.is_physical_key_pressed(KEY_T) and Input.is_physical_key_pressed(KEY_A) \
			and Input.is_physical_key_pressed(KEY_X):
		Game.money = 10000
	if Input.is_physical_key_pressed(KEY_A) and Input.is_physical_key_pressed(KEY_R) \
			and Input.is_physical_key_pressed(KEY_M):
		Game.ramp = 3500
		Game.super_meteors = 3
