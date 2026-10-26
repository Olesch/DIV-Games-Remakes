class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/mini2).
## DIV places a graphic by its control point 0; Sprite2D nodes use offset = -cp0.

const DIR := "res://assets/fpg/mini2/"

## Control point 0 of every graphic used (from assets/fpg/mini2/meta.json).
const CP0 := {
	1: Vector2(25, 50), 2: Vector2(25, 50),      # riders
	10: Vector2(37, 18), 11: Vector2(50, 25),    # clouds
	20: Vector2(20, 20),                         # cannonball
	30: Vector2(16, 16), 31: Vector2(16, 16), 32: Vector2(16, 16),
	33: Vector2(16, 16), 34: Vector2(16, 16), 35: Vector2(16, 16),  # explosion
}

static var _textures: Dictionary = {}


static func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


## Show graphic `code` on a Sprite2D so that the node position is the DIV (x, y).
static func apply(sprite: Sprite2D, code: int) -> void:
	sprite.centered = false
	sprite.texture = tex(code)
	sprite.offset = -CP0[code]
