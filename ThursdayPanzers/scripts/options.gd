extends Node
## Autoload "Options": the match values THURPANZ.PRG hard-codes in its main program, adjustable on
## the setup screen (new, owner's decision 2026-10-26). Defaults are exactly the original's; values
## live for the session only (every fresh start is the original match again).

## One entry per team value (index 1 = team 1 / green, 2 = team 2 / red; index 0 unused).
## DIV: Panzer(x,y,life,power,velo,player,team) - player tanks 300/10/40, computer tanks 200/5/30.
const SPECS := [
	{"key": &"tanks", "label": "TANKS", "min": 1, "max": 61, "step": 1, "default": [0, 22, 28]},
	{"key": &"player_life", "label": "PLAYER LIFE", "min": 25, "max": 3000, "step": 25, "default": [0, 300, 300]},
	{"key": &"player_power", "label": "PLAYER DAMAGE", "min": 1, "max": 100, "step": 1, "default": [0, 10, 10]},
	{"key": &"player_velo", "label": "PLAYER SPEED", "min": 5, "max": 100, "step": 5, "default": [0, 40, 40]},
	{"key": &"ai_life", "label": "COMPUTER LIFE", "min": 25, "max": 3000, "step": 25, "default": [0, 200, 200]},
	{"key": &"ai_power", "label": "COMPUTER DAMAGE", "min": 1, "max": 100, "step": 1, "default": [0, 5, 5]},
	{"key": &"ai_velo", "label": "COMPUTER SPEED", "min": 5, "max": 100, "step": 5, "default": [0, 30, 30]},
]

## DIV: FOR(x=0;x<=1600;x+=80) for team 1 (21 computer tanks), x+=60 for team 2 (27 computer tanks).
const ORIGINAL_ROW_STEP: Array[int] = [0, 80, 60]
const ROW_Y: Array[int] = [0, 300, 900]

## DIV (commented out): LOOP Panzer(rand(0,1600),rand(0,1200),75,5,25,0,2); ...team 1...; FRAME(2400); END
const REINFORCEMENT_LIFE := 75
const REINFORCEMENT_POWER := 5
const REINFORCEMENT_VELO := 25
const REINFORCEMENT_TICKS := 24  # FRAME(2400) = 24 frames at 24 fps = one second

var values: Dictionary = {}  # key -> Array[int] [unused, team 1, team 2]
var reinforcements := false


func _init() -> void:
	reset_to_original()


func get_value(key: StringName, team: int) -> int:
	return values[key][team]


func spec_of(key: StringName) -> Dictionary:
	for spec: Dictionary in SPECS:
		if spec["key"] == key:
			return spec
	return {}


## Move a team value one step up (direction 1) or down (-1), clamped to the option's range.
func step_value(key: StringName, team: int, direction: int) -> void:
	var spec := spec_of(key)
	var current: int = values[key][team]
	values[key][team] = clampi(current + direction * int(spec["step"]), spec["min"], spec["max"])


func reset_to_original() -> void:
	values.clear()
	for spec: Dictionary in SPECS:
		var defaults: Array = spec["default"]
		values[spec["key"]] = defaults.duplicate()
	reinforcements = false


func is_original() -> bool:
	if reinforcements:
		return false
	for spec: Dictionary in SPECS:
		if values[spec["key"]] != spec["default"]:
			return false
	return true


## X positions of the computer tanks' start row (before the rand(-10,10) jitter). At the original
## team size the original spacing is kept (team 2's row then ends at 1560, as in DIV); any other
## count is spread evenly over the map width.
func row_xs(team: int) -> Array[float]:
	var count := get_value(&"tanks", team) - 1  # minus the player's tank
	var xs: Array[float] = []
	var original_count := floori(Game.WORLD_SIZE.x / ORIGINAL_ROW_STEP[team]) + 1
	if count == original_count:
		for i in count:
			xs.append(float(i * ORIGINAL_ROW_STEP[team]))
	elif count == 1:
		xs.append(Game.WORLD_SIZE.x / 2.0)
	else:
		for i in count:
			xs.append(Game.WORLD_SIZE.x * i / (count - 1))
	return xs
