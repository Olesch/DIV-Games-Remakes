class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/huhn). DIV places a graphic by its
## control point 0; Sprite2D nodes use offset = -cp0.

const DIR := "res://assets/fpg/huhn/"

## Control point 0 of every graphic used (from meta.json; centre if undefined).
const CP0 := {
	2: Vector2(10, 10),                        # crosshair (Cursordeko)
	5: Vector2(19, 59),                        # ammo icon (Munition)
	9: Vector2(80, 60), 10: Vector2(80, 60), 11: Vector2(80, 60),
	12: Vector2(80, 60), 13: Vector2(80, 60),  # bird animation
	100: Vector2(0, 0),                        # foreground panorama (Front)
	101: Vector2(0, 0),                        # background panorama (scroll graphic, drawn from 0,0)
	110: Vector2(15, 7),                       # castle tower
	111: Vector2(5, 12), 112: Vector2(5, 12), 113: Vector2(5, 12), 114: Vector2(5, 12),  # flowers
	115: Vector2(0, 0), 116: Vector2(0, 0), 117: Vector2(0, 0), 118: Vector2(0, 0),      # hills, gate, castle top
}

static var _textures: Dictionary = {}
static var _images: Dictionary = {}


static func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


static func cp0(code: int) -> Vector2:
	return CP0.get(code, Vector2.ZERO)


## Show graphic `code` on a Sprite2D so that the node position is the DIV (x, y).
static func apply(sprite: Sprite2D, code: int) -> void:
	sprite.centered = false
	sprite.texture = tex(code) if code > 0 else null
	sprite.offset = -cp0(code)


## DIV collision(): is the pixel of graphic `code` under `world_point` opaque?
## `node_pos` = position of control point 0, `scale` = signed scale (negative = mirrored).
static func pixel_hit(code: int, node_pos: Vector2, scale: Vector2, world_point: Vector2) -> bool:
	if not _images.has(code):
		_images[code] = tex(code).get_image()
	var img: Image = _images[code]
	var local := (world_point - node_pos) / scale + cp0(code)
	var px := Vector2i(floori(local.x), floori(local.y))
	if px.x < 0 or px.y < 0 or px.x >= img.get_width() or px.y >= img.get_height():
		return false
	return img.get_pixelv(px).a > 0.0
