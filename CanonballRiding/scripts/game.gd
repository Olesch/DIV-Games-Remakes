extends Node
## Autoload "Game": the GLOBAL section of the DIV program (wind, score, hiscores, player count)
## plus input actions and hiscore files.

signal score_changed(value: int)
signal hiscores_changed

const MAX_WIND := 25
const SCORE_FILES := ["", "user://CbScore1.sav", "user://CbScore2.sav"]  # DIV: saves\CbScore1/2.sav
const SEED_FILES := ["", "res://assets/dat/cbscore1.json", "res://assets/dat/cbscore2.json"]

## DIV: Wind, -25 (blows left) .. 25 (blows right); changed gradually by WindRegulator.
var wind: int = 0
var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)
## 1 or 2 (DIV: Playercount 1 / 11)
var player_count: int = 1
## Best score for one player [index 1] and for two players [index 2] (DIV: Hiscore1/2).
var hiscores: Array[int] = [0, 0, 0]


func _ready() -> void:
	_register_input_actions()
	for n in [1, 2]:
		hiscores[n] = _load_hiscore(n)
	hiscores_changed.emit()


func new_game(players: int) -> void:
	player_count = players
	score = 0


func set_hiscore(players: int, value: int) -> void:
	hiscores[players] = value
	hiscores_changed.emit()
	var file := FileAccess.open(SCORE_FILES[players], FileAccess.WRITE)
	if file:
		file.store_32(value)  # same raw int32 format as the DIV .sav files


## Hiscore from user://, otherwise seeded from the original DIV save (converted to assets/dat).
func _load_hiscore(players: int) -> int:
	if FileAccess.file_exists(SCORE_FILES[players]):
		var file := FileAccess.open(SCORE_FILES[players], FileAccess.READ)
		if file and file.get_length() >= 4:
			return file.get_32()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SEED_FILES[players]))
	if parsed is Dictionary:
		var values: Array = parsed.get("int32_le", [])
		if not values.is_empty():
			return int(values[0])
	return 0


func _register_input_actions() -> void:
	_add_keys(&"p1_left", [KEY_LEFT, KEY_KP_4])       # DIV: _left
	_add_keys(&"p1_right", [KEY_RIGHT, KEY_KP_6])     # DIV: _right
	_add_keys(&"p2_left", [KEY_A])                    # DIV: _a
	_add_keys(&"p2_right", [KEY_D])                   # DIV: _d
	_add_keys(&"start_1p", [KEY_1, KEY_KP_1])         # DIV: _1
	_add_keys(&"start_2p", [KEY_2, KEY_KP_2])         # DIV: _2
	_add_keys(&"escape", [KEY_ESCAPE])                # DIV: _esc


func _add_keys(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key: int in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key as Key
		InputMap.action_add_event(action, event)
