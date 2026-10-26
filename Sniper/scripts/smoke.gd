class_name Smoke
extends Node2D
## DIV: PROCESS Smoke(x,y) - grenade trail: rises 5 px and shrinks 2 % per frame, random rotation.

var _size := 100.0  # DIV size (percent)

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	Gfx.apply(_sprite, 12)
	rotation = deg_to_rad(randf_range(-180.0, 180.0))
	reset_physics_interpolation()  # start at the random angle, no spin from 0 in the first tick


func _physics_process(_delta: float) -> void:
	_size -= 2.0
	position.y -= 5.0
	if _size < 0.0:
		queue_free()
		return
	scale = Vector2.ONE * _size / 100.0
