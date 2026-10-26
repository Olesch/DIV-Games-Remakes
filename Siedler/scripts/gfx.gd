class_name Gfx
extends RefCounted
## SIEDLER.FPG helpers: graphic textures, their control points and the few palette colours
## the game needs (baked from assets/fpg/siedler/palette.json so no raw data file is read).

const DIR := "res://assets/fpg/siedler/"

## Palette entries (8-bit RGB) used by the start maps and shown on the minimap.
const PALETTE := {
	40: Color8(0, 231, 0),      # grass / tree / woodcutter
	41: Color8(0, 255, 0),      # woodcutter felling
	42: Color8(48, 255, 32),    # wood carrier
	55: Color8(0, 48, 255),     # water / idle settler
	75: Color8(255, 255, 73),   # walking settler
	120: Color8(195, 113, 0),   # clay / clay digger
	121: Color8(199, 130, 28),  # clay digger digging
	122: Color8(207, 146, 60),  # clay carrier
}

## Control point 0 of graphics that are not 10x10 tiles (those use the centre, 5,5).
const CP0 := {1: Vector2(1, 1), 11: Vector2(64, 48), 12: Vector2(66, 50), 200: Vector2(15, 15)}

static var _cache: Dictionary[int, Texture2D] = {}


static func texture(code: int) -> Texture2D:
	if not _cache.has(code):
		_cache[code] = load(DIR + "%d.png" % code) as Texture2D
	return _cache[code]


static func cp0(code: int) -> Vector2:
	return CP0.get(code, Vector2(5, 5))


static func palette_color(index: int) -> Color:
	return PALETTE.get(index, Color.BLACK)


## Top-left world position of a 10x10 tile drawn on a cell. The original map_put()s each tile
## with its centre on (cell*10, cell*10), so the whole world is shifted by -5 pixels.
static func cell_origin(cell: Vector2i) -> Vector2:
	return Vector2(cell * Game.CELL) - Vector2(5, 5)
