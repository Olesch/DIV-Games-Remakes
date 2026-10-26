extends Node
## Autoload "Game": the GLOBAL variables of ATOMS.PRG, scoring, hiscores, input polling.
##
## Timing: the original runs at DIV's default 18 fps. Delays are converted to seconds
## (n frames / 18) in main.gd and cursor.gd; nothing else depends on frame counts.

const FPS := 18
var score_files: Array[String] = ["user://ATSCEA.DAT", "user://ATSCHA.DAT"]  # easy / hard (DIV: Saves\ATSCEA.DAT, ATSCHA.DAT)

var board := AtomBoard.new()

var cursor_state := 0                    # 0 = moving, 1 = creating connections (DIV: CursorState)
var connections: Array[int] = []         # DIV: Connections[10]; [0] is the atom being built
var con_info := 0                        # how many upcoming atoms are shown (DIV: ConInfo)
var points := 0                          # DIV: Points
var hi_easy := 0                         # DIV: HiEasy
var hi_hard := 0                         # DIV: HiHard
var given_atoms := 0                     # DIV: GivenAtoms
var bombs := 0                           # DIV: Bombs
var bombs_supply := 0                    # DIV: bombssupply (points collected towards the next bomb)
var bomb_need := 0                       # DIV: BombSNeed
var quad := 0                            # 0 = normal, 1 = fewer 4-bond atoms (DIV: Quad)

var mode: int:                           # 0 = easy, 1 = hard (DIV: MODE)
	get:
		return board.mode
	set(v):
		board.mode = v
var field: int:                          # index of the last row/column (DIV: Field)
	get:
		return board.field
	set(v):
		board.field = v

func _ready() -> void:
	connections.resize(11)
	_setup_input()
	load_hiscores()


## DIV: rand(lo, hi) - inclusive.
func rand(lo: int, hi: int) -> int:
	return randi_range(lo, hi)


## Random bond count of the next atom (DIV: rand(1,4) or, with fewer 4s, rand(3,13)/3).
func random_connections() -> int:
	if quad == 0:
		return rand(1, 4)
	return rand(3, 13) / 3


## Removes the checked group (if complete) and awards the points (DIV: PROCESS KILL).
func resolve_kill() -> void:
	var counts := board.kill()
	if given_atoms == 0:
		points += counts
		bombs_supply += counts
		if bombs_supply >= bomb_need:
			bombs_supply -= bomb_need
			bombs += 1
	else:
		given_atoms += counts


## Scatters the pre-set atoms over the empty board (the FOR loop in the DIV main code).
## Every atom gets random bonds; if it immediately forms a complete molecule it is removed and
## the counter gets it back, so exactly the chosen number of atoms stays on the board.
func place_given_atoms() -> void:
	while given_atoms > 0:
		given_atoms += 1
		var x: int
		var y: int
		if mode == 0:
			x = rand(0, field)
			y = rand(0, field)
		else:
			x = rand(1, field - 1)
			y = rand(1, field - 1)
		var c := board.cell(x, y)
		if c.exists:
			given_atoms += 1
		else:
			c.exists = true
			c.up = rand(0, 1) == 1
			c.down = rand(0, 1) == 1
			c.left = rand(0, 1) == 1
			c.right = rand(0, 1) == 1
			board.check(x, y)
			resolve_kill()
		given_atoms -= 2   # end of loop body + FOR decrement


func reset_round_board() -> void:
	cursor_state = 0
	board.clear_all()


# --- hiscores (original: commented-out Save of HiEasy/HiHard) ---------------------------------

func load_hiscores() -> void:
	hi_easy = _read_score(score_files[0])
	hi_hard = _read_score(score_files[1])


func _read_score(path: String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null or f.get_length() < 4:
		return 0
	return f.get_32()


## Stores the score of the round that just ended if it beats the stored best for its mode.
func submit_score() -> void:
	if mode == 0:
		if points > hi_easy:
			hi_easy = points
			_write_score(score_files[0], hi_easy)
	elif points > hi_hard:
		hi_hard = points
		_write_score(score_files[1], hi_hard)


func _write_score(path: String, value: int) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_32(value)


# --- input map --------------------------------------------------------------------------------

func _setup_input() -> void:
	# physical keys = DIV scan codes; the arrow keys share their code with the numpad keys
	var map := {
		&"up": [KEY_UP, KEY_KP_8],              # _up
		&"down": [KEY_DOWN, KEY_KP_2],          # _down
		&"left": [KEY_LEFT, KEY_KP_4],          # _left
		&"right": [KEY_RIGHT, KEY_KP_6],        # _right
		&"confirm": [KEY_ENTER, KEY_KP_ENTER],  # _enter
		&"bomb": [KEY_BACKSPACE],               # _backspace
		&"new_round": [KEY_ESCAPE],             # _esc
		&"rules": [KEY_H],                      # _h
		&"choice_1": [KEY_1],                   # _1
		&"choice_2": [KEY_2],                   # _2
	}
	for action: StringName in map:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code: Key in map[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = code
			InputMap.action_add_event(action, ev)
