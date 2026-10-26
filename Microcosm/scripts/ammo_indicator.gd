class_name AmmoIndicator
extends Sprite2D
## DIV: PROCESS MunitionsZeiger(Nummer, Seite) - one of six stacked ammo lights per cannon.
## Hidden above the cannon's capacity, "empty" while reloading, "full" when loaded.

const EMPTY_GRAPHIC := 17
const FULL_GRAPHIC := 18

var side: Defs.Side = Defs.Side.LEFT
var index: int = 1  # 1..6, DIV: Nummer


## Call before add_child().
func setup(cannon_side: Defs.Side, number: int) -> void:
	side = cannon_side
	index = number
	position = Vector2(30.0 if side == Defs.Side.LEFT else 994.0, 568.0 - number * 30.0)
	z_index = 5


func _ready() -> void:
	Game.ammo_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	if Game.ammo_max[side] < index:
		Gfx.apply(self, 0)
	elif Game.ammo[side] < index:
		Gfx.apply(self, EMPTY_GRAPHIC)
	else:
		Gfx.apply(self, FULL_GRAPHIC)
