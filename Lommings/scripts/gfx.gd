class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/lommings). DIV places a graphic by control point 0
## (centre when undefined); this is also where map_put / map_xput draw (see PORTING_NOTES).

const DIR := "res://assets/fpg/lommings/"

static var _textures: Dictionary = {}
static var _images: Dictionary = {}


static func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


## Control point 0 from meta.json (lemming sprites are 16x16 with cp (7,12); centre otherwise).
static func cp0(code: int) -> Vector2i:
	match code:
		115, 116:
			return Vector2i(7, 11)
		83:
			return Vector2i(15, 16)
		80:
			return Vector2i(2, 0)
	if code >= 81 and code <= 82 or code >= 100 and code <= 118:
		return Vector2i(7, 12)
	var t := tex(code)
	return Vector2i(t.get_width() / 2, t.get_height() / 2)


## RGBA8 copy of a graphic (cached, do not modify).
static func image(code: int) -> Image:
	if not _images.has(code):
		var img := tex(code).get_image()
		img.convert(Image.FORMAT_RGBA8)
		_images[code] = img
	return _images[code]
