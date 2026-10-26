class_name CenterMissile
extends Shot
## DIV: CenterMissile(x,y,angle,centerx,centery) - homes in on the point where the weapon-4
## reticle was when it was fired, then flies straight.

var target := Vector2.ZERO
var stop_angle := 0


static func launch(pos: Vector2, missile_angle: int, aim: Vector2) -> void:
	var m := Scenes.CENTER_MISSILE.instantiate() as CenterMissile
	m.position = pos
	m.angle = missile_angle
	m.target = aim
	Game.add_entity(m)


func _setup() -> void:
	graph = 106
	strength = 35
	explode_size = 50


func _step() -> void:
	stop_angle += 1
	if position.distance_to(target) < 15.0:
		stop_angle = 40
	if stop_angle < 40:
		angle = Div.near_angle(angle, Div.angle_to(position, target), 6000)
		rotation = Div.rot(angle)
	super._step()
