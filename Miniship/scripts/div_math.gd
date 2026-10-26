class_name DivMath
extends RefCounted
## DIV integer helpers. Angles are thousandths of a degree, counter-clockwise (0 = right, 90000 = up).

const PI_DIV := 180000


## DIV get_distx(angle, dist): int(cos * dist)
static func dist_x(angle: int, dist: int) -> int:
	return int(cos(deg_to_rad(angle / 1000.0)) * dist)


## DIV get_disty(angle, dist): int(-sin * dist)   (screen y points down)
static func dist_y(angle: int, dist: int) -> int:
	return int(-sin(deg_to_rad(angle / 1000.0)) * dist)


## DIV fget_angle(x0, y0, x1, y1)
static func angle_between(x0: int, y0: int, x1: int, y1: int) -> int:
	return int(rad_to_deg(atan2(-float(y1 - y0), float(x1 - x0))) * 1000.0)


## DIV fget_dist
static func distance(x0: int, y0: int, x1: int, y1: int) -> int:
	return int(sqrt(float(x1 - x0) * float(x1 - x0) + float(y1 - y0) * float(y1 - y0)))


## Wrap into (-180000, 180000]
static func norm_angle(a: int) -> int:
	a = posmod(a, 360000)
	if a > 180000:
		a -= 360000
	return a


## DIV near_angle(a, target, step): turn `a` towards `target` by at most `step` the short way.
static func near_angle(a: int, target: int, step: int) -> int:
	var diff := norm_angle(target - a)
	if absi(diff) <= step:
		return norm_angle(target)
	return norm_angle(a + (step if diff > 0 else -step))


static func isqrt(v: int) -> int:
	return int(sqrt(float(v)))
