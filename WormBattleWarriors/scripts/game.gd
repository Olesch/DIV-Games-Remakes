extends Node
## Global game state and rules (DIV: the GLOBAL struct Xp[31].Yp[23] and the action code inside CURSOR).
## The board is a flat set of arrays indexed by y * W + x. Everything that changes the board emits
## `board_changed`, the Board node redraws then (DIV: REPAINT()).

signal board_changed
signal turn_changed
signal selection_changed
signal cursor_moved
signal game_over(winner: int)

const W := 32
const H := 24
const FPS := 18  # DIV: set_fps() is never called, so the default 18 fps applies

# Floor values (DIV comment: < 100 walkable, otherwise not walkable except for workers)
const GRASS := 1
const DUG := 2        # Abgetragene Erde
const HOLE := 3       # Loch in die Erde
const DIRT := 101     # Erde
const LEAF := 102     # Blatt
const BRANCH := 103   # Ast
const AIR := 104      # Luft
const FOOD_STORE := 105   # FutterLager
const BIRTH_PLACE := 106  # Geburtort
const TRAINER := 107      # Kriegsausbilder

# Unit types (player 2 = +10)
const WORKER := 1
const WORKER_WOOD := 2
const WORKER_LEAF := 3
const WORKER_FOOD := 4
const FIGHTER_WEAK := 5
const FIGHTER_STRONG := 6

# Not in the original (it has no combat): damage per hit by unit kind (type mod 10), costs 1 AP.
const DAMAGE := {1: 5, 2: 5, 3: 5, 4: 5, 5: 20, 6: 40}

var floor_: PackedInt32Array = PackedInt32Array()
var stat: PackedInt32Array = PackedInt32Array()   # Stat: 4 = store/trainer used up
var typ: PackedInt32Array = PackedInt32Array()
var life_max: PackedInt32Array = PackedInt32Array()
var life: PackedInt32Array = PackedInt32Array()
var move_max: PackedInt32Array = PackedInt32Array()
var move: PackedInt32Array = PackedInt32Array()   # action points (AP)

var player_turn := 0     # DIV: PlayerTurn (0 = player 1)
var cursor_cell := Vector2i.ZERO
var selected := false
var winner := -1
var finished := false


func _ready() -> void:
	new_game()


static func idx(c: Vector2i) -> int:
	return c.y * W + c.x


static func in_bounds(c: Vector2i) -> bool:
	return c.x >= 0 and c.x < W and c.y >= 0 and c.y < H


static func owner_of(unit_type: int) -> int:
	return unit_type / 10


static func kind_of(unit_type: int) -> int:
	return unit_type % 10


static func is_worker(unit_type: int) -> bool:
	return kind_of(unit_type) >= 1 and kind_of(unit_type) <= 4


## DIV "Ebene": 1 = grass layer (rows 3..10), 0 = air above and underground below.
static func level_of(c: Vector2i) -> int:
	return 1 if c.y >= 3 and c.y <= 10 else 0


func new_game() -> void:
	var n := W * H
	for a: PackedInt32Array in [floor_, stat, typ, life_max, life, move_max, move]:
		a.resize(n)
		a.fill(0)
	for x in W:
		for y in range(0, 3):
			floor_[idx(Vector2i(x, y))] = AIR
		for y in range(3, 11):
			var r := randi_range(0, 9)
			floor_[idx(Vector2i(x, y))] = BRANCH if r == 0 else (LEAF if r == 1 else GRASS)
		for y in range(11, 24):
			var r := randi_range(0, 75)
			var f := DIRT
			if r == 0 or r == 1:
				f = FOOD_STORE
			elif r == 2:
				f = BIRTH_PLACE
			elif r == 3 or r == 4:
				f = TRAINER
			floor_[idx(Vector2i(x, y))] = f
	# start units: two workers per player on the grass layer (original: player 2 had AP 500 for testing)
	for c in [Vector2i(4, 7), Vector2i(6, 7)]:
		_spawn(c, WORKER)
	for c in [Vector2i(27, 7), Vector2i(25, 7)]:
		_spawn(c, WORKER + 10)
	floor_[idx(Vector2i(5, 7))] = HOLE
	floor_[idx(Vector2i(26, 7))] = HOLE
	# the dug start tunnels below the holes
	for c in [Vector2i(5, 11), Vector2i(5, 12), Vector2i(5, 13), Vector2i(5, 14), Vector2i(5, 15), Vector2i(5, 16),
			Vector2i(6, 16), Vector2i(4, 16)]:
		floor_[idx(c)] = DUG
		floor_[idx(Vector2i(W - 1 - c.x, c.y))] = DUG
	player_turn = 0
	cursor_cell = Vector2i.ZERO
	selected = false
	winner = -1
	finished = false
	board_changed.emit()
	turn_changed.emit()
	selection_changed.emit()
	cursor_moved.emit()


func _spawn(c: Vector2i, unit_type: int) -> void:
	var i := idx(c)
	typ[i] = unit_type
	life_max[i] = 50
	life[i] = 50
	move_max[i] = 5
	move[i] = 5
	floor_[i] = GRASS


