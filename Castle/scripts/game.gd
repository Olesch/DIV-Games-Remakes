extends Node
## Autoload "Game": the GLOBAL section of CASTLE.PRG (Stage, Stat, Difficulty, xhero/yhero, Map)
## plus level/save file handling and the room helpers every entity uses.

const FPS := 24  # DIV: set_fps(24,0); physics ticks are set to 24 so one tick = one DIV frame

const ROOMS := 36           # DIV: Map[35]
const COLS := 40            # Xpos[39]
const ROWS := 30            # Ypos[29]
const TILE := 20            # one map cell = 20x20 pixels
const SCREEN_W := 800
const SCREEN_H := 600
const SAVE_INTS := 1 + 1 + HeroStats.FILE_INTS + 1 + 1 + 1 + ROOMS * 2 * COLS * ROWS  # 86428
const LEVEL_BYTES := ROOMS * 2 * COLS * ROWS * 4   # LEVELn.DAT: the raw Map array

const DIFFICULTY_NAMES := ["Baby", "Schueler", "Jugendlicher", "Erwachsener", "Kaempfer", "Schlossherr", "Diabolo"]

# Terrain codes (layer 0)
const T_FLOOR := 6
const T_SILVER_DOOR := 11
const T_SECRET := 20            # looks like wall, walkable
const T_WALL := 22
const T_LOOPHOLE := 26          # arrow slit: blocks walking, arrows fly through
const T_THIN_LOOPHOLE := 28     # thin slit: arrows fly through only while moved <= 80
const T_SLIME := 40
const T_GOLD_DOOR := 71
const T_TRAP_TRIGGER := 211     # steps on it: nearby open trapdoors (213) shut
const T_TRAP_SHUT := 212        # closed trapdoor: wall
const T_TRAP_OPEN := 213        # open trapdoor: floor
const T_TRAP_OPENER := 214      # steps on it: nearby shut trapdoors (212) open

var stage: int = 0                 # DIV: Stage (room 0..35)
var difficulty: int = 0            # DIV: Difficulty (-3..3)
var xhero: int = 0                 # DIV: xhero (saved hero position)
var yhero: int = 0
var map: PackedInt32Array = PackedInt32Array()   # DIV: Map[room].Layer[l].Xpos[x].Ypos[y]
var stat: HeroStats = HeroStats.new()
var hero: Hero = null
var world: World = null
## true when the next game starts from a save slot (hero placed at xhero/yhero)
var loaded_from_save: bool = false


func _ready() -> void:
	_register_input_actions()
	RenderingServer.set_default_clear_color(Color.BLACK)
	map.resize(ROOMS * 2 * COLS * ROWS)
	if "--autotest" in OS.get_cmdline_user_args():
		var test := AutoTest.new()
		test.name = "AutoTest"
		get_tree().root.add_child.call_deferred(test)


# ----------------------------------------------------------------- map access

func map_index(room: int, layer: int, gx: int, gy: int) -> int:
	return ((room * 2 + layer) * COLS + gx) * ROWS + gy


func cell(layer: int, gx: int, gy: int) -> int:
	if stage < 0 or stage >= ROOMS or gx < 0 or gx >= COLS or gy < 0 or gy >= ROWS:
		return 0
	return map[map_index(stage, layer, gx, gy)]


func set_cell(layer: int, gx: int, gy: int, value: int) -> void:
	if stage < 0 or stage >= ROOMS or gx < 0 or gx >= COLS or gy < 0 or gy >= ROWS:
		return
	map[map_index(stage, layer, gx, gy)] = value


## Terrain code under pixel position (px, py) in the current room (DIV: Map[Stage].Layer[0].Xpos[x/20].Ypos[y/20]).
func terrain_at(px: int, py: int) -> int:
	return cell(0, px / TILE, py / TILE)


## Tiles an entity cannot walk onto (hero without the Alt+Ctrl cheat, enemies of spec 0..3).
func is_walkable_blocker(t: int) -> bool:
	return t == T_WALL or t == T_LOOPHOLE or t == T_THIN_LOOPHOLE or t == T_SILVER_DOOR \
		or t == T_GOLD_DOOR or t == T_TRAP_SHUT


# ----------------------------------------------------------------- game setup

## Level sets 3 and 4 are the user slots of the Castedit port (new). Godot keeps each project's user://
## in its own folder (.../app_userdata/<project name>, on the web inside the one IndexedDB store all games
## of the site share), so Castle reads Castedit's folder next to its own.
func edited_level_path(n: int) -> String:
	return OS.get_user_data_dir().get_base_dir().path_join("Castedit").path_join("CastleLevel%d.dat" % n)


## Sets 1/2 always exist; 3/4 only when Castedit has saved that slot.
func has_levelset(n: int) -> bool:
	return n == 1 or n == 2 or ((n == 3 or n == 4) and FileAccess.file_exists(edited_level_path(n)))


## Sets 1/2: the original LEVELn.DAT; 3/4: Castedit's CastleLevelN.dat.
func load_levelset(n: int) -> bool:
	if not has_levelset(n):
		return false
	var path := "res://assets/dat/level%d.dat" % n if n <= 2 else edited_level_path(n)
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() != LEVEL_BYTES:
		push_warning("Level data missing or wrong size: %s (%d bytes)" % [path, bytes.size()])
		return false
	map = bytes.to_int32_array()
	return true


func start_new_game(diff: int) -> void:
	difficulty = diff
	stage = 0
	xhero = 30
	yhero = 30
	stat = HeroStats.new_game(difficulty)
	loaded_from_save = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func start_loaded_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func to_title() -> void:
	hero = null
	get_tree().change_scene_to_file("res://scenes/title.tscn")


