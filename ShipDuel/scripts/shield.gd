class_name Shield
extends Area2D
## DIV: PROCESS playershield - a crescent in front of the ship (graph 6) that turns shots around.
## It is a child of the ship, so it turns with it (DIV: angle = father.angle).


func _ready() -> void:
	var texture := Gfx.tex(Gfx.SHIELD)
	($Sprite2D as Sprite2D).texture = texture
	Shapes.add_alpha_polygons(self, texture)
