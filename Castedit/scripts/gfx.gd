class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/castle). DIV places a graphic by its control
## point 0; Sprite2D nodes use offset = -cp0 so that the node position is the DIV (x, y).

const DIR := "res://assets/fpg/castle/"
const SYSTEM_FONT_PATH := "res://assets/fnt/system/font_bmfont.fnt"
const SYSTEM_FONT_SIZE := 8

# Graphics whose control point 0 is defined as the top-left corner (the 800x600 canvas and the tiles).
# Every other graphic used here has no cp0 = centre (width/2, height/2).
const TOP_LEFT := [100, 101, 102, 103, 104, 110, 111, 112, 113, 120, 121, 125, 126, 130, 131, 132,
	134, 135, 136]

static var _textures: Dictionary = {}


static func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


static func cp0(code: int) -> Vector2:
	if code in TOP_LEFT:
		return Vector2.ZERO
	var t := tex(code)
	return Vector2(int(t.get_width()) / 2, int(t.get_height()) / 2)


## Show graphic `code` on `sprite` (0 = invisible).
static func apply(sprite: Sprite2D, code: int) -> void:
	sprite.centered = false
	if code <= 0:
		sprite.texture = null
		return
	sprite.texture = tex(code)
	sprite.offset = -cp0(code)
