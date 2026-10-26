class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/castle).
## DIV places a graphic by its control point 0; Sprite2D nodes use offset = -cp0.

const DIR := "res://assets/fpg/castle/"
const FONT_PATH := "res://assets/fnt/castle/font_bmfont.fnt"
const FONT_SIZE := 23
const SYSTEM_FONT_PATH := "res://assets/fnt/system/font_bmfont.fnt"

# Graphics whose control point 0 is explicitly the top-left corner (tiles, bars, parchment).
# Every other graphic of CASTLE.FPG has no cp0 defined = centre (width/2, height/2).
const TOP_LEFT := [100, 101, 102, 103, 104, 110, 111, 112, 113, 120, 121, 125, 126, 130, 131, 132,
	51, 52, 53, 54]

static var _textures: Dictionary = {}
static var _masks: Dictionary = {}


static func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


static func cp0(code: int) -> Vector2:
	if code in TOP_LEFT:
		return Vector2.ZERO
	var t := tex(code)
	return Vector2(int(t.get_width()) / 2, int(t.get_height()) / 2)


## Show graphic `code` on `sprite` so that the node position is the DIV (x, y). 0 = invisible.
static func apply(sprite: Sprite2D, code: int) -> void:
	sprite.centered = false
	if code <= 0:
		sprite.texture = null
		return
	sprite.texture = tex(code)
	sprite.offset = -cp0(code)


## Opaque-pixel mask (1 = opaque) of a graphic, for DIV's pixel-exact collision().
static func mask(code: int) -> Dictionary:
	if not _masks.has(code):
		var img: Image = tex(code).get_image()
		var w := img.get_width()
		var h := img.get_height()
		var data := PackedByteArray()
		data.resize(w * h)
		for yy in h:
			for xx in w:
				data[yy * w + xx] = 1 if img.get_pixel(xx, yy).a > 0.5 else 0
		_masks[code] = {"w": w, "h": h, "data": data}
	return _masks[code]


## DIV collision(): do the opaque pixels of graphic a (cp0 at ax, ay) and b (cp0 at bx, by) overlap?
static func overlap(a: int, ax: int, ay: int, b: int, bx: int, by: int) -> bool:
	if a <= 0 or b <= 0:
		return false
	var ma := mask(a)
	var mb := mask(b)
	var ca := cp0(a)
	var cb := cb_point(b)
	var ox_a := ax - int(ca.x)
	var oy_a := ay - int(ca.y)
	var ox_b := bx - int(cb.x)
	var oy_b := by - int(cb.y)
	var x0 := maxi(ox_a, ox_b)
	var y0 := maxi(oy_a, oy_b)
	var x1 := mini(ox_a + int(ma["w"]), ox_b + int(mb["w"]))
	var y1 := mini(oy_a + int(ma["h"]), oy_b + int(mb["h"]))
	var da: PackedByteArray = ma["data"]
	var db: PackedByteArray = mb["data"]
	for yy in range(y0, y1):
		for xx in range(x0, x1):
			if da[(yy - oy_a) * int(ma["w"]) + (xx - ox_a)] == 1 and db[(yy - oy_b) * int(mb["w"]) + (xx - ox_b)] == 1:
				return true
	return false


static func cb_point(code: int) -> Vector2:
	return cp0(code)


## DIV get_dist(): integer distance between two points.
static func idist(ax: int, ay: int, bx: int, by: int) -> int:
	var dx := float(bx - ax)
	var dy := float(by - ay)
	return int(sqrt(dx * dx + dy * dy))
