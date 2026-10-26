class_name Ball
extends Area2D
## One ball (DIV process Ball), in group "balls". Logic runs once per physics tick (24/s = set_fps)
## because the original moves 4*Activity px per frame and its bounce/score tests depend on those
## discrete positions.

const CENTER := Vector2(320, 240)
const BOTTOM_BOUNCE := 468      # DIV: y>=468 -> go up
const TOP_BOUNCE := 12          # DIV: y<=12 -> go down
const RIGHT_OUT := 648          # DIV: x>648 -> ball left on the right side
const LEFT_OUT := -8            # DIV: x<-8  -> ball left on the left side

var velocity := Vector2i.ZERO   # DIV: xinc, yinc
var _step := 16                 # DIV: 4*Activity, the speed after a bounce


## Call before add_child. DIV creates the ball and moves it once before its first FRAME.
## The start velocity may differ from the bounce speed (one-ball mode starts balls at 4 px/frame).
func setup(start_velocity: Vector2i) -> void:
	_step = Game.step()
	velocity = start_velocity
	position = CENTER + Vector2(velocity)


func _physics_process(_delta: float) -> void:
	# DIV order inside the loop: tests after FRAME, then move at the top of the next pass.
	if position.y >= BOTTOM_BOUNCE:
		velocity.y = -_step
	if position.y <= TOP_BOUNCE:
		velocity.y = _step
	if has_overlapping_areas():  # touching a bat (physics layer "bat")
		velocity.x = -_step if position.x > CENTER.x else _step
	if position.x > RIGHT_OUT:
		Game.ball_out(1)
		position = CENTER
	elif position.x < LEFT_OUT:
		Game.ball_out(-1)
		position = CENTER
	position += Vector2(velocity)
