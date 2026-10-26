class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/mini1). Every graphic used has an undefined
## control point 0, i.e. its centre, so all sprites are simply centred Sprite2D nodes.

const DIR := "res://assets/fpg/mini1/"
const LEVEL := 1        # arena map (walls = palette index 55)
const FIRST_SHIP := 2   # Player1..4 = 2..5
const SHIELD := 6       # PlayerWand
const FIRST_SHOT := 7   # Schuss1..4 = 7..10 (= ship graph + 5)
const FIRST_EXPLOSION := 11  # Explode1..6 = 11..16
const SHOT_CP0 := Vector2i(10, 10)

static var _textures: Dictionary = {}
static var _shot_pixels: Array[Vector2i] = []


static func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


static func ship_tex(index: int) -> Texture2D:
	return tex(FIRST_SHIP + index)


static func shot_tex(index: int) -> Texture2D:
	return tex(FIRST_SHOT + index)


## Opaque pixels of a shot graphic relative to its centre (all four shots share one silhouette);
## used to test the shot against the wall map like DIV's pixel collision.
static func shot_pixels() -> Array[Vector2i]:
	if _shot_pixels.is_empty():
		var image := tex(FIRST_SHOT).get_image()
		for y in image.get_height():
			for x in image.get_width():
				if image.get_pixel(x, y).a > 0.0:
					_shot_pixels.append(Vector2i(x, y) - SHOT_CP0)
	return _shot_pixels
