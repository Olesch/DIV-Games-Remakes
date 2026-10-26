class_name SpecialItem
extends Node2D
## DIV: PROCESS SpecialItems(x, y, graph, Points, z, Life): flowers, hills, castle parts.
## Static targets that take `life` extra hits before they are destroyed.

@onready var sprite: Sprite2D = $Sprite2D

var graph: int = 111
var points: int = 0
var life: int = 0
var div_z: int = 0


func setup(x: int, y: int, graphic: int, point_value: int, z: int, lives: int) -> void:
	position = Vector2(x, y)
	graph = graphic
	points = point_value
	div_z = z
	life = lives


func _ready() -> void:
	add_to_group(&"specials")
	z_index = -div_z        # DIV: lower z = in front
	Gfx.apply(sprite, graph)


func contains_point(world_point: Vector2) -> bool:
	return Gfx.pixel_hit(graph, position, Vector2.ONE, world_point)


## DIV: the cursor set Killed=1 on this item.
@warning_ignore("integer_division")
func hit() -> void:
	Game.hits += 1
	if life > 0:
		life -= 1
		return
	Game.add_score(points)
	Game.combo_bar += points / 2
	Game.popup_world(str(points), position)
	if graph > 110 and graph < 115:                  # flower
		Game.flowers -= 1
	if graph == 116 or graph == 115:                 # hill (Berge)
		Game.combo_bar -= 200
		Game.hills -= 1
	if graph == 110 or graph == 118 or graph == 117: # castle ruin (Burg)
		Game.castle -= 1
	queue_free()
