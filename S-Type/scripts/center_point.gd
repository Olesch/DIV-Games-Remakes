class_name CenterPoint
extends Node2D
## DIV: Centerpoint(x,y,nummer) - the aiming reticle of weapon 4 (graph 107+nummer). It is only
## visible while that weapon is selected; the ship moves it (3x speed while not firing).

var index := 0


func _ready() -> void:
	Gfx.apply($Sprite, 107 + index)
	visible = false


func _physics_process(_delta: float) -> void:
	visible = Game.players[index].weapon == 4
	position = position.clamp(Vector2.ZERO, Game.SCREEN)
