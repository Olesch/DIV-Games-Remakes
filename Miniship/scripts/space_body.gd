class_name SpaceBody
extends Node2D
## Base of everything that flies around the torus-shaped 800x600 playfield.
## DIV resolution=100: px/py are in 1/100 pixel, xinc/yinc are "units" with position += inc/10 per frame.

var px := 0
var py := 0
var xinc := 0
var yinc := 0
var changed := 0              # DIV `changed`: swap velocities only once per collision
var shielded := false
var radius := 8.0             # collision circle (replaces pixel-exact collision())
var centre_offset := Vector2.ZERO


func place(teleported := false) -> void:
	position = Vector2(px, py) / 100.0
	if teleported:
		reset_physics_interpolation()


func centre() -> Vector2:
	return Vector2(px, py) / 100.0 + centre_offset


func overlaps(other: SpaceBody) -> bool:
	return centre().distance_to(other.centre()) <= radius + other.radius


## DIV get_dist(id) (in 1/100 px)
func get_dist(other: SpaceBody) -> int:
	return DivMath.distance(px, py, other.px, other.py)


## DIV get_angle(id)
func get_angle(other: SpaceBody) -> int:
	return DivMath.angle_between(px, py, other.px, other.py)


## DIV: IF (x>80000) x=1; ... (the playfield wraps). Returns true when it wrapped.
func wrap_world() -> bool:
	var wrapped := false
	if px > Game.WORLD_W:
		px = 1
		wrapped = true
	if py > Game.WORLD_H:
		py = 1
		wrapped = true
	if px < 0:
		px = Game.WORLD_W - 1
		wrapped = true
	if py < 0:
		py = Game.WORLD_H - 1
		wrapped = true
	return wrapped


## Bump used by ships and asteroids: push both bodies 2.5 px apart, optionally swap velocities.
func bump(other: SpaceBody, swap: bool) -> void:
	var a := get_angle(other)
	other.px += DivMath.dist_x(a, 250)
	other.py += DivMath.dist_y(a, 250)
	px -= DivMath.dist_x(a, 250)
	py -= DivMath.dist_y(a, 250)
	if swap and changed < 1 and other.changed < 1:
		var t := other.xinc
		other.xinc = xinc
		xinc = t
		t = other.yinc
		other.yinc = yinc
		yinc = t
		# Original: changed=1 then changed-- in the same frame, so the partner could swap again and
		# undo it. Two frames of protection make the swap stick.
		changed = 2
