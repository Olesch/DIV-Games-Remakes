class_name Ball
extends Node2D
## One flying ball. DIV: PROCESS Ball(x, y, Stay) with resolution=10.
##
## Positions are kept in tenths of a pixel, exactly like the original, because the original's
## direction quantisation is what gives the picture its shape: advance(10) moves by
## (int(cos*10), int(-sin*10)) tenths, so only a few dozen directions exist and many balls do NOT
## fly exactly at the centre - early ones miss the seed and leave the screen.
## Each physics tick (= one DIV frame at set_fps(100)) the ball takes up to 40 such steps, checking
## for contact before every step. On contact it sticks: it is drawn into the aggregate and removed.

const STEPS_PER_FRAME := 40  # DIV: FROM i=1 TO 40 ... advance(10)
const STEP_LENGTH := 10  # DIV: advance(10) at resolution 10 = 1 px
const CENTRE := Vector2i(5120, 3840)  # tenths of a pixel
## DIV: IF(x<-50 OR x>10290 OR y>7730 OR y<-50) BREAK;  (tenths)
const LIMIT_MIN := Vector2i(-50, -50)
const LIMIT_MAX := Vector2i(10290, 7730)

signal escaped

var cluster: Cluster
var pos_tenths := Vector2i.ZERO
var _step := Vector2i.ZERO
var _last_tick := -1


## Call before add_child. start is in tenths of a pixel.
func setup(start: Vector2i, target_cluster: Cluster) -> void:
	cluster = target_cluster
	pos_tenths = start
	# DIV: angle = fget_angle(x, y, 5120, 3840): thousandths of a degree, counter-clockwise, truncated
	var to_centre := CENTRE - start
	var angle_millideg := int(rad_to_deg(atan2(-float(to_centre.y), float(to_centre.x))) * 1000.0)
	var a := deg_to_rad(angle_millideg / 1000.0)
	# DIV advance(): get_distx = int(cos*d), get_disty = int(-sin*d), truncated toward zero
	_step = Vector2i(int(cos(a) * STEP_LENGTH), int(-sin(a) * STEP_LENGTH))
	position = Vector2(pixel())


func pixel() -> Vector2i:
	return Vector2i(pos_tenths.x / 10, pos_tenths.y / 10)  # DIV x/10: integer division


func _physics_process(_delta: float) -> void:
	fly()


## Moves the ball for one frame. The spawner calls it right after creating the ball (a new DIV
## process runs up to its first FRAME immediately); the guard keeps it to once per tick.
func fly() -> void:
	var tick := Engine.get_physics_frames()
	if tick == _last_tick or is_queued_for_deletion():
		return
	_last_tick = tick
	for i in STEPS_PER_FRAME:
		if _touches_other_ball() or cluster.is_blocked(pixel()):
			_stick()
			return
		pos_tenths += _step
	position = Vector2(pixel())
	if pos_tenths.x < LIMIT_MIN.x or pos_tenths.x > LIMIT_MAX.x \
			or pos_tenths.y < LIMIT_MIN.y or pos_tenths.y > LIMIT_MAX.y:
		escaped.emit()
		queue_free()


## DIV: collision(TYPE Ball). In the original two flying balls that touch both stop for good
## (each one breaks out of its move loop every frame from then on); here the first one sticks and
## the other one meets it in the aggregate on its next check - same result.
func _touches_other_ball() -> bool:
	var me := pixel()
	for other: Ball in get_tree().get_nodes_in_group(&"flying_balls"):
		if other != self and not other.is_queued_for_deletion() \
				and cluster.balls_overlap(me, other.pixel()):
			return true
	return false


func _stick() -> void:
	position = Vector2(pixel())
	cluster.stamp(pixel())
	remove_from_group(&"flying_balls")
	queue_free()
