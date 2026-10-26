extends Node
## Autoload "Game": level list, best times (DIV: HiTimes[] / saves\Ballers.dat) and scene flow.

signal hi_times_changed

## The levels contained in Baller.fpg: graphic code, size, start point (control point 1).
## The original always played code 117 (global `Level=117`); the level list is new.
const LEVELS: Array[Dictionary] = [
	{"code": 100, "name": "Level 1", "size": Vector2i(640, 480), "start": Vector2i(75, 101)},
	{"code": 101, "name": "Level 2", "size": Vector2i(640, 480), "start": Vector2i(48, 65)},
	{"code": 102, "name": "Level 3", "size": Vector2i(640, 480), "start": Vector2i(211, 163)},
	{"code": 105, "name": "Level 6", "size": Vector2i(2048, 480), "start": Vector2i(122, 162)},
	{"code": 110, "name": "Level 11", "size": Vector2i(640, 480), "start": Vector2i(97, 134)},
	{"code": 115, "name": "Level 16", "size": Vector2i(1024, 768), "start": Vector2i(175, 84)},
	{"code": 116, "name": "Level 17", "size": Vector2i(640, 480), "start": Vector2i(76, 62)},
	{"code": 117, "name": "Level 18", "size": Vector2i(1024, 768), "start": Vector2i(56, 69)},
]
const DEFAULT_LEVEL_INDEX := 7  # code 117, the level the original had hard-coded
const HI_TIMES_COUNT := 31      # DIV: HiTimes[30]
## Best times shipped with the original's saves\Ballers.dat (frames; index = code - 99), used until a user file exists.
const ORIGINAL_HI_TIMES: Array[int] = [0, 156, 515, 453, 0, 0, 243, 0, 0, 0, 0, 704, 0, 0, 0, 0, 457, 252, 2196,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

var save_path := "user://ballers.dat"
var hi_times: PackedInt32Array = PackedInt32Array()
var selected_level := DEFAULT_LEVEL_INDEX


func _ready() -> void:
	load_hi_times()
	if "--autotest" in OS.get_cmdline_user_args():
		save_path = "user://ballers_autotest.dat"
		hi_times = PackedInt32Array(ORIGINAL_HI_TIMES)
		add_child(AutoTest.new())


func hi_time_index(code: int) -> int:
	return code - 99  # DIV: LevelReal = Level - 99


func hi_time(code: int) -> int:
	return hi_times[hi_time_index(code)]


## DIV: a stored time of 0 (none) or a worse one is replaced. Returns true if the record changed.
func submit_time(code: int, frames: int) -> bool:
	var i := hi_time_index(code)
	if hi_times[i] == 0 or hi_times[i] > frames:
		hi_times[i] = frames
		save_hi_times()
		hi_times_changed.emit()
		return true
	return false


func load_hi_times() -> void:
	hi_times = PackedInt32Array(ORIGINAL_HI_TIMES)
	var f := FileAccess.open(save_path, FileAccess.READ)
	if f == null:
		return
	for i in HI_TIMES_COUNT:
		if f.get_position() + 4 > f.get_length():
			break
		hi_times[i] = f.get_32()


func save_hi_times() -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		push_warning("cannot save best times to " + save_path)
		return
	for v in hi_times:
		f.store_32(v)


func start_level(level_index: int) -> void:
	selected_level = level_index
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func show_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
