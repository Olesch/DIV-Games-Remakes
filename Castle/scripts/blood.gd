class_name Blood
extends Node2D
## DIV: PROCESS Blood(x,y,angle,Power) - a 50% transparent splash (graph 50) that grows from size 5%
## by 20% per frame until it reaches `power`, then disappears.

var power: int = 150
var size_pct: int = 5

@onready var _sprite: Sprite2D = $Sprite


func setup(px: int, py: int, angle_thousandths: int, pwr: int) -> void:
	position = Vector2(px, py)
	rotation = -deg_to_rad(angle_thousandths / 1000.0)
	power = pwr


func _ready() -> void:
	Gfx.apply(_sprite, 50)
	_sprite.modulate.a = 0.5  # flags=4
	_apply()
	if size_pct >= power:
		queue_free()


func _physics_process(_delta: float) -> void:
	size_pct += 20
	if size_pct >= power:
		queue_free()
		return
	_apply()


func _apply() -> void:
	scale = Vector2.ONE * (size_pct / 100.0)
