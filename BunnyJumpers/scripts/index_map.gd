class_name IndexMap
extends Resource
## Palette-index bitmap of a DIV graphic (what `map_get_pixel` read), stored zstd-compressed.
## Baked from the converter's indices.bin by scripts/debug/make_terrain.gd.

@export var width: int = 0
@export var height: int = 0
@export var packed_size: int = 0
@export var packed: PackedByteArray = PackedByteArray()

var _data: PackedByteArray = PackedByteArray()


func unpack() -> void:
	_data = packed.decompress(packed_size, FileAccess.COMPRESSION_ZSTD)


## DIV map_get_pixel: 0 outside the graphic.
func index_at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height:
		return 0
	return _data[y * width + x]
