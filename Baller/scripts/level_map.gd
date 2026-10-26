class_name LevelMap
extends RefCounted
## Terrain of one level: the original palette index of every pixel of the level graphic
## (DIV: map_get_pixel). The index values are the terrain types; the first pixels of the
## picture additionally carry the level's tuning values.

const DEATH := 22   # DIV comment "22-Tot"
const WIN := 41     # "41-Win"
const WALL := 54    # "54-Wall"
const HOLE := 73    # "73-Hole": attracts the ball (yellow)
const HILL := 89    # "89-Hill": repels the ball (purple)

var width: int
var height: int
var data: PackedByteArray

# Tuning read from the level's pixels (see read_tuning)
var speedup: int = 2          # DIV: Speedup, steering acceleration of the guide ball per frame
var speedmul: int = 5         # DIV: Speedmul, movement sub-steps per frame
var yellow_strength: int = 10 # DIV: YellowStr, pull of hole pixels
var gravity: int = 500        # DIV: BBGrav (pixel value * 10), how loosely the ball follows the guide
var friction: int = 10        # DIV: Reibung, frames between velocity decay steps (0 = none)
var purple_strength: int = 6  # DIV: LilaStr, push of hill pixels


static func load_level(code: int, w: int, h: int) -> LevelMap:
	var packed := FileAccess.get_file_as_bytes("res://assets/levels/%d.idx" % code)
	var map := LevelMap.new()
	map.width = w
	map.height = h
	map.data = packed.decompress(w * h, FileAccess.COMPRESSION_DEFLATE)
	assert(map.data.size() == w * h, "level %d failed to decompress" % code)
	map.read_tuning()
	return map


func get_index(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height:
		return 0
	return data[y * width + x]


## Pixel value 54 (the normal wall colour) = default, 255 = the value 54, anything else = the value.
func _tuning_pixel(x: int, y: int, default: int) -> int:
	var v := get_index(x, y)
	if v == 54:
		return default
	if v == 255:
		return 54
	return v


func read_tuning() -> void:
	speedup = _tuning_pixel(0, 0, 2)
	speedmul = _tuning_pixel(1, 0, 5)
	yellow_strength = _tuning_pixel(2, 0, 10)
	gravity = _tuning_pixel(3, 0, 50) * 10
	friction = _tuning_pixel(4, 0, 10)
	purple_strength = _tuning_pixel(2, 1, 6)
