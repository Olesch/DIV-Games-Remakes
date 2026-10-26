class_name FloatingText
extends PixelLabel
## DIV: PROCESS Text / Textb. Rises one pixel every 3 frames for 30 steps, then disappears.

const STEP_TICKS := 3
const STEPS := 30

var _ticks: int = 0
var _steps: int = 0


func setup(value: String, screen_pos: Vector2) -> void:
	text = value
	align_code = 7
	anchor = screen_pos
	_anchor_set = true


func _physics_process(_delta: float) -> void:
	_ticks += 1
	if _ticks % STEP_TICKS != 0:
		return
	if _steps >= STEPS:
		queue_free()
		return
	_steps += 1
	move_anchor(anchor + Vector2(0, -1))
