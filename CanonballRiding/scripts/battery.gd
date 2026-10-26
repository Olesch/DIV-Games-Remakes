class_name Battery
extends Node
## The cannons below the screen: fires a ball at ever shorter intervals
## (the shot logic of the DIV main code's second LOOP).

signal ball_fired

const START_RATE := 4800  # DIV: KanShotRate, interval in hundredths of a frame (4800 = 48 frames)

@export var ball_scene: PackedScene

var shot_rate: int = START_RATE
var _frames_since_shot: int = 0  # DIV: Cannonshot


func _ready() -> void:
	set_physics_process(false)


func start() -> void:
	shot_rate = START_RATE
	_frames_since_shot = 0
	set_physics_process(true)


func stop() -> void:
	set_physics_process(false)


@warning_ignore("integer_division")
func _physics_process(_delta: float) -> void:
	_frames_since_shot += 1
	if _frames_since_shot > shot_rate / 100:
		fire(randi_range(0, 640), randi_range(-5, 5), randi_range(-35, -25), randi_range(5, 15))
		ball_fired.emit()
		_frames_since_shot = 0
	# The interval shrinks every frame, slower and slower down to 3 frames.
	if shot_rate > 1200:
		shot_rate -= randi_range(1, 2)
	elif shot_rate > 600:
		shot_rate -= 1
	elif shot_rate > 300:
		shot_rate -= randi_range(0, 1)


func fire(x: int, x_inc: int, y_inc: int, size_pct: int) -> Cannonball:
	var ball := ball_scene.instantiate() as Cannonball
	ball.setup(x, x_inc, y_inc, size_pct)
	get_parent().add_child(ball)
	return ball
