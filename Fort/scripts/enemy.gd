class_name Enemy
extends Area2D
## Enemy (DIV: Enemy(art)). Flies at 6 px/frame; dies after two hits.
## NORMAL heads straight for the fort and shrinks as it gets closer (size = distance/3 %).
## ZIGZAG (the original starts moving to the right, angle 0) re-aims at the fort with a random
## +-30 degree error whenever its counter passes 70 (counter grows by rand(0,2) per frame).

enum Kind { NORMAL, ZIGZAG }

const SPEED := 6.0 * 24.0  # DIV: advance(6) @ 24 fps
const TEXTURES := {
	Kind.NORMAL: preload("res://assets/fpg/fortkeep/10.png"),
	Kind.ZIGZAG: preload("res://assets/fpg/fortkeep/11.png"),
}

var kind: Kind = Kind.NORMAL
var damage: int = 0  # DIV: local `damage`
var _heading := 0.0  # radians, screen coordinates (DIV: angle)
var _counter := 0.0  # DIV: Countera, in frames


func _ready() -> void:
	# both graphics are 35x35 without control point -> origin is the centre (17,17)
	($Sprite2D as Sprite2D).texture = TEXTURES[kind]
	_heading = 0.0 if kind == Kind.ZIGZAG else (Game.FORT_POS - position).angle()
	rotation = _heading


func hit() -> void:
	damage += 1
	if damage > 1:
		Game.enemies_shot += 1
		queue_free()


func _physics_process(delta: float) -> void:
	if kind == Kind.NORMAL:
		_heading = (Game.FORT_POS - position).angle()
		scale = Vector2.ONE * (position.distance_to(Game.FORT_POS) / 3.0 / 100.0)
	else:
		if _counter > 70.0:
			_heading = (Game.FORT_POS - position).angle() + deg_to_rad(randf_range(-30.0, 30.0))
			_counter = 0.0
		_counter += randf_range(0.0, 2.0) * 24.0 * delta  # mean 1 per frame
	rotation = _heading
	position += Vector2.from_angle(_heading) * SPEED * delta
