class_name Terrain
extends RefCounted
## The destructible level bitmap (DIV: graphic 2 "Level Now" = copy of the level graphic, edited at runtime
## with map_put). Lemmings test it per pixel: free ("air") is palette index 113, anything else is solid
## (incl. transparent index-0 pixels). Colour 113 is unique in the palette, so the RGBA image doubles as the
## index map; a parallel byte array caches the air flag.

var image: Image
var texture: ImageTexture
var _air: PackedByteArray
var _dirty := false


func load_level(code: int) -> void:
	image = Gfx.image(code).duplicate()
	var w := Defs.FIELD_SIZE.x
	var h := Defs.FIELD_SIZE.y
	_air = PackedByteArray()
	_air.resize(w * h)
	var data := image.get_data()
	for i in w * h:
		var o := i * 4
		var is_air := data[o + 3] == 255 and data[o] == 44 and data[o + 1] == 24 and data[o + 2] == 0
		_air[i] = 1 if is_air else 0
	if texture == null:
		texture = ImageTexture.create_from_image(image)
	else:
		texture.set_image(image)
	_dirty = false


## DIV: map_get_pixel(0,2,x,y)==113 (outside the graphic DIV returns 0 = solid).
func is_air(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= Defs.FIELD_SIZE.x or y >= Defs.FIELD_SIZE.y:
		return false
	return _air[y * Defs.FIELD_SIZE.x + x] == 1


## DIV: map_put(0, 2, code, x, y): draws graphic `code` with its control point 0 at (x,y);
## index-0 (transparent) pixels are skipped, so hole graphics (index 113) carve air, ladder pieces add terrain.
func stamp(code: int, x: int, y: int) -> void:
	var src := Gfx.image(code)
	var origin := Vector2i(x, y) - Gfx.cp0(code)
	for sy in src.get_height():
		var dy := origin.y + sy
		if dy < 0 or dy >= Defs.FIELD_SIZE.y:
			continue
		for sx in src.get_width():
			var dx := origin.x + sx
			if dx < 0 or dx >= Defs.FIELD_SIZE.x:
				continue
			var c := src.get_pixel(sx, sy)
			if c.a == 0.0:
				continue
			image.set_pixel(dx, dy, c)
			_air[dy * Defs.FIELD_SIZE.x + dx] = 1 if c.is_equal_approx(Defs.AIR_COLOR) else 0
	_dirty = true


## Upload pending changes to the GPU (once per rendered frame).
func flush() -> void:
	if _dirty:
		texture.update(image)
		_dirty = false
