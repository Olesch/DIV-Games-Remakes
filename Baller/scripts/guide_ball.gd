class_name GuideBall
extends Node2D
## The small ball you steer with the arrow keys (DIV: SmallBall + globals SmallBall_x/y).
## Arrows only change its velocity; the big ball follows it elastically. The camera follows this ball
## (DIV: scroll.camera=id). Positions are in 1/100 pixel (DIV resolution=100), one physics tick = one DIV frame.

const MAX_SPEED := 99  # velocity clamp in 1/100 px per sub-step

var pos := Vector2i.ZERO   # DIV: x, y
var vel := Vector2i.ZERO   # DIV: SmallBall_x / SmallBall_y
var speedup := 2
var speedmul := 5

@onready var camera: Camera2D = $Camera2D


func setup(start: Vector2i, level_size: Vector2i, tuning: LevelMap) -> void:
	pos = start * 100
	speedup = tuning.speedup
	speedmul = tuning.speedmul
	position = Vector2(start)
	# a scroll window never shows anything outside the level graphic
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = level_size.x
	camera.limit_bottom = level_size.y
	reset_physics_interpolation()


## Used by the ball when R pulls the guide back onto it.
func teleport_to(new_pos: Vector2i) -> void:
	pos = new_pos
	position = Vector2(pos) / 100.0
	reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed(&"move_up"):
		vel.y -= speedup
	if Input.is_action_pressed(&"move_down"):
		vel.y += speedup
	if Input.is_action_pressed(&"move_left"):
		vel.x -= speedup
	if Input.is_action_pressed(&"move_right"):
		vel.x += speedup
	vel = vel.clampi(-MAX_SPEED, MAX_SPEED)
	pos += vel * speedmul
	position = Vector2(pos) / 100.0
