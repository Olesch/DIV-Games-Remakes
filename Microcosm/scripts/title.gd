extends Node2D
## Title / help screen with difficulty selection (the first LOOP of the DIV main code).

const GAME_SCENE := "res://scenes/game.tscn"

var _starting := false

@onready var _difficulty_label: PixelLabel = $DifficultyLabel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_difficulty_label.set_value(str(Game.difficulty))


func _process(_delta: float) -> void:
	# DIV: mouse.left AND mouse.right also start the game
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_start_game()


func _unhandled_input(event: InputEvent) -> void:
	# The original changes the value every frame while the key is held; one step per press is saner.
	if event.is_action_pressed(&"difficulty_up") and Game.difficulty < 5:
		Game.difficulty += 1
		_difficulty_label.set_value(str(Game.difficulty))
	elif event.is_action_pressed(&"difficulty_down") and Game.difficulty > 1:
		Game.difficulty -= 1
		_difficulty_label.set_value(str(Game.difficulty))
	elif event.is_action_pressed(&"start_game"):
		_start_game()


func _start_game() -> void:
	if _starting:
		return
	_starting = true
	Game.new_game()
	get_tree().change_scene_to_file(GAME_SCENE)
