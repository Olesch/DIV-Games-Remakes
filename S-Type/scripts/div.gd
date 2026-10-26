class_name Div
extends RefCounted
## DIV helper maths. Angles are DIV angles: thousandths of a degree, counter-clockwise
## (0 = right, 90000 = up). Positions in Godot are plain pixels (DIV: 1/100 px, resolution=100).


static func rand(lo: int, hi: int) -> int:
	return randi_range(lo, hi)


## DIV get_distx/get_disty: unit vector of `angle` scaled by `dist` (y points down on screen).
static func vec(angle: int, dist: float) -> Vector2:
	var r := deg_to_rad(angle / 1000.0)
	return Vector2(cos(r), -sin(r)) * dist


## DIV fget_angle: angle from point a to point b.
static func angle_to(a: Vector2, b: Vector2) -> int:
	var d := b - a
	if d == Vector2.ZERO:
		return 0
	return roundi(-rad_to_deg(atan2(d.y, d.x)) * 1000.0)


## DIV near_angle: turn `angle` towards `target` by at most `step`, the short way round.
static func near_angle(angle: int, target: int, step: int) -> int:
	var diff := wrapi(target - angle, -180000, 180000)
	if absi(diff) <= step:
		return angle + diff
	return angle + step * signi(diff)


## Godot node rotation for a DIV angle.
static func rot(angle: int) -> float:
	return -deg_to_rad(angle / 1000.0)
