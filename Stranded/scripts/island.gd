class_name Island
extends RefCounted
## The island map (DIV: graphics 101 field colours, 103 object map, 104 radar fog, 100 the big
## 5000x5000 ground picture that Draw_all painted tile by tile). Here the ground picture is a set
## of TileMapLayers fed through the signals below, and the 250x250 index maps are byte arrays.

signal ground_changed(cell: Vector2i, tile: int)
## layer 0 = first object sprite, layer 1 = sprite drawn over it; tile 0 clears the layer.
signal overlay_changed(cell: Vector2i, layer: int, tile: int)

const SIZE := 250                      # cells per side
const TILE_PX := 20                    # DIV: cell*20 = pixel coordinate in the scroll graphic
const START_CELL := Vector2i(47, 31)   # control point 1 of the radar graphic (101)

# Field colours (DIV: FelderFarben)
const GRASS := 41
const WATER := 54
const SAND := 73
# Object colours (DIV: ObjektFarben)
const BIG_STONE := 4
const STONE := 6
const PICKED_BERRIES := 11
const BERRIES := 22
const TREE := 39
const SPRING := 56
const HERB := 59
const PLANTED_GRAIN := 70
const GRAIN := 73
# Tile graphics (FPG codes)
const T_BERRY_BUSH := 63
const T_GRAIN_RIPE := 64
const T_DECO := 65
const T_PICKED_BERRIES := 66
const T_STONE := 69
const T_SPRING := 70
const T_BIG_STONE := 71
const T_HERB := 72
const T_GRAIN_SEEDLING := 73
const GROUND_TILES: Array[int] = [50, 51, 52, 57, 58]
const OBJECT_TILES: Array[int] = [60, 61, 63, 64, 65, 66, 69, 70, 71, 72, 73]
const FOG_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1), Vector2i(1, -1),
	Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]  # DIV: OpenCard

var field := PackedByteArray()      # DIV: graphic 101
var objects := PackedByteArray()    # DIV: graphic 103
var fog := PackedByteArray()        # DIV: graphic 104 (1 = still covered)
var radar_image: Image
var radar_texture: ImageTexture
var _ground := PackedByteArray()
var _layer_a := PackedByteArray()
var _layer_b := PackedByteArray()
var _palette: Array = []
var _radar_dirty := false


func _init() -> void:
	field = FileAccess.get_file_as_bytes("res://assets/data/fieldmap.bin")
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/info.json"))
	_palette = info["palette_rgb8"]
	var n := SIZE * SIZE
	objects.resize(n)
	fog.resize(n)
	_ground.resize(n)
	_layer_a.resize(n)
	_layer_b.resize(n)
	fog.fill(1)  # graphic 104 is solid colour 240 (black) until the hero opens cells
	radar_image = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	radar_texture = ImageTexture.create_from_image(radar_image)


