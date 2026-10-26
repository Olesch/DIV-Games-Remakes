extends Node
## Autoload "Game": the level data being edited and the editor's global settings.
## DIV: GLOBAL Map[35].Layer[1].Xpos[39].Ypos[29], stage, set (CASTEDIT.PRG).

const ROOMS := 36          # 6 x 6 room grid; room graphic in the old FPG was 900 + 2*room
const GRID_W := 6
const COLS := 40           # 40 x 30 cells of 20 px = 800 x 600
const ROWS := 30
const TILE := 20
const SCREEN_W := 800
const SCREEN_H := 600
const START_ROOM := 13     # DIV: Stage=13

enum Layer { FLOOR = 0, OBJECTS = 1 }

## Size of a LevelN.dat file: the raw Map[] array, 86400 little-endian int32.
const LEVEL_BYTES := ROOMS * 2 * COLS * ROWS * 4
## Sets 1 and 2 are Oleg's originals (read-only); 3 and 4 are user slots (new, the original overwrote
## saves/LevelN.dat). The prefix keeps the names apart in the browser storage that all games of the web
## site share; Castle reads the slots too. CastleLevel1/2.dat from an earlier version are ignored.
const ORIGINAL_SETS := [1, 2]
const USER_SLOTS := [3, 4]
const SAVED_PATH := "user://CastleLevel%d.dat"
const ORIGINAL_PATH := "res://assets/dat/level%d.dat"
const EXPORT_NAME := "CastleLevel%d.dat"

## Raw int32 dump of Map[]: value index ((room*2 + layer)*40 + x)*30 + y.
var map := PackedInt32Array()
var level_set := 0         # DIV: set (1 or 2); 3 and 4 = user slots
var room := START_ROOM     # DIV: stage


func _ready() -> void:
	_setup_input()
	if "--autotest" in OS.get_cmdline_user_args():
		var test: Node = load("res://scripts/debug/autotest.gd").new()
		test.name = "AutoTest"
		add_child(test)


func is_user_slot(n: int) -> bool:
	return n in USER_SLOTS


func has_saved_set(n: int) -> bool:
	return is_user_slot(n) and FileAccess.file_exists(SAVED_PATH % n)


## Sets 1/2: the original saves/LevelN.dat (shipped as res://assets/dat/levelN.dat).
## Slots 3/4: user://CastleLevelN.dat; false if the slot is empty or the file has the wrong size.
func load_levelset(n: int) -> bool:
	var path: String = SAVED_PATH % n if is_user_slot(n) else ORIGINAL_PATH % n
	var bytes := FileAccess.get_file_as_bytes(path)
	if not use_bytes(bytes):
		push_warning("Level data missing or wrong size: %s (%d bytes)" % [path, bytes.size()])
		return false
	level_set = n
	room = START_ROOM
	return true


## An empty user slot starts as a copy of original set `source`; it is written on the first Ctrl+S.
func start_slot_from(slot: int, source: int) -> bool:
	if not load_levelset(source):
		return false
	level_set = slot
	return true


## Replaces the set being edited with the contents of a LevelN.dat file; false if the size is wrong.
func use_bytes(bytes: PackedByteArray) -> bool:
	if bytes.size() != LEVEL_BYTES:
		return false
	map = bytes.to_int32_array()
	return true


## DIV: Control+S - save("saves\levelN.dat", OFFSET Map, ...). Same raw format, written to user slot 3/4,
## which then becomes the open set.
func save_to_slot(slot: int) -> bool:
	assert(is_user_slot(slot))
	var f := FileAccess.open(SAVED_PATH % slot, FileAccess.WRITE)
	if f == null:
		push_error("Cannot write %s: %s" % [SAVED_PATH % slot, error_string(FileAccess.get_open_error())])
		return false
	f.store_buffer(map.to_byte_array())
	f.close()
	level_set = slot
	return true


func delete_slot(slot: int) -> void:
	if has_saved_set(slot):
		DirAccess.remove_absolute(SAVED_PATH % slot)


func index_of(r: int, layer: int, x: int, y: int) -> int:
	return ((r * 2 + layer) * COLS + x) * ROWS + y


func cell(layer: int, x: int, y: int) -> int:
	return map[index_of(room, layer, x, y)]


func set_cell(layer: int, x: int, y: int, value: int) -> void:
	map[index_of(room, layer, x, y)] = value


func to_title() -> void:
	get_tree().change_scene_to_file("res://scenes/title.tscn")


func start_editor(n: int) -> void:
	if load_levelset(n):
		open_editor()


func open_editor() -> void:
	get_tree().change_scene_to_file("res://scenes/editor.tscn")


# ----------------------------------------------------------------- input map

## Original keys (DIV scan codes = physical positions): _z/_x choosers (Z is Y on Oleg's German keyboard),
## _i/_j/_k/_l rooms, cursor keys, _del, _enter, Ctrl+_s. H/F1 (help), Esc (back), Ctrl+E/Ctrl+O
## (export/import), D and Enter on the start screen (delete a slot) are new. Ctrl means Cmd on a Mac.
func _setup_input() -> void:
	_add(&"save", [KEY_S], true)                  # DIV: key(_control) AND key(_s)
	_add(&"export", [KEY_E], true)
	_add(&"import", [KEY_O], true)
	_add(&"delete_slot", [KEY_D])
	_add(&"confirm", [KEY_ENTER, KEY_KP_ENTER])
	_add(&"pick_floor", [KEY_Z])                  # DIV: key(_z) -> Stat=2 (Bodenwahl)
	_add(&"pick_object", [KEY_X])                 # DIV: key(_x) -> Stat=3 (Objectwahl)
	_add(&"cursor_left", [KEY_LEFT, KEY_KP_4])
	_add(&"cursor_right", [KEY_RIGHT, KEY_KP_6])
	_add(&"cursor_up", [KEY_UP, KEY_KP_8])
	_add(&"cursor_down", [KEY_DOWN, KEY_KP_2])
	_add(&"room_up", [KEY_I])                     # DIV: key(_i) Stage-=6
	_add(&"room_down", [KEY_K])                   # DIV: key(_k) Stage+=6
	_add(&"room_left", [KEY_J])                   # DIV: key(_j) Stage-=1
	_add(&"room_right", [KEY_L])                  # DIV: key(_l) Stage+=1
	_add(&"place", [KEY_ENTER, KEY_KP_ENTER])     # DIV: key(_enter)
	_add(&"erase", [KEY_DELETE, KEY_KP_PERIOD])   # DIV: key(_del)
	_add(&"help", [KEY_H, KEY_F1])                # new: help overlay
	_add(&"back", [KEY_ESCAPE])                   # new: back to the level set choice
	_add(&"set_1", [KEY_1, KEY_KP_1])
	_add(&"set_2", [KEY_2, KEY_KP_2])
	_add(&"set_3", [KEY_3, KEY_KP_3])
	_add(&"set_4", [KEY_4, KEY_KP_4])


func _add(action: StringName, keys: Array, ctrl: bool = false) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k: int in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k as Key
		ev.command_or_control_autoremap = ctrl
		InputMap.action_add_event(action, ev)