func move_cursor(c: Vector2i) -> void:
	cursor_cell = Vector2i(clampi(c.x, 0, W - 1), clampi(c.y, 0, H - 1))
	cursor_moved.emit()


## Enter on a unit of the player whose turn it is.
func select_at_cursor() -> bool:
	if finished:
		return false
	var t := typ[idx(cursor_cell)]
	if t != 0 and owner_of(t) == player_turn:
		selected = true
		selection_changed.emit()
		return true
	return false


func deselect() -> void:
	if selected:
		selected = false
		selection_changed.emit()


## Not in the original: hand over to the other player and refresh that player's action points.
func end_turn() -> void:
	if finished:
		return
	selected = false
	player_turn = 1 - player_turn
	for i in W * H:
		if typ[i] != 0 and owner_of(typ[i]) == player_turn:
			move[i] = move_max[i]
	selection_changed.emit()
	turn_changed.emit()
	board_changed.emit()


func count_units(player: int) -> int:
	var n := 0
	for i in W * H:
		if typ[i] != 0 and owner_of(typ[i]) == player:
			n += 1
	return n


## The selected unit at `from` tries to step onto `to`. Returns the cell the cursor ends on
## (it follows the unit when it moved).
func act(from: Vector2i, to: Vector2i) -> Vector2i:
	if finished or not in_bounds(to) or level_of(from) != level_of(to):
		return from
	var o := idx(from)
	var n := idx(to)
	if typ[n] != 0:
		_attack(o, n)
		board_changed.emit()
		return from
	var result := from
	var t := typ[o]
	match floor_[n]:
		GRASS, DUG:
			if move[o] > 0:
				_move_unit(o, n, 1)
				result = to
		HOLE:  # drop down into row 11 of the same column
			var below := Vector2i(to.x, 11)
			if move[o] > 0 and typ[idx(below)] == 0:
				_move_unit(o, idx(below), 1)
				result = below
		DIRT:  # must be dug away: workers only, 2 AP
			if move[o] > 1 and is_worker(t):
				_move_unit(o, n, 2)
				floor_[n] = DUG
				result = to
		LEAF:  # only an unladen worker can lift it
			if move[o] > 0 and (t == WORKER or t == WORKER + 10):
				_move_unit(o, n, 1)
				typ[n] += 2
				floor_[n] = GRASS
				result = to
		BRANCH:
			if move[o] > 0 and (t == WORKER or t == WORKER + 10):
				_move_unit(o, n, 1)
				typ[n] += 1
				floor_[n] = GRASS
				result = to
		FOOD_STORE:
			if move[o] > 0:
				if (t == WORKER or t == WORKER + 10) and stat[n] == 0:
					stat[n] = 4
					typ[o] += 3
					move[o] -= 1
				elif (t == WORKER_LEAF or t == WORKER_LEAF + 10) and stat[n] > 0:
					# a leaf carrier refreshes the store (the original's AND/OR precedence made this check looser)
					stat[n] = 0
					typ[o] -= 2
					move[o] -= 1
		BIRTH_PLACE:  # food in, a new worker comes out
			if move[o] > 0 and (t == WORKER_FOOD or t == WORKER_FOOD + 10):
				typ[n] = t - 3
				life_max[n] = 50
				life[n] = 50
				move_max[n] = 5
				move[n] = 2
				typ[o] -= 3
				move[o] -= 1
		TRAINER:
			if move[o] > 0:
				if (t == WORKER or t == WORKER + 10) and stat[n] == 0:
					stat[n] = 4
					typ[o] += 4
					life[o] += 50
					life_max[o] += 50
					move[o] -= 1
				elif (t == FIGHTER_WEAK or t == FIGHTER_WEAK + 10) and stat[n] == 0:
					stat[n] = 4
					typ[o] += 1
					life[o] += 50
					life_max[o] += 50
					move_max[o] += 2
					move[o] -= 1
				elif (t == WORKER_FOOD or t == WORKER_FOOD + 10) and stat[n] > 0:
					stat[n] = 0
					typ[o] -= 3
					move[o] -= 1
		_:
			pass  # AIR: "what does it want in the air?"
	board_changed.emit()
	return result


func _move_unit(o: int, n: int, cost: int) -> void:
	typ[n] = typ[o]
	life_max[n] = life_max[o]
	life[n] = life[o]
	move_max[n] = move_max[o]
	move[n] = move[o] - cost
	typ[o] = 0
	life_max[o] = 0
	life[o] = 0
	move_max[o] = 0
	move[o] = 0


# Added (original: "Da steht schon jemand auf dem Feld! Interaktion muss kommen!")
func _attack(o: int, n: int) -> void:
	if owner_of(typ[o]) == owner_of(typ[n]) or move[o] < 1:
		return
	move[o] -= 1
	life[n] -= DAMAGE[kind_of(typ[o])]
	if life[n] <= 0:
		var loser := owner_of(typ[n])
		typ[n] = 0
		life[n] = 0
		life_max[n] = 0
		move[n] = 0
		move_max[n] = 0
		if count_units(loser) == 0:
			finished = true
			winner = 1 - loser
			selected = false
			selection_changed.emit()
			game_over.emit(winner)
