extends Node
## Autoload "Game": the GLOBAL section of SIEDLER.PRG - job quotas, collection points, the
## building mode and the house records - plus the input actions. The colony simulation, the
## cursor and the menu bar read and change this state.

signal worker_max_changed

## Grid size of the logic maps (DIV graphics 9, 10, 11, 13 are 128x96 pixels, one pixel per cell).
const MAP_W := 128
const MAP_H := 96
## Size of one map cell in world pixels (the world graphics 2 and 8 are 1280x960).
const CELL := 10
const WORLD_SIZE := Vector2(MAP_W * CELL, MAP_H * CELL)
const NO_POINT := Vector2i(-1, -1)

## House size code of the only building type, "Haus1 3x3" (DIV: Hausgroesse=0303).
const HOUSE_3X3 := 303

## Job quotas (DIV: HolzArbeiterMax / LehmArbeiterMax). Can go negative, like the original.
var wood_workers_max: int = 0:
	set(value):
		wood_workers_max = value
		worker_max_changed.emit()
var clay_workers_max: int = 0:
	set(value):
		clay_workers_max = value
		worker_max_changed.emit()
## Settlers currently holding the job (DIV: HolzArbeiter / LehmArbeiter).
var wood_workers: int = 0
var clay_workers: int = 0

## Collection points in map cells, (-1,-1) = not set (DIV: HolzSPX/Y, LehmSPX/Y).
var wood_point := NO_POINT
var clay_point := NO_POINT
## "The next left click sets this point" (DIV: Holzsetzen / Lehmsetzen).
var wood_point_pending := false
var clay_point_pending := false

## DIV: STOP. Set when a worker quits because its collection point is missing; the original
## never clears it again, which disables "too many workers -> one quits" for good (kept).
var stop_latch := false

## Building mode with the house ghost under the cursor (DIV: BeimBau, Hausgroesse).
var building := false
var house_size := 0

## Placed building sites (DIV: STRUCT Haus[50] + Hauszaehler). Recorded but never used by the
## original - houses are never built on them.
var houses: Array[HouseSite] = []


class HouseSite:
	var cell := Vector2i.ZERO   # DIV: X_coor / Y_coor (top-left cell)
	var size := Vector2i(3, 3)  # DIV: Width / Height
	var need_wood := 6          # DIV: Need_Wood
	var need_loam := 0          # DIV: Need_Loam
	var building_type := 1      # DIV: Building_Type
	var specific := 0           # DIV: Specific_Var


func _ready() -> void:
	_register_actions()


func add_house_site(top_left: Vector2i) -> void:
	var site := HouseSite.new()
	site.cell = top_left
	houses.append(site)


## Keys of the original (DIV scan codes = physical key positions).
func _register_actions() -> void:
	var keys := {
		&"menu_open": [KEY_M],          # (M)enu
		&"menu_points": [KEY_S],        # (S)ammelpunkte setzen
		&"menu_build": [KEY_G],         # (G)ebaeude bauen
		&"menu_workers": [KEY_R],       # A(r)beiterzahlen setzen
		&"menu_abort": [KEY_A],         # (A)bbruch
		&"menu_h": [KEY_H],             # (H)olz / (H)aus / (H)olzfaeller
		&"menu_l": [KEY_L],             # (L)ehm / (L)ehmsammler
		&"count_up": [KEY_EQUAL, KEY_KP_ADD],         # DIV _plus (scan 13)
		&"count_down": [KEY_MINUS, KEY_KP_SUBTRACT],  # DIV _minus (scan 12)
		&"release_mouse": [KEY_ESCAPE],
	}
	for action: StringName in keys:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for code: Key in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = code
			InputMap.action_add_event(action, ev)
	if not InputMap.has_action(&"place"):
		InputMap.add_action(&"place")
		var mb := InputEventMouseButton.new()
		mb.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event(&"place", mb)
