class_name BossCannon
extends Node2D
## DIV: Endenemy1Cannon(weapon,xplus,yplus) - weapon 1 aims at a player and fires a 3-way
## burst, weapons 2 and 3 sweep between 135 and 225 degrees (3 starts sweeping the other way).

var weapon := 1
var angle := 180000
var direction := 0
var shot_wait := 0
var target := 0


func _ready() -> void:
	z_index = 1
	scale = Vector2.ONE * 1.3
	Gfx.apply($Sprite, 401)
	target = Game.pick_target()
	if weapon == 3:
		weapon = 2
		direction = 1


func _physics_process(_delta: float) -> void:
	if weapon == 1:
		var ship := Game.ship_of(target)
		if ship != null:
			angle = Div.angle_to(global_position, ship.global_position)
	if weapon == 2:
		angle += 5000 if direction == 0 else -5000
		if angle > 225000:
			direction = 1
		if angle < 135000:
			direction = 0
	rotation = Div.rot(angle)
	shot_wait += 1
	if weapon == 2:
		shot_wait += 6
	if shot_wait > 50:
		EnemyShot.fire(global_position, angle, 405)
		if weapon == 1:
			EnemyShot.fire(global_position, angle + 45000, 405)
			EnemyShot.fire(global_position, angle - 45000, 405)
		shot_wait = 0
		target = Game.pick_target()
