class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/miniship).
## Control point 0 of every graphic used (meta.json; centre when undefined).

const DIR := "res://assets/fpg/miniship/"
const SHIP_BASE := 1          # graphics 1..4 = ship of player 0..3
const LASER := 5
const PLANET := 6
const ENERGY_LINE := 7
const SHIELD := 8
const ROCKET := 9             # also the menu cursor
const MENU_PLAIN := 10
const PARTICLE := 11
const MENU_SIMPLE := 13
const MENU_FLAG := 14
const FLAG := 20
const ASTEROID_BASE := 20     # + weight (1..3)

const CP0 := {
	1: Vector2(10, 10), 2: Vector2(10, 10), 3: Vector2(10, 10), 4: Vector2(10, 10),
	5: Vector2(8, 1), 6: Vector2(40, 40), 7: Vector2(0, 1), 8: Vector2(20, 20),
	9: Vector2(5, 2), 10: Vector2(400, 300), 11: Vector2(0, 0), 12: Vector2(12, 12),
	13: Vector2(400, 300), 14: Vector2(400, 300), 20: Vector2(9, 16),
	21: Vector2(12, 12), 22: Vector2(17, 17), 23: Vector2(22, 22),
}

static var _textures: Dictionary = {}


static func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


## Show graphic `code` so that the node position is the DIV (x, y).
static func apply(sprite: Sprite2D, code: int) -> void:
	sprite.centered = false
	sprite.texture = tex(code)
	sprite.offset = -CP0[code]
