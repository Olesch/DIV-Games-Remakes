extends Node
## Autoload "Options": the values the DIV program hard-codes in its GLOBAL section, made
## configurable. Defaults are exactly the original's. Changes are announced with `changed`
## and remembered in user://rotators.cfg (not while an autotest runs).

signal changed(key: StringName)

enum SpeedMode { RANDOM, TABLE, COUNTED }  # DIV: Mode 0 / 1 / 2
enum Trails { ALL, LAST_ONLY, OFF }        # DIV: Modeb 0 / 1 (OFF is new)
enum TrailColour { WHITE, RAINBOW, GREYS }

const SAVE_PATH := "user://rotators.cfg"

## Original values (DIV globals and literals of SPACE2.PRG).
const DEFAULTS := {
	&"speed_mode": SpeedMode.COUNTED,  # DIV: Mode=2
	&"chain_length": 20,               # DIV: Howmuch_counts=20 -> 22 rotators
	&"first_speed": 5000,              # DIV: Dreher1(...,5000), thousandths of a degree per frame
	&"speed_step": 1000,               # DIV: Rotsp+1000 for every next rotator
	&"random_range": 4500,             # DIV: Rand(4500,-4500) (first rotator Rand(2500,-2500))
	&"size": 50,                       # DIV: Size_ins=50 (percent)
	&"trails": Trails.ALL,             # DIV: Modeb=0
	&"trail_colour": TrailColour.WHITE,  # DIV: put_pixel(..., 15) = white
	&"show_rotators": true,
	&"fps": 100,                       # DIV: set_fps(100,0)
}

## UI description of every option: label, kind ("enum"/"int"/"bool"), range/step, value names.
const SPECS := [
	{"key": &"speed_mode", "label": "Speed mode", "kind": "enum",
		"names": ["Random", "Table", "Counted"]},
	{"key": &"chain_length", "label": "Rotators", "kind": "int", "min": 0, "max": 62, "step": 1,
		"fmt": "rotators"},
	{"key": &"first_speed", "label": "First speed", "kind": "int", "min": -30000, "max": 30000,
		"step": 500, "fmt": "deg"},
	{"key": &"speed_step", "label": "Speed step", "kind": "int", "min": -10000, "max": 10000,
		"step": 250, "fmt": "deg_signed"},
	{"key": &"random_range", "label": "Random range", "kind": "int", "min": 500, "max": 30000,
		"step": 500, "fmt": "deg_pm"},
	{"key": &"size", "label": "Size", "kind": "int", "min": 10, "max": 200, "step": 5, "fmt": "percent"},
	{"key": &"trails", "label": "Trails", "kind": "enum", "names": ["All rotators", "Last only", "Off"]},
	{"key": &"trail_colour", "label": "Trail colour", "kind": "enum", "names": ["White", "Rainbow", "Greys"]},
	{"key": &"show_rotators", "label": "Show rotators", "kind": "bool"},
	{"key": &"fps", "label": "Frames/second", "kind": "int", "min": 10, "max": 400, "step": 10, "fmt": "plain"},
]

## DIV: Speeds[12]=1000,...,12000 (13 entries, the last one 0).
const SPEED_TABLE: Array[int] = [1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 0]

var values: Dictionary = DEFAULTS.duplicate()
var _persist := true


func _ready() -> void:
	_persist = not ("--autotest" in OS.get_cmdline_user_args())
	_register_input_actions()
	_load()
	Engine.physics_ticks_per_second = get_value(&"fps")


func get_value(key: StringName) -> Variant:
	return values[key]


func set_value(key: StringName, value: Variant) -> void:
	if values[key] == value:
		return
	values[key] = value
	if key == &"fps":
		Engine.physics_ticks_per_second = int(value)
	_save()
	changed.emit(key)


func spec_of(key: StringName) -> Dictionary:
	for spec: Dictionary in SPECS:
		if spec["key"] == key:
			return spec
	return {}


## Move an option one step (enum/bool wrap around, numbers clamp).
func step_value(key: StringName, direction: int) -> void:
	var spec := spec_of(key)
	match spec["kind"]:
		"enum":
			var count: int = spec["names"].size()
			set_value(key, posmod(int(values[key]) + direction, count))
		"bool":
			set_value(key, not values[key])
		_:
			set_value(key, clampi(int(values[key]) + direction * int(spec["step"]), spec["min"], spec["max"]))


