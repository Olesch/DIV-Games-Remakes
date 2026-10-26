class_name TerrainLayer
extends TileMapLayer
## The ground (DIV: graphic 2 "WorldMap", filled by Draw_all from StartMapTerrain). Each grass,
## water and clay cell gets a random tile variant once; building sites replace 3x3 cells with
## "BauPlatte1". The node sits at (-5,-5) because the original centred every tile on cell*10.

const GRASS_TILES := [3, 7]   # Grasplatte1..5
const WATER_TILES := [15, 17] # WasserPlatte1..3
const CLAY_TILES := [20, 22]  # LehmPlatte1..3
const BUILDING_SITE_TILE := 30 # BauPlatte1
const ALL_TILES := [3, 4, 5, 6, 7, 15, 16, 17, 20, 21, 22, 30]

@export var colony: Colony


func _ready() -> void:
	position = -Vector2(5, 5)
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(Game.CELL, Game.CELL)
	for code: int in ALL_TILES:
		var source := TileSetAtlasSource.new()
		source.texture = Gfx.texture(code)
		source.texture_region_size = Vector2i(Game.CELL, Game.CELL)
		source.create_tile(Vector2i.ZERO)
		tiles.add_source(source, code)
	tile_set = tiles
	colony.building_site_placed.connect(_on_building_site_placed)


## DIV: Draw_all(1,0), terrain part.
func build(terrain: PackedByteArray) -> void:
	clear()
	var rng := colony.rng
	for i in terrain.size():
		var range_: Array
		match terrain[i]:
			Colony.Terrain.GRASS: range_ = GRASS_TILES
			Colony.Terrain.WATER: range_ = WATER_TILES
			Colony.Terrain.CLAY: range_ = CLAY_TILES
			_: continue
		@warning_ignore("integer_division")
		var cell := Vector2i(i % Game.MAP_W, i / Game.MAP_W)
		set_cell(cell, rng.randi_range(range_[0], range_[1]), Vector2i.ZERO)


## Cells just outside the map are drawn too (and clipped by the camera limits), like the
## original's map_put at the world graphic's edge.
func _on_building_site_placed(center: Vector2i) -> void:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			set_cell(center + Vector2i(dx, dy), BUILDING_SITE_TILE, Vector2i.ZERO)
