class_name Cannonball
extends Area2D
## Cannonball fired from below the screen; it grows while it flies (DIV: PROCESS Cannonball).
## Only dangerous once it is bigger than 50 %.

const START_Y := 500
const DANGER_SIZE := 50

var x: int = 0
var y: int = START_Y
var x_inc: int = 0
var y_inc: int = 0
var size_pct: int = 10  # DIV: size (percent)
var depth: int = 90     # DIV: z, grows every frame so older balls are drawn further back


func setup(start_x: int, start_x_inc: int, start_y_inc: int, start_size: int) -> void:
	x = start_x
	x_inc = start_x_inc
	y_inc = start_y_inc
	size_pct = start_size


func _ready() -> void:
	add_to_group(&"cannonballs")
	_step()  # DIV: the new process runs up to its first FRAME immediately
	reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	if y > START_Y + 1:
		queue_free()
		return
	_step()


func _step() -> void:
	size_pct += 1
	depth += 1
	x += x_inc
	y += y_inc
	y_inc += 1
	position = Vector2(x, y)
	scale = Vector2.ONE * (size_pct / 100.0)
	z_index = -depth


func is_dangerous() -> bool:
	return size_pct > DANGER_SIZE
