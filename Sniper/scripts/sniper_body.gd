class_name SniperBody
extends Node2D
## DIV: PROCESS SniperBody(x,y) - the kneeling body (graph 2) behind a sniper, z=1. The DIV code
## always follows the lead sniper (Sniperfollo); each body here follows its own `leader`.

var leader: Node2D

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	Gfx.apply(_sprite, 2)


func _physics_process(_delta: float) -> void:
	if is_instance_valid(leader):
		position.y = leader.position.y + 14.0
