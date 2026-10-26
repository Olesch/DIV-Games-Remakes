class_name TreeLayer
extends Node2D
## Trees on the overlay (DIV: graphic 8 "Overlayer", trees map_put by Draw_all with a random
## graphic Baum1..3 and a random 1-pixel jitter). Redrawn only when a tree disappears.

@export var colony: Colony


func _ready() -> void:
	colony.trees_changed.connect(queue_redraw)


func _draw() -> void:
	for i: int in colony.trees:
		var tree: Vector3i = colony.trees[i]
		@warning_ignore("integer_division")
		var cell := Vector2i(i % Game.MAP_W, i / Game.MAP_W)
		draw_texture(Gfx.texture(tree.x), Gfx.cell_origin(cell) + Vector2(tree.y, tree.z))
