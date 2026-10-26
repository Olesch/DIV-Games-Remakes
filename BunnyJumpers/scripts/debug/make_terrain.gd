extends SceneTree
## One-off tool: bakes assets/fpg/bunyjump/indices.bin (graphic 1 = 1024x768 background) into
## res://assets/terrain.res.   godot --headless --path . --script res://scripts/debug/make_terrain.gd


func _initialize() -> void:
	var all := FileAccess.get_file_as_bytes("res://assets/fpg/bunyjump/indices.bin")
	var map := IndexMap.new()
	map.width = 1024
	map.height = 768
	var raw := all.slice(0, map.width * map.height)  # graphic 1 has offset 0
	map.packed_size = raw.size()
	map.packed = raw.compress(FileAccess.COMPRESSION_ZSTD)
	print("terrain: ", raw.size(), " -> ", map.packed.size(), " bytes")
	print("save: ", ResourceSaver.save(map, "res://assets/terrain.res"))
	quit()
