class_name Compain
extends Node2D
## DIV: Compain(nummer,count) - companion pod. Pod `count` (0..3) is visible while the player owns
## more than `count` pods; it trails its `leader` (ship for pod 0, the previous pod otherwise) and
## copies the fire of the selected weapon while the fire key is held.

var index := 0       # player number (DIV: nummer)
var count := 0
var leader: Node2D
var angle := 0
var shot_wait := 0
var ship: Ship


func _ready() -> void:
	Gfx.apply($Sprite, 30)
	position = Vector2.ZERO  # DIV: spawned at (0,0) and flies to the ship when first owned
	visible = false


func _physics_process(_delta: float) -> void:
	if leader == null or not is_instance_valid(leader) or ship == null or not is_instance_valid(ship):
		queue_free()
		return
	var ps := Game.players[index]
	if ps.compains > count:
		visible = true
		angle = Div.near_angle(angle, Div.angle_to(position, leader.position), 10000)
		rotation = Div.rot(angle)
		if position.distance_to(leader.position) > 35.0:
			position += Div.vec(angle, 4.0)
		if ship.fire_held:
			if ps.weapon == 1 and shot_wait > 18:
				Shot.create(Shot.Kind.RED, position, angle - 15000)
				Shot.create(Shot.Kind.RED, position, angle + 15000)
				shot_wait = 0
			if ps.weapon == 2 and shot_wait > 6:
				Shot.create(Shot.Kind.GATLING, position, angle)
				shot_wait = 0
			if ps.weapon == 3 and shot_wait > 35:
				BoingLaser.fire(position, angle, 0, null)
				shot_wait = 0
			if ps.weapon == 4 and shot_wait > 30:
				CenterMissile.launch(position, angle, ps.center.position)
				shot_wait = 0
		shot_wait += 1
		if Div.rand(0, 1) == 0:
			shot_wait += 1
	else:
		visible = false
