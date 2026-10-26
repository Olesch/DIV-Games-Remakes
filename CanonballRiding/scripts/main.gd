class_name Main
extends Node2D
## Title menu and game flow (the DIV main code and escproc). One scene, small state machine:
## MENU (title, 1 / 2 start, Esc quits) -> PLAYING -> GAME_OVER (Esc back to the menu).

enum State { MENU, PLAYING, GAME_OVER }

const CLOUD_COUNT := 15
const CLOUD_SCENE := preload("res://scenes/cloud.tscn")
const PLAYER_SCENE := preload("res://scenes/player.tscn")

var state: State = State.MENU
var _score_saved := false

@onready var entities: Node2D = $Entities
@onready var battery: Battery = $Entities/Battery
@onready var hud: Hud = $Hud
@onready var _fade: ColorRect = $FadeLayer/Fade


func _ready() -> void:
	for i in CLOUD_COUNT:
		var cloud := CLOUD_SCENE.instantiate() as Cloud
		cloud.setup(randi_range(0, 640), randi_range(0, 480), randi_range(10, 11), randi_range(50, 200))
		entities.add_child(cloud)
	battery.ball_fired.connect(_on_ball_fired)
	hud.show_menu()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/debug/autotest.gd").new())


func _unhandled_input(event: InputEvent) -> void:
	match state:
		State.MENU:
			if event.is_action_pressed(&"start_1p"):
				start_game(1)
			elif event.is_action_pressed(&"start_2p"):
				start_game(2)
			elif event.is_action_pressed(&"escape"):
				_quit()
		State.PLAYING:
			if event.is_action_pressed(&"escape"):
				end_game()  # DIV escproc: Esc during play ends the run
		State.GAME_OVER:
			if event.is_action_pressed(&"escape"):
				back_to_menu()


func start_game(players: int) -> void:
	_clear_entities()
	Game.new_game(players)
	_score_saved = false
	if players == 1:
		_spawn_player(1, 320, &"p1_left", &"p1_right", 1)
	else:
		var rider1 := _spawn_player(1, 427, &"p1_left", &"p1_right", 1)
		var rider2 := _spawn_player(2, 213, &"p2_left", &"p2_right", 2)
		rider1.other = rider2
		rider2.other = rider1
	battery.start()
	hud.show_game()
	state = State.PLAYING


func back_to_menu() -> void:
	battery.stop()
	_clear_entities()
	hud.show_menu()
	state = State.MENU


## DIV PlayerMinus: the first death (or Esc) ends the run, in two-player games too.
## The remaining rider and the cannons carry on, but the score stops counting.
func end_game() -> void:
	if state == State.PLAYING:
		state = State.GAME_OVER


func _spawn_player(number: int, x: int, left: StringName, right: StringName, graph: int) -> Player:
	var rider := PLAYER_SCENE.instantiate() as Player
	rider.player_number = number
	rider.x = x
	rider.left_action = left
	rider.right_action = right
	rider.graph = graph
	rider.died.connect(end_game)
	entities.add_child(rider)
	return rider


func _clear_entities() -> void:
	for group: StringName in [&"players", &"cannonballs"]:
		for node in get_tree().get_nodes_in_group(group):
			node.queue_free()
	for node in entities.get_children():
		if node is Explosion:
			node.queue_free()


func _on_ball_fired() -> void:
	match state:
		State.PLAYING:
			Game.score += 1
		State.GAME_OVER:
			# DIV: the ELSE branch of the shot code: show the final score, save a new hiscore
			hud.show_game_over()
			if not _score_saved and Game.score > Game.hiscores[Game.player_count]:
				Game.set_hiscore(Game.player_count, Game.score)
				_score_saved = true


func _quit() -> void:
	if OS.has_feature("web"):
		return  # nowhere to quit to in a browser
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, 0.4)
	tween.tween_callback(get_tree().quit)
