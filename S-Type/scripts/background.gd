extends Node2D
## DIV: Background - the 1600x600 star field (graph 11) scrolls 2 px per frame and wraps at -800.

const SPEED := 2.0  # px per tick


func _physics_process(_delta: float) -> void:
	position.x -= SPEED
	if position.x < -800.0:
		position.x = 0.0
		reset_physics_interpolation()
