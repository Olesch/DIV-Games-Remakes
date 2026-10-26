class_name LevelData
extends RefCounted
## One level graphic of the converted Gigamaze.fpg: its palette-index map (DIV map_get_pixel)
## and its control points (DIV get_point).  Colour index 1 = free floor, everything else is wall.

const DIR := "res://assets/fpg/gigamaze/"

var width := 0
var height := 0
var indices := PackedByteArray()
var points: Array = []   # Vector2i or null per control point number


static func load_graphic(code: int) -> LevelData:
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIR + "meta.json"))
	var all := FileAccess.get_file_as_bytes(DIR + "indices.bin")
	for g: Dictionary in meta["graphics"]:
		if int(g["code"]) != code:
			continue
		var level := LevelData.new()
		level.width = int(g["width"])
		level.height = int(g["height"])
		var offset := int(g["offset"])
		level.indices = all.slice(offset, offset + level.width * level.height)
		for p in g["points"]:
			level.points.append(null if p == null else Vector2i(int(p[0]), int(p[1])))
		return level
	return null


## DIV map_get_pixel: colour index, 0 outside the graphic.
func get_index(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height:
		return 0
	return indices[y * width + x]


## DIV get_point: (-1,-1) when the point is undefined.
func get_point(n: int) -> Vector2i:
	if n < 0 or n >= points.size() or points[n] == null:
		return Vector2i(-1, -1)
	return points[n]
