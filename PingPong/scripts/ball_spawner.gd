extends Node
## Releases the balls.
## Normal mode (DIV main code): FOR x<pairs: Ball(4*Activity,4*Activity); Ball(-4*Activity,-4*Activity);
## FRAME(300/Activity). FRAME(75) at Activity 4 is 3/4 of a frame, so four pairs come every three ticks.
## Classic one-ball mode (the original's commented-out LOOP): every frame, with a chance of 1 in 51
## (rand(0,50)==0), one ball to a random side (rand(0,1)) and random vertical direction
## (rand(0,1)*8-4) at 4 px/frame; it speeds up to 4*Activity at its first bounce. The original loop never
## ended; here it stops at Game.ball_count balls.

@export var ball_scene: PackedScene
@export var ball_parent: Node

var _released := 0
var _frame_percent := 75   # DIV FRAME(300/Activity), integer division
var _credit := 0           # percent of a frame collected; a pair is released per _frame_percent


func _ready() -> void:
	@warning_ignore("integer_division")
	_frame_percent = 300 / Game.activity
	_credit = _frame_percent   # the first pair appears immediately


func _physics_process(_delta: float) -> void:
	if Game.one_ball_mode:
		_release_at_random()
	else:
		_release_pairs()
	if _released >= Game.ball_count:
		set_physics_process(false)


func _release_pairs() -> void:
	var step := Game.step()
	while _credit >= _frame_percent and _released < Game.ball_count:
		_credit -= _frame_percent
		_spawn(Vector2i(step, step))
		_spawn(Vector2i(-step, -step))
	_credit += 100


func _release_at_random() -> void:
	if randi_range(0, 50) != 0:
		return
	var x_direction := 1 if randi_range(0, 1) == 0 else -1
	_spawn(Vector2i(4 * x_direction, randi_range(0, 1) * 8 - 4))


func _spawn(velocity: Vector2i) -> void:
	var ball := ball_scene.instantiate() as Ball
	ball.setup(velocity)
	ball_parent.add_child(ball)
	_released += 1
