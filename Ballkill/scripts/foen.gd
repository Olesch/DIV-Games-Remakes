class_name Foen
extends Node2D
## DIV: PROCESS Foen - the hair-dryer at the top. Hold the right mouse button to move it right,
## otherwise it drifts back left. Balls beneath it get blown down. Lives at y=0.

const X_MIN := 2000   # DIV: x>2000 (1/100 px)
const X_MAX := 78000  # DIV: x<78000
const STEP := 500     # DIV: 5 px per frame (one physics tick = one 18 fps frame)
const START_X := 40000

## Horizontal position in 1/100 px, like the DIV process with resolution=100.
var x_centi: int = START_X


func _ready() -> void:
	_apply()
	reset_physics_interpolation()  # start at x=400, not sliding there from (0, 0)


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed(&"blow"):
		if x_centi < X_MAX:
			x_centi += STEP
	elif x_centi > X_MIN:
		x_centi -= STEP
	_apply()


func _apply() -> void:
	position = Vector2(x_centi / 100.0, 0.0)
