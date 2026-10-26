extends Node
## Global state (DIV: FESTUNG_ID and the Festung's `damage` local).
## The original has no game over: the fort only counts the damage it takes.

signal damage_changed(value: int)

const VIEW_SIZE := Vector2(800, 600)
const FORT_POS := Vector2(400, 300)  # DIV: Festung x=400, y=300

var damage: int = 0
var enemies_shot: int = 0  # statistics only (used by the autotest)


func add_damage() -> void:
	damage += 1
	damage_changed.emit(damage)
