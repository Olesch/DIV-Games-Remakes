class_name World
extends Node2D
## DIV: main code + Draw_all + the scroll window (start_scroll(0, 0, 100, 55, 1, 0)).
## The 5000x5000 ground picture is three TileMapLayers (ground, object, object overlay);
## the water background (graphic 55) lives in `Water` on a layer behind this world.

const TILE := Island.TILE_PX
const FPG := "res://assets/fpg/stranded/%d.png"

@onready var ground_layer: TileMapLayer = $Ground
@onready var object_layer: TileMapLayer = $Objects
@onready var overlay_layer: TileMapLayer = $Overlay
@onready var camera: Camera2D = $Hero/Camera2D


func _ready() -> void:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE, TILE)
	var codes: Array[int] = []
	codes.append_array(Island.GROUND_TILES)
	codes.append_array(Island.OBJECT_TILES)
	for code in codes:
		var source := TileSetAtlasSource.new()
		source.texture = load(FPG % code)
		source.texture_region_size = Vector2i(TILE, TILE)
		source.create_tile(Vector2i.ZERO)
		tile_set.add_source(source, code)
	ground_layer.tile_set = tile_set
	object_layer.tile_set = tile_set
	overlay_layer.tile_set = tile_set

	Game.start_new_game()
	var island := Game.island
	island.ground_changed.connect(_on_ground_changed)
	island.overlay_changed.connect(_on_overlay_changed)
	island.generate()
	# scroll window stops at the edges of the 5000x5000 graphic
	var world_px := Island.SIZE * TILE
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = world_px
	camera.limit_bottom = world_px


func _on_ground_changed(cell: Vector2i, tile: int) -> void:
	ground_layer.set_cell(cell, tile, Vector2i.ZERO)


func _on_overlay_changed(cell: Vector2i, layer: int, tile: int) -> void:
	var target := object_layer if layer == 0 else overlay_layer
	if tile == 0:
		target.erase_cell(cell)
	else:
		target.set_cell(cell, tile, Vector2i.ZERO)
