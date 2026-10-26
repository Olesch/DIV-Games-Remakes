class_name Cloud
extends Sprite2D
## Background cloud, blown sideways by the wind (DIV: PROCESS cloud). Runs one step per 24 Hz tick.

const SCREEN_W := 640
const SCREEN_H := 480

var x: int = 0
var y: int = 0
var graph: int = 10
var size_pct: int = 100  # DIV: size


func setup(start_x: int, start_y: int, start_graph: int, start_size: int) -> void:
	x = start_x
	y = start_y
	graph = start_graph
	size_pct = start_size


func _ready() -> void:
	z_index = -(1000 - size_pct)  # DIV: z = 1000 - size (never updated afterwards)
	_apply()
	reset_physics_interpolation()  # appear in place instead of sliding in from (0, 0)


@warning_ignore("integer_division")
func _physics_process(_delta: float) -> void:
	x += Game.wind * (size_pct / 50)
	if x < -51:
		_respawn(SCREEN_W + 50)  # 690
	elif x > SCREEN_W + 51:      # 691
		_respawn(-50)
	_apply()


func _respawn(new_x: int) -> void:
	x = new_x
	y = randi_range(0, SCREEN_H)
	graph = randi_range(10, 11)
	size_pct = randi_range(50, 200)
	_apply()
	reset_physics_interpolation()


func _apply() -> void:
	Gfx.apply(self, graph)
	position = Vector2(x, y)
	scale = Vector2.ONE * (size_pct / 100.0)
