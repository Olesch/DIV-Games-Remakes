class_name Crystal
extends Area2D
## The diamond (DIV process Crystal): 200 points, then jumps to one of the diamond places 5..10.

signal collected(player: int)


func _ready() -> void:
	$Sprite2D.texture = Game.tex(17)
	area_entered.connect(_on_area_entered)
	_relocate()


func _relocate() -> void:
	var p := Game.level.get_point(randi_range(Game.POINT_DIAMOND_FIRST, Game.POINT_DIAMOND_LAST))
	position = Vector2(p)


func _on_area_entered(area: Area2D) -> void:
	var ship := area as Ship
	if ship == null:
		return
	ship.stats.score += Game.DIAMOND_SCORE
	collected.emit(ship.player)
	_relocate()