func format_value(key: StringName) -> String:
	var spec := spec_of(key)
	var v: Variant = values[key]
	match spec["kind"]:
		"enum":
			return spec["names"][int(v)]
		"bool":
			return "Yes" if v else "No"
	match spec.get("fmt", "plain"):
		"rotators":
			return str(rotator_count())
		"deg":
			return "%.2f deg/frame" % (int(v) / 1000.0)
		"deg_signed":
			return "%+.2f deg/frame" % (int(v) / 1000.0)
		"deg_pm":
			return "+/-%.1f deg/frame" % (int(v) / 1000.0)
		"percent":
			return "%d %%" % int(v)
	return str(v)


## Total number of rotators: the first (Dreher1), chain_length middle ones (Dreher2) and the
## last one (Dreher3). DIV: Howmuch_counts=0 still creates Dreher1 + Dreher3.
func rotator_count() -> int:
	return int(values[&"chain_length"]) + 2


func is_default() -> bool:
	return values == DEFAULTS


func reset_to_original() -> void:
	values = DEFAULTS.duplicate()
	Engine.physics_ticks_per_second = values[&"fps"]
	_save()
	changed.emit(&"")


func randomise() -> void:
	values[&"speed_mode"] = SpeedMode.COUNTED if randf() < 0.7 else SpeedMode.RANDOM
	values[&"chain_length"] = randi_range(2, 40)
	values[&"first_speed"] = randi_range(-24, 24) * 500
	values[&"speed_step"] = randi_range(-12, 12) * 250
	values[&"random_range"] = randi_range(2, 20) * 500
	values[&"size"] = randi_range(4, 16) * 5
	values[&"trails"] = Trails.ALL if randf() < 0.75 else Trails.LAST_ONLY
	values[&"trail_colour"] = randi_range(0, TrailColour.size() - 1)
	_save()
	changed.emit(&"")


## Rotation speed (thousandths of a degree per frame) of rotator `index` (0 = the first one).
func rotator_speed(index: int) -> int:
	match int(values[&"speed_mode"]):
		SpeedMode.RANDOM:
			# DIV: Rand(2500,-2500) for the first rotator, Rand(4500,-4500) for the others
			var limit: int = values[&"random_range"]
			if index == 0:
				limit = limit * 2500 / 4500
			return randi_range(-limit, limit)
		SpeedMode.TABLE:
			return table_speed(index)
	return int(values[&"first_speed"]) + index * int(values[&"speed_step"])


## DIV: Speeds[Speed_pointer] with Speed_pointer counting up per rotator. The table has only
## 13 entries, so from the 14th rotator on the original reads the globals stored after it.
## Those values are reproduced here (the original bug is part of the pattern).
func table_speed(index: int) -> int:
	if index < SPEED_TABLE.size():
		return SPEED_TABLE[index]
	match index:
		13: return int(values[&"chain_length"])  # Howmuch_counts
		14: return int(values[&"size"])          # Size_ins
		15: return 15                            # Speed_Pointer itself (it is 15 when read)
		16: return 15                            # Howmuch (the reading rotator is the 15th)
		19: return 1000                          # Schl, the map code returned by load_map
	return 0  # score, speed, and whatever lay behind the globals (assumed 0)


# ----------------------------------------------------------------- persistence

func _load() -> void:
	if not _persist:
		return
	var file := ConfigFile.new()
	if file.load(SAVE_PATH) != OK:
		return
	for key: StringName in DEFAULTS:
		var v: Variant = file.get_value("options", String(key), DEFAULTS[key])
		if typeof(v) == typeof(DEFAULTS[key]):
			values[key] = v


func _save() -> void:
	if not _persist:
		return
	var file := ConfigFile.new()
	for key: StringName in values:
		file.set_value("options", String(key), values[key])
	file.save(SAVE_PATH)


# ----------------------------------------------------------------- input map

func _register_input_actions() -> void:
	_add_keys(&"toggle_options", [KEY_TAB, KEY_O, KEY_F1])
	_add_keys(&"clear_trails", [KEY_C, KEY_BACKSPACE])
	_add_keys(&"restart", [KEY_R])
	_add_keys(&"pause", [KEY_SPACE, KEY_P])
	_add_keys(&"randomise", [KEY_N])
	_add_keys(&"original", [KEY_0, KEY_KP_0])
	_add_keys(&"toggle_text", [KEY_H])
	_add_keys(&"close", [KEY_ESCAPE])


func _add_keys(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key: int in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key as Key
		InputMap.action_add_event(action, event)