# ----------------------------------------------------------------- save slots
# File layout = DIV `save("Saves\castleN.dat", OFFSET stage, ...)`: raw little-endian int32:
# Stage, Campaign, Stat[Hero_id + 22 fields], Difficulty, xhero, yhero, Map (86400) = 86428 ints.

func slot_user_path(slot: int) -> String:
	return "user://castle%d.dat" % slot


func slot_bundled_path(slot: int) -> String:
	return "res://assets/dat/castle%d.dat" % slot


func _slot_bytes(slot: int) -> PackedByteArray:
	if FileAccess.file_exists(slot_user_path(slot)):
		return FileAccess.get_file_as_bytes(slot_user_path(slot))
	if FileAccess.file_exists(slot_bundled_path(slot)):
		return FileAccess.get_file_as_bytes(slot_bundled_path(slot))
	return PackedByteArray()


func slot_available(slot: int) -> bool:
	return _slot_bytes(slot).size() == SAVE_INTS * 4


## Returns true and prepares the global state when the slot holds a valid save.
func load_slot(slot: int) -> bool:
	var bytes := _slot_bytes(slot)
	if bytes.size() != SAVE_INTS * 4:
		return false
	var v := bytes.to_int32_array()
	stage = v[0]
	# v[1] = Campaign (unused), v[2] = Hero_id (a DIV process id, meaningless now)
	stat = HeroStats.new()
	stat.from_ints(v, 3)
	var o := 3 + HeroStats.FILE_INTS - 1
	difficulty = v[o]
	xhero = v[o + 1]
	yhero = v[o + 2]
	map = v.slice(o + 3)
	loaded_from_save = true
	return true


func save_slot(slot: int, hero_x: int, hero_y: int) -> void:
	xhero = hero_x
	yhero = hero_y
	var v := PackedInt32Array()
	v.append(stage)
	v.append(0)
	v.append(0)
	for n in stat.to_ints():
		v.append(n)
	v.append(difficulty)
	v.append(xhero)
	v.append(yhero)
	v.append_array(map)
	var f := FileAccess.open(slot_user_path(slot), FileAccess.WRITE)
	if f == null:
		push_error("Cannot write " + slot_user_path(slot))
		return
	f.store_buffer(v.to_byte_array())
	f.close()


# ----------------------------------------------------------------- input

func _register_input_actions() -> void:
	# DIV: Hero(_up,_down,_left,_right,_end,_del,_ins,_pgup) and Statistic on _pgdn.
	# Extra letter/space keys are new, for keyboards without the navigation block.
	_add_keys(&"hero_up", [KEY_UP, KEY_KP_8])
	_add_keys(&"hero_down", [KEY_DOWN, KEY_KP_2])
	_add_keys(&"hero_left", [KEY_LEFT, KEY_KP_4])
	_add_keys(&"hero_right", [KEY_RIGHT, KEY_KP_6])
	_add_keys(&"hero_attack", [KEY_END, KEY_KP_1, KEY_SPACE])        # DIV: _end
	_add_keys(&"hero_weapon", [KEY_DELETE, KEY_KP_PERIOD, KEY_X])    # DIV: _del
	_add_keys(&"hero_run", [KEY_INSERT, KEY_KP_0, KEY_SHIFT])        # DIV: _ins
	_add_keys(&"hero_magic", [KEY_PAGEUP, KEY_KP_9, KEY_C])          # DIV: _pgup
	_add_keys(&"hero_stats", [KEY_PAGEDOWN, KEY_KP_3, KEY_V])        # DIV: _pgdn
	_add_keys(&"hero_save_mod", [KEY_CTRL])                          # DIV: key(_control) on a save point
	_add_keys(&"hero_cheat_alt", [KEY_ALT])                          # DIV: key(_alt) AND key(_control)
	_add_keys(&"slot_1", [KEY_1])
	_add_keys(&"slot_2", [KEY_2])
	_add_keys(&"slot_3", [KEY_3])
	_add_keys(&"slot_4", [KEY_4])
	_add_keys(&"save_f1", [KEY_F1])
	_add_keys(&"save_f2", [KEY_F2])
	_add_keys(&"save_f3", [KEY_F3])
	_add_keys(&"save_f4", [KEY_F4])
	_add_keys(&"menu_new", [KEY_S])
	_add_keys(&"menu_load", [KEY_L])
	_add_keys(&"menu_left", [KEY_LEFT, KEY_KP_4])
	_add_keys(&"menu_right", [KEY_RIGHT, KEY_KP_6])
	_add_keys(&"menu_confirm", [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE])
	_add_keys(&"back_to_title", [KEY_ESCAPE])  # new: DIV could only quit with Ctrl+Esc


func _add_keys(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key: int in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key as Key
		InputMap.action_add_event(action, event)


## Save slot (1..4) requested by this key event while standing on a save point: Ctrl+digit, or F1..F4
## (new: browsers grab Ctrl+digit). 0 = not a save request.
func save_slot_for_event(event: InputEvent) -> int:
	for i in range(1, 5):
		if event.is_action_pressed("save_f%d" % i, false, true):
			return i
	if event is InputEventKey and event.ctrl_pressed:
		return slot_for_event(event)
	return 0


## Slot/number (1..4) of a digit key press, else 0.
func slot_for_event(event: InputEvent) -> int:
	for i in range(1, 5):
		if event.is_action_pressed("slot_%d" % i, false, true):
			return i
	return 0
