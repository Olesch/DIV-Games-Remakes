class_name HouseGhost
extends Sprite2D
## DIV: Hausbau(200) - the house picture snapped to the 10-pixel grid under the cursor while
## the building mode is on. Placing only lays out the building site; the house itself is never
## built in the original.

@export var cursor: Node2D


func _ready() -> void:
	texture = Gfx.texture(200)
	centered = false
	offset = -Gfx.cp0(200)
	z_index = 50  # DIV z=-50: above the overlay, below the cursor
	visible = false


func _process(_delta: float) -> void:
	visible = Game.building
	if visible:
		position = (cursor.position / Game.CELL).floor() * Game.CELL
