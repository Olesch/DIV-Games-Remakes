extends Node2D
## Background stars: DIV put_pixel(rand(0,800), rand(0,600), 15) x 300 (palette colour 15 = white).

const COUNT := 300

var _stars := PackedVector2Array()


func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	z_index = -10
	for i in COUNT:
		_stars.append(Vector2(randi_range(0, 800), randi_range(0, 600)))


func _draw() -> void:
	for s in _stars:
		draw_rect(Rect2(s, Vector2.ONE), Color.WHITE)
