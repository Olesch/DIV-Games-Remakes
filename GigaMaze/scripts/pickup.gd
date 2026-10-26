class_name Pickup
extends Area2D
## A level item (DIV process Item).  Weapon items vanish when a ship touches them; the others
## (rockets, shield, teleporters) are decoration only, as in the original.

var number := 0
var graph := 0
var _taken := false

@onready var _sprite: Sprite2D = $Sprite2D


## DIV Item(Number): graphic by control point number.
static func graph_for(point_number: int) -> int:
	if point_number >= 11 and point_number <= 18:
		return 53
	if point_number >= 19 and point_number <= 26:
		return 56
	if point_number >= 27 and point_number <= 30:
		return 58
	if point_number >= 31 and point_number <= 38:
		return 59
	if point_number >= 39 and point_number <= 43:
		return 60
	if point_number >= 44 and point_number <= 47:
		return 61
	if point_number >= 48 and point_number <= 51:
		return 62
	if point_number >= 52 and point_number <= 53:
		return 63
	return 64


func setup(point_number: int, at: Vector2i) -> void:
	number = point_number
	graph = graph_for(point_number)
	position = Vector2(at)


func _ready() -> void:
	_sprite.texture = Game.tex(graph)
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if _taken or not Game.PICKUPS.has(graph):
		return
	var ship := area as Ship
	if ship == null:
		return
	_taken = true
	var grant: Array = Game.PICKUPS[graph]
	ship.stats.weapon = grant[0]
	ship.stats.ammo = grant[1]
	queue_free()
