class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/snipgame). DIV places a graphic by its
## control point 0; Sprite2D nodes use offset = -cp0.

const DIR := "res://assets/fpg/snipgame/"
const SCREEN_SIZE := Vector2(1024, 768)

## Control point 0 per graphic (meta.json).
const CP0 := {
	2: Vector2(50, 50), 5: Vector2(12, 12), 6: Vector2(24, 26), 8: Vector2(70, 1),
	9: Vector2(50, 100), 10: Vector2(50, 100), 11: Vector2(17, 17), 12: Vector2(22, 22),
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


## DIV out_region(id, 0): the (rotated) graphic's bounding box is completely outside the screen.
## `pos` is the control point; for these (near-)centred graphics it stands in for the box centre.
static func is_outside_screen(pos: Vector2, size: Vector2, rot: float) -> bool:
	var c := absf(cos(rot))
	var s := absf(sin(rot))
	var half := Vector2(c * size.x + s * size.y, s * size.x + c * size.y) * 0.5
	return (pos.x + half.x < 0.0 or pos.x - half.x > SCREEN_SIZE.x
		or pos.y + half.y < 0.0 or pos.y - half.y > SCREEN_SIZE.y)
