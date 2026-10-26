class_name Colony
extends Node2D
## The settler simulation (DIV processes Maennchen, Draw_all, Begehbar, Loesche_Feld).
##
## The original keeps the whole world in three 128x96 "maps" (one palette index per cell) and
## one process sweeps the LogicMap cell by cell, once per frame, deciding what each settler
## does. This node keeps the same three grids as PackedByteArrays and runs the same sweep once
## per physics tick (physics runs at the original 24 fps). It does not draw anything itself:
## TreeLayer, SettlerLayer, TerrainLayer and the minimap read its state and its signals.

## Emitted after every sweep (settlers may have moved).
signal ticked
## A visible tree was removed (felled).
signal trees_changed
## A 3x3 building site was laid out around this cell.
signal building_site_placed(center: Vector2i)

## StartMapTerrain values (DIV graphic 10).
enum Terrain { NONE = 0, GRASS = 40, WATER = 55, BUILDING_SITE = 115, FINISHED_HOUSE = 116, CLAY = 120 }
## StartMapObjects values (DIV graphic 9).
enum Obj { NONE = 0, TREE = 40, SETTLER = 55 }
## LogicMap values (DIV graphic 11): what the settler standing on that cell is doing.
enum Job {
	NONE = 0,
	IDLE = 55,            # Nichts machen
	WALKING = 75,         # Laufen
	WOODCUTTER = 40,      # BaumFaeller
	FELLING = 41,         # BaumFaeller faellt
	CARRYING_WOOD = 42,   # BaumFaeller traegt Holz
	CLAY_DIGGER = 120,    # LehmSammler
	DIGGING = 121,        # LehmSammler sammelt (unreachable: commented out in the original)
	CARRYING_CLAY = 122,  # LehmSammler traegt Lehm
}

## Settler graphics in SIEDLER.FPG.
const GFX_SETTLER := 100        # Maennchen
const GFX_WOODCUTTER := 101     # HolzfaellerMaennchen
const GFX_WOOD_CARRIER := 102   # HolztraegerMaennchen
const GFX_CLAY_DIGGER := 105    # LehmsammlerMaennchen
const GFX_CLAY_CARRIER := 106   # LehmtraegerMaennchen

## Border cells a settler may never step on. The original compared the cell coordinate with the
## *pixel* size (x != 1279, y != 959), so settlers could walk off the right/bottom edge of the
## map and vanish; fixed to the last cell (127 / 95).
const BORDER_MAX := Vector2i(Game.MAP_W - 1, Game.MAP_H - 1)

const SIEDLER := "res://assets/fpg/siedler/"

var terrain := PackedByteArray()
var objects := PackedByteArray()
var logic := PackedByteArray()
## Visible trees: cell index -> Vector3i(graphic 25..27, x jitter, y jitter).
var trees: Dictionary[int, Vector3i] = {}
## Settler graphics currently painted on the overlay: cell index -> graphic code. Mirrors the
## original's map_put / Loesche_Feld calls, so a settler keeps its old picture until it moves.
var sprites: Dictionary[int, int] = {}

var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()


## Reads the two start maps (DIV graphics 10 and 9) and clears the LogicMap.
func load_start_maps() -> void:
	terrain = _read_index_map(SIEDLER + "10.png")
	objects = _read_index_map(SIEDLER + "9.png")
	logic = PackedByteArray()
	logic.resize(Game.MAP_W * Game.MAP_H)
	trees.clear()
	sprites.clear()


## DIV: Draw_all(0,1) objects part - plants the trees and turns the settler markers into
## idle settlers on the LogicMap. Call after the terrain has been drawn.
func place_start_objects() -> void:
	for i in objects.size():
		match objects[i]:
			Obj.TREE:
				if terrain[i] == Terrain.GRASS:
					trees[i] = Vector3i(rng.randi_range(25, 27), rng.randi_range(-1, 1), rng.randi_range(-1, 1))
				else:
					# Original bug, kept: meant to forget the tree, but clears the TERRAIN cell.
					# The tree stays as an invisible obstacle that woodcutters can still fell.
					terrain[i] = Terrain.NONE
			Obj.SETTLER:
				if terrain[i] == Terrain.GRASS:
					_paint(i, GFX_SETTLER)
					logic[i] = Job.IDLE
				objects[i] = Obj.NONE


