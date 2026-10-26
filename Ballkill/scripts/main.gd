extends Node2D
## DIV: main code of BALLKILL - spawns balls (one per level), raises the level, handles clicks and
## the game-over sequence.

const BALL_SCENE := preload("res://scenes/ball.tscn")
const LEVEL_FRAMES := 100        # DIV: Levelwait>100*Level (in 18 fps frames)
const GAME_OVER_FRAMES := 120    # DIV: y from 0 to 600 in steps of 5 px
const FPS := 18.0
const RESTART_DELAY := 2.0       # new: the original exited to DOS, we start over

var _level_wait: int = 0
var _game_over := false

@onready var _foen: Foen = $Foen
@onready var _balls: Node2D = $Balls
@onready var _game_over_sprite: Sprite2D = $GameOver


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Game.new_game()
	_game_over_sprite.hide()
	if "--autotest" in OS.get_cmdline_user_args():
		var test := AutoTest.new()
		add_child(test)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(_delta: float) -> void:
	if _game_over:
		return
	if Game.ball_count < Game.level:
		_spawn_ball()
	_level_wait += 1
	if _level_wait > LEVEL_FRAMES * Game.level:
		_level_wait = 0
		Game.next_level()


func _unhandled_input(event: InputEvent) -> void:
	if _game_over or not event.is_action_pressed(&"pin"):
		return
	click(get_global_mouse_position().round())


## A mouse click: every ball under the pin loses one life (DIV: collision(TYPE mouse) per Ball).
func click(point: Vector2) -> void:
	for node in get_tree().get_nodes_in_group(&"balls"):
		var ball := node as Ball
		if ball.try_hit(point) and ball.life < 1:
			Game.ball_count -= 1


func _spawn_ball() -> void:
	var ball := BALL_SCENE.instantiate() as Ball
	ball.setup(Game.level, _foen)
	ball.escaped.connect(_on_ball_escaped)
	_balls.add_child(ball)
	Game.ball_count += 1


## DIV: y<0 -> let_me_alone(), save hiscore, "Game Over" graphic falls down the screen, exit.
func _on_ball_escaped() -> void:
	if _game_over:
		return
	_game_over = true
	Game.submit_score()
	_foen.queue_free()
	for node in _balls.get_children():
		(node as Ball).freeze()
		node.queue_free()
	_game_over_sprite.position = Vector2(400, 0)
	_game_over_sprite.show()
	_game_over_sprite.reset_physics_interpolation()
	var tween := create_tween()
	tween.tween_property(_game_over_sprite, "position:y", 600.0, GAME_OVER_FRAMES / FPS)
	tween.tween_interval(RESTART_DELAY)
	tween.tween_callback(func() -> void: get_tree().reload_current_scene())
