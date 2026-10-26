class_name WallMap
extends RefCounted
## The arena map (graph 1) as a pixel lookup. DIV used collision(TYPE screen) for "touches the map"
## and map_get_pixel(...) == 55 to find out which side was hit.

const WALL_G_CHANNEL := 48  # palette 55 = (0, 48, 255); palette 56 (rim line) = (0, 101, 255)

static var _width := 0
static var _height := 0
static var _data := PackedByteArray()


static func _ensure() -> void:
	if _data.is_empty():
		var image := Gfx.tex(Gfx.LEVEL).get_image()
		image.convert(Image.FORMAT_RGBA8)
		_width = image.get_width()
		_height = image.get_height()
		_data = image.get_data()


## Any non-transparent map pixel (colour index != 0).
static func is_solid(x: int, y: int) -> bool:
	_ensure()
	if x < 0 or y < 0 or x >= _width or y >= _height:
		return false
	return _data[(y * _width + x) * 4 + 3] > 0


## DIV: map_get_pixel(0, Karte, x, y) == 55
static func is_wall(x: int, y: int) -> bool:
	_ensure()
	if x < 0 or y < 0 or x >= _width or y >= _height:
		return false
	var i := (y * _width + x) * 4
	return _data[i + 3] > 0 and _data[i + 1] == WALL_G_CHANNEL


## True when any of the sprite's opaque pixels (offsets from `center`) lies on a map pixel.
static func overlaps(center: Vector2i, offsets: Array[Vector2i]) -> bool:
	for offset in offsets:
		if is_solid(center.x + offset.x, center.y + offset.y):
			return true
	return false