func settler_count() -> int:
	var n := 0
	for v in logic:
		if v != 0:
			n += 1
	return n


func cell_index(cell: Vector2i) -> int:
	return cell.y * Game.MAP_W + cell.x


func in_map(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < Game.MAP_W and cell.y < Game.MAP_H


## DIV: Begehbar(x,y). Outside the map every grid reads 0, so it counts as walkable.
func is_walkable(cell: Vector2i) -> bool:
	if not in_map(cell):
		return true
	var i := cell_index(cell)
	if terrain[i] == Terrain.WATER or terrain[i] == Terrain.BUILDING_SITE:
		return false
	if objects[i] == Obj.TREE:
		return false
	return logic[i] == 0


## The building-site part of the original cursor process: a 3x3 site around `center` if all
## nine cells are walkable. Returns true when it was placed.
func try_place_house(center: Vector2i) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if not is_walkable(center + Vector2i(dx, dy)):
				return false
	Game.add_house_site(center - Vector2i.ONE)
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var c := center + Vector2i(dx, dy)
			if in_map(c):
				terrain[cell_index(c)] = Terrain.BUILDING_SITE
	building_site_placed.emit(center)
	return true


func _physics_process(_delta: float) -> void:
	sweep()


## One pass of the Maennchen process over the whole LogicMap, row by row. Changes are made in
## place, so a settler that steps right or down is met again later in the same pass and may act
## twice - the bug the original's header describes, kept on purpose.
func sweep() -> void:
	var w := Game.MAP_W
	for i in logic.size():
		if logic[i] == 0:
			continue
		@warning_ignore("integer_division")
		var cell := Vector2i(i % w, i / w)
		_change_job(i)
		_act(i, cell)
	ticked.emit()


## First SWITCH of Maennchen ("JobAenderung").
func _change_job(i: int) -> void:
	match logic[i]:
		Job.IDLE:
			if rng.randi_range(0, 50) == 0:
				logic[i] = Job.WALKING
		Job.WALKING:
			# Both rolls are independent; if both hit, the settler ends up a clay digger but was
			# also counted as a woodcutter (original behaviour).
			if rng.randi_range(0, 200) == 0 and Game.wood_workers < Game.wood_workers_max:
				logic[i] = Job.WOODCUTTER
				Game.wood_workers += 1
			if rng.randi_range(0, 200) == 0 and Game.clay_workers < Game.clay_workers_max:
				logic[i] = Job.CLAY_DIGGER
				Game.clay_workers += 1
		Job.WOODCUTTER:
			# The original also had "OR Rand(0,250==0)" here - a misplaced bracket that makes it
			# Rand(0,0), which is never true. So workers only quit for the two reasons below.
			if Game.wood_point == Game.NO_POINT:
				_quit_job(i)
				Game.wood_workers -= 1
				Game.stop_latch = true
			if Game.wood_workers > Game.wood_workers_max and rng.randi_range(0, 150) == 0 \
					and not Game.stop_latch:
				_quit_job(i)
				Game.wood_workers -= 1
		Job.CLAY_DIGGER:
			if Game.clay_point == Game.NO_POINT:
				_quit_job(i)
				Game.clay_workers -= 1
				Game.stop_latch = true
			if Game.clay_workers > Game.clay_workers_max and rng.randi_range(0, 150) == 0 \
					and not Game.stop_latch:
				_quit_job(i)
				Game.clay_workers -= 1


func _quit_job(i: int) -> void:
	logic[i] = Job.IDLE
	_clear(i)
	_paint(i, GFX_SETTLER)


## Second SWITCH of Maennchen ("Bewegung").
func _act(i: int, cell: Vector2i) -> void:
	match logic[i]:
		Job.WALKING:
			var target := _random_step(cell)
			if _inside_border(target) and is_walkable(target):
				_move(i, target, Job.WALKING, GFX_SETTLER)
		Job.WOODCUTTER:
			var target := _step_toward(cell, Game.wood_point)
			if _inside_border(target):
				if is_walkable(target):
					_move(i, target, Job.WOODCUTTER, GFX_WOODCUTTER)
				var t := cell_index(target)
				if objects[t] == Obj.TREE and logic[t] == 0:
					_move(i, target, Job.FELLING, GFX_WOODCUTTER)
		Job.FELLING:
			if rng.randi_range(0, 100) == 0:
				_clear(i)
				_paint(i, GFX_WOOD_CARRIER)
				logic[i] = Job.CARRYING_WOOD
				objects[i] = Obj.NONE
		Job.CLAY_DIGGER:
			var target := _step_toward(cell, Game.clay_point)
			if _inside_border(target) and is_walkable(target):
				_move(i, target, Job.CLAY_DIGGER, GFX_CLAY_DIGGER)
			# The step onto clay ground (-> DIGGING) is commented out in the original
			# ("OLLO! Petite Probleme!!!"), so clay diggers never dig.
		Job.DIGGING:
			if rng.randi_range(0, 150) == 0:
				_clear(i)
				_paint(i, GFX_CLAY_CARRIER)
				logic[i] = Job.CARRYING_CLAY
		# IDLE, CARRYING_WOOD and CARRYING_CLAY do nothing: carriers never deliver.


func _move(from: int, to: Vector2i, job: int, gfx: int) -> void:
	var t := cell_index(to)
	_paint(t, gfx)
	logic[t] = job
	logic[from] = 0
	_clear(from)


## rand(1,20): 1..4 one step right/left/down/up, otherwise stay. "Stay" is the original's
## target (0,0), which the border test rejects.
func _random_step(cell: Vector2i) -> Vector2i:
	match rng.randi_range(1, 20):
		1: return cell + Vector2i.RIGHT
		2: return cell + Vector2i.LEFT
		3: return cell + Vector2i.DOWN
		4: return cell + Vector2i.UP
	return Vector2i.ZERO


## Woodcutter / clay digger walk: rand(1,40) -> 1..5 step along the farther axis toward the
## collection point, 6..8 along the nearer axis, 9..33 stay, 34..40 a random step.
func _step_toward(cell: Vector2i, point: Vector2i) -> Vector2i:
	var roll := rng.randi_range(1, 40)
	var d := cell - point
	if roll <= 8:
		var use_x := absi(d.x) > absi(d.y) if roll <= 5 else absi(d.x) < absi(d.y)
		if use_x:
			return cell + (Vector2i.LEFT if d.x > 0 else Vector2i.RIGHT)
		return cell + (Vector2i.UP if d.y > 0 else Vector2i.DOWN)
	if roll <= 33:
		return Vector2i.ZERO
	return _random_step(cell)


func _inside_border(c: Vector2i) -> bool:
	return c.x != 0 and c.x < BORDER_MAX.x and c.y != 0 and c.y < BORDER_MAX.y


func _paint(i: int, gfx: int) -> void:
	sprites[i] = gfx


## DIV: Loesche_Feld - wipes the cell's 10x10 square of the overlay (settler picture and tree).
func _clear(i: int) -> void:
	sprites.erase(i)
	if trees.erase(i):
		trees_changed.emit()


## Decodes a converted 128x96 map PNG back to palette indices. These maps only contain the
## indices 0, 40, 55 and 120, whose palette colours are unique.
func _read_index_map(path: String) -> PackedByteArray:
	var image := (load(path) as Texture2D).get_image()
	image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var palette := {}
	for index: int in [Terrain.GRASS, Terrain.WATER, Terrain.CLAY]:
		palette[Gfx.palette_color(index).to_rgba32()] = index
	var out := PackedByteArray()
	out.resize(Game.MAP_W * Game.MAP_H)
	for y in Game.MAP_H:
		for x in Game.MAP_W:
			var c := image.get_pixel(x, y)
			if c.a < 0.5:
				continue
			var key := c.to_rgba32()
			assert(palette.has(key), "unexpected colour in %s" % path)
			out[y * Game.MAP_W + x] = palette.get(key, 0)
	return out
