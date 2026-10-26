extends Node
## Global state (DIV GLOBAL section), game options, input map and shared references.

const FPS := 30                       # DIV set_fps(30,0); gameplay logic runs once per physics tick (30 Hz)
const WORLD_W := 80000                # 800 px in 1/100 px (resolution=100)
const WORLD_H := 60000

const PLAYER_TEXT := ["OFF", "ON", "PC Easy", "PC Normal", "PC Hard", "PC King"]
const PARTICLE_TEXT := ["None", "Normal", "Much"]
const LASER_TEXT := ["Laser", "Durable Laser", "Lasershot", "Machinelasershot", "Spreader", "Sniper", "GravitLaser"]
const LOAD_TEXT := ["None", "Slow", "Normal", "Fast", "Starwars"]
const PLAY_TEXT := ["Standart", "Simple", "Hold the Flag"]

## Per laser type: [energy needed (> this), energy cost, damage to an unshielded ship]
const LASER_STATS := [[15, 15, 50], [3, 3, 10], [10, 10, 60], [6, 6, 45], [3, 3, 30], [25, 25, 500], [10, 10, 90]]

signal points_changed

# Menu options (DIV: shipamode.., maxenergy, gravity, Asteroids, Particelamount, Lasertype, Loadtype, Playtype)
var ship_mode: Array[int] = [1, 1, 0, 0]
var max_energy := 1000
var gravity := 8000
var asteroids := 0
var particles := 1
var laser_type := 0
var load_type := 2
var play_type := 0

var points: Array[int] = [0, 0, 0, 0]

# Live references (set by the world scene)
var ships: Array = [null, null, null, null]   # alive Ship per player (DIV shipX with shipXtot == 0)
var planet: Planet
var flag: Flag
var follow: Ship                              # flag carrier (DIV Follow)
var effects: Effects
var entities: Node2D


func _ready() -> void:
	_setup_input()


func add_points(player: int, amount: int) -> void:
	points[player] += amount
	points_changed.emit()


func reset_points() -> void:
	points = [0, 0, 0, 0]
	points_changed.emit()


func alive_ships() -> Array[Ship]:
	var result: Array[Ship] = []
	for s in ships:
		if is_instance_valid(s):
			result.append(s)
	return result


func _setup_input() -> void:
	var web := OS.has_feature("web")
	# Ship keys (DIV scan codes in comments). In the web build Ctrl is not used because
	# Ctrl+W (player 2 thrust while player 1 fires) would close the browser tab.
	_bind(&"p0_thrust", [KEY_UP, KEY_KP_8])                 # _up
	_bind(&"p0_right", [KEY_RIGHT, KEY_KP_6])               # _right
	_bind(&"p0_left", [KEY_LEFT, KEY_KP_4])                 # _left
	var fire0: Array = [[KEY_SHIFT, KEY_LOCATION_RIGHT]]    # alternative: right shift
	if not web:
		fire0.append(KEY_CTRL)                              # _control
	_bind(&"p0_fire", fire0)
	_bind(&"p1_thrust", [KEY_W])                            # _w
	_bind(&"p1_right", [KEY_D])                             # _d
	_bind(&"p1_left", [KEY_A])                              # _a
	_bind(&"p1_fire", [[KEY_SHIFT, KEY_LOCATION_LEFT]])     # _l_shift
	_bind(&"p2_thrust", [KEY_KP_5])                         # _c_center
	_bind(&"p2_right", [KEY_KP_3])                          # _c_pgdn
	_bind(&"p2_left", [KEY_KP_1])                           # _c_end
	_bind(&"p2_fire", [KEY_KP_0])                           # _c_ins
	_bind(&"p3_thrust", [KEY_I])                            # _i
	_bind(&"p3_right", [KEY_L])                             # _l
	_bind(&"p3_left", [KEY_J])                              # _j
	_bind(&"p3_fire", [KEY_SPACE])                          # _space
	# Menu
	_bind(&"menu_up", [KEY_UP, KEY_KP_8])
	_bind(&"menu_down", [KEY_DOWN, KEY_KP_2])
	_bind(&"menu_left", [KEY_LEFT, KEY_KP_4])
	_bind(&"menu_right", [KEY_RIGHT, KEY_KP_6])
	_bind(&"menu_start", [KEY_ENTER, KEY_KP_ENTER])
	_bind(&"back", [KEY_BACKSPACE, KEY_ESCAPE])


func _bind(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		if k is Array:
			ev.physical_keycode = k[0]
			ev.location = k[1]
		else:
			ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