static func in_range(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < SIZE and cell.y < SIZE


func get_field(cell: Vector2i) -> int:
	return field[cell.y * SIZE + cell.x] if in_range(cell) else 0


func get_object(cell: Vector2i) -> int:
	return objects[cell.y * SIZE + cell.x] if in_range(cell) else 0


func set_object(cell: Vector2i, value: int) -> void:
	if not in_range(cell):
		return
	objects[cell.y * SIZE + cell.x] = value
	_update_radar_cell(cell)


## DIV: Begehbar(x, y)
func is_walkable(cell: Vector2i) -> bool:
	var f := get_field(cell)
	return f == GRASS or f == SAND


## DIV: map_put(0, 100, tile, x*20, y*20). Grass/sand tiles are opaque and wipe everything
## drawn on the cell; other tiles are drawn over what is already there (two layers kept).
func put_tile(cell: Vector2i, tile: int) -> void:
	if not in_range(cell):
		return
	var i := cell.y * SIZE + cell.x
	if tile in GROUND_TILES:
		_ground[i] = tile
		_layer_a[i] = 0
		_layer_b[i] = 0
		ground_changed.emit(cell, tile)
		overlay_changed.emit(cell, 0, 0)
		overlay_changed.emit(cell, 1, 0)
		return
	if _layer_b[i] != 0:
		_layer_a[i] = _layer_b[i]
		overlay_changed.emit(cell, 0, _layer_a[i])
	_layer_b[i] = tile
	overlay_changed.emit(cell, 1, tile)


func random_grass() -> int:
	return randi_range(50, 52)


## DIV: Draw_all - paints the field tiles and scatters trees, bushes, stones...
func generate() -> void:
	for cy in SIZE:
		for cx in SIZE:
			var cell := Vector2i(cx, cy)
			match get_field(cell):
				GRASS:
					put_tile(cell, random_grass())
				SAND:
					put_tile(cell, randi_range(57, 58))
	# the hero's starting surroundings (right/below: grain, left: herb, above: spring)
	var s := START_CELL
	put_tile(s + Vector2i(1, 0), T_GRAIN_RIPE)
	set_object(s + Vector2i(1, 0), GRAIN)
	put_tile(s + Vector2i(-1, 0), T_HERB)
	set_object(s + Vector2i(-1, 0), HERB)
	put_tile(s + Vector2i(0, 1), T_GRAIN_RIPE)
	set_object(s + Vector2i(0, 1), GRAIN)
	put_tile(s + Vector2i(0, -1), T_SPRING)
	set_object(s + Vector2i(0, -1), SPRING)
	for i in 18001:
		var cell := Vector2i(randi_range(0, SIZE - 1), randi_range(0, SIZE - 1))
		if get_object(cell) != 0 or get_field(cell) != GRASS:
			continue
		var y := randi_range(0, 137)
		if y <= 60:  # tree
			put_tile(cell, randi_range(60, 61))
			set_object(cell, TREE)
		elif y <= 100:  # decoration (no object entry)
			put_tile(cell, T_DECO)
		elif y <= 110:  # berry bush
			put_tile(cell, T_BERRY_BUSH)
			set_object(cell, BERRIES)
		elif y == 111:  # grain
			if randi_range(0, 1) == 1:
				put_tile(cell, T_GRAIN_RIPE)
				set_object(cell, GRAIN)
		elif y <= 124:  # stone
			put_tile(cell, T_STONE)
			set_object(cell, STONE)
		elif y == 125:  # spring
			put_tile(cell, T_SPRING)
			set_object(cell, SPRING)
		elif y <= 136:  # big stone
			put_tile(cell, T_BIG_STONE)
			set_object(cell, BIG_STONE)
		else:  # herb
			put_tile(cell, T_HERB)
			set_object(cell, HERB)
	_redraw_radar()


## DIV: Refresh_all (runs every night): picked berries may regrow, planted grain ripens.
func refresh_all() -> void:
	for cy in SIZE:
		for cx in SIZE:
			var cell := Vector2i(cx, cy)
			match get_object(cell):
				PICKED_BERRIES:
					if randi_range(0, 10) == 10:
						put_tile(cell, T_BERRY_BUSH)
						set_object(cell, BERRIES)
				PLANTED_GRAIN:
					put_tile(cell, random_grass())
					put_tile(cell, T_GRAIN_RIPE)
					set_object(cell, GRAIN)


## DIV: OpenCard(x, y) - uncover the radar around the hero.
func open_card(cell: Vector2i) -> void:
	for d in FOG_OFFSETS:
		var c := cell + d
		if in_range(c):
			fog[c.y * SIZE + c.x] = 0
			_update_radar_cell(c)


func flush_radar() -> void:
	if _radar_dirty:
		radar_texture.update(radar_image)
		_radar_dirty = false


func _redraw_radar() -> void:
	for cy in SIZE:
		for cx in SIZE:
			_set_radar_pixel(Vector2i(cx, cy))
	_radar_dirty = true


func _update_radar_cell(cell: Vector2i) -> void:
	_set_radar_pixel(cell)
	_radar_dirty = true


func _set_radar_pixel(cell: Vector2i) -> void:
	var i := cell.y * SIZE + cell.x
	var index: int
	if fog[i] != 0:
		index = 240
	elif objects[i] != 0:
		index = objects[i]
	else:
		index = field[i]
	var rgb: Array = _palette[index]
	radar_image.set_pixel(cell.x, cell.y, Color8(rgb[0], rgb[1], rgb[2]))
