extends Node
## Autoload "Game": global state of SIEGE (the GLOBAL block of the PRG) and keyboard input.

## Key actions. Original DIV keys (scan codes, see PRG: Cursor(player, up, down, left, right, click, activ, new)):
##   player 0: _up _down _left _right  _o _p _l   -> arrows (or keypad), O, P, L
##   player 1: _w _s _a _d             _1 _2 _q   -> W, S, A, D, 1, 2, Q
const ACTIONS := {
	&"p0_up": [KEY_UP, KEY_KP_8], &"p0_down": [KEY_DOWN, KEY_KP_2],
	&"p0_left": [KEY_LEFT, KEY_KP_4], &"p0_right": [KEY_RIGHT, KEY_KP_6],
	&"p0_click": [KEY_O], &"p0_build": [KEY_P], &"p0_new": [KEY_L],
	&"p1_up": [KEY_W], &"p1_down": [KEY_S], &"p1_left": [KEY_A], &"p1_right": [KEY_D],
	&"p1_click": [KEY_1], &"p1_build": [KEY_2], &"p1_new": [KEY_Q],
	&"confirm": [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE],
}

const FIELD_W := 6   # DIV field[p].x[0..5]
const FIELD_H := 5   # DIV field[p].y[0..4]

## Game frames per second: 18 like DIV's default; only the debug autotest changes it (to run faster).
var fps := Defs.FPS

signal match_started

## DIV: tech[1]=6,6  (tech level of both players; never changes in the original)
var tech: Array[int] = [6, 6]
## Who plays each side (new setup page, owner's decision 2026-10-26): false = human at the keyboard,
## true = the PRG's computer opponent KI(player). Default: two humans, like the original's main code.
var computer: Array[bool] = [false, false]
## DIV: life[1]=100,100  (castle life of both players)
var life: Array[int] = [100, 100]
## DIV: field[player].x[x].y[y] = 1 wood, 2 metal, 3 fire, 4 magic. Indexed field[player][x][y].
var field: Array = []


func _ready() -> void:
	for action: StringName in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for code: int in ACTIONS[action]:
				var ev := InputEventKey.new()
				ev.physical_keycode = code as Key
				InputMap.action_add_event(action, ev)
	Engine.physics_ticks_per_second = Defs.FPS


func random_tile() -> int:
	return randi_range(1, 4)


func new_match() -> void:
	life = [100, 100]
	tech = [6, 6]
	field = []
	for p in 2:
		var columns: Array = []
		for x in FIELD_W:
			var col: Array[int] = []
			for y in FIELD_H:
				col.append(random_tile())
			columns.append(col)
		field.append(columns)
	match_started.emit()
