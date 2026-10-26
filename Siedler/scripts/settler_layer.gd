class_name SettlerLayer
extends Node2D
## Settler pictures on the overlay (DIV: map_put of Maennchen / HolzfaellerMaennchen / ... into
## graphic 8). Redrawn after every simulation sweep.

@export var colony: Colony


func _ready() -> void:
	colony.ticked.connect(queue_redraw)


func _draw() -> void:
	for i: int in colony.sprites:
		@warning_ignore("integer_division")
		var cell := Vector2i(i % Game.MAP_W, i / Game.MAP_W)
		draw_texture(Gfx.texture(colony.sprites[i]), Gfx.cell_origin(cell))
