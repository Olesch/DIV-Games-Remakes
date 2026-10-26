class_name SnakeCannon
extends Node2D
## DIV: SnakeCannon(weapon) - turret attached to a snake segment (child node, so it follows and
## dies with it). weapon: 1 forward, 2 / 3 fixed diagonals (upper / lower), 4 targeting at the
## segment centre, 5 / 6 rotating (lower / upper right), 7-10 targeting at the other mounts.

var weapon := 1
var blue := false       # DIV: father.graph==203 -> graph 206
var angle := 0
var shot_wait := 0
var target := 0


func _ready() -> void:
	z_index = 1  # DIV z=-1
	target = Game.pick_target()
	Gfx.apply($Sprite, 206 if blue else 205)
	if weapon == 1:
		angle = 180000
	if weapon == 2:
		angle = 150000
	if weapon == 3:
		angle = 210000
	_place()
	rotation = Div.rot(angle) - get_parent().rotation


func _place() -> void:
	match weapon:
		1, 4:
			position = Vector2.ZERO
		2, 7:
			position = Vector2(-8, -13)
		3, 8:
			position = Vector2(-8, 12)
		5, 9:
			position = Vector2(27, 12)
		6, 10:
			position = Vector2(27, -13)


func _physics_process(_delta: float) -> void:
	if weapon == 4 or weapon >= 7:
		var ship := Game.ship_of(target)
		if ship != null:
			angle = Div.angle_to(global_position, ship.global_position)
	if weapon == 5:
		angle += 5000
	if weapon == 6:
		angle -= 5000
	rotation = Div.rot(angle)

	shot_wait += 1
	if shot_wait > 30:
		EnemyShot.fire(global_position, angle, 103)
		shot_wait = 0
		target = Game.pick_target()
