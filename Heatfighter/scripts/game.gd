extends Node
## Autoload "Game": match setup chosen on the title screen, the shared hit-pause counter and the
## input actions of both players.

signal hit_pause_changed

## Player setup (index 0 = player 1). DIV: Fighter(Spielernr, Charakter, SpielerArt) in the main code
## (player 1 human, player 2 computer, both "Chain").
var is_cpu: Array[bool] = [false, true]
var characters: Array[int] = [Defs.Character.CHAIN, Defs.Character.CHAIN]

## DIV global "Dontmove": while > 0 every fighter freezes ("nano pause" to feel a hit). The arena
## counts it down once per tick, after the fighters have acted (DIV: DontMovePlus, priority -100).
var hit_pause: int = 0
const HIT_DONT_WAIT := 0  # DIV: HitDontWait - freeze length after a normal hit (0 = none)


func _ready() -> void:
	_setup_input()


func _setup_input() -> void:
	# Original keys (scan codes, German keyboard):
	#   player 1: X left, V right, D up, C down, 1 = light punch, 2 = strong punch
	#   player 2: cursor keys, 9 = light punch, 0 = strong punch
	var map := {
		&"p1_left": KEY_X, &"p1_right": KEY_V, &"p1_up": KEY_D, &"p1_down": KEY_C,
		&"p1_light": KEY_1, &"p1_heavy": KEY_2,
		&"p2_left": KEY_LEFT, &"p2_right": KEY_RIGHT, &"p2_up": KEY_UP, &"p2_down": KEY_DOWN,
		&"p2_light": KEY_9, &"p2_heavy": KEY_0,
	}
	for action: StringName in map:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = map[action]
		InputMap.action_add_event(action, event)
	# Player 2's punches also on the keypad / ,. so a laptop without a number row still works.
	for pair: Array in [[&"p2_light", KEY_COMMA], [&"p2_heavy", KEY_PERIOD]]:
		var alt := InputEventKey.new()
		alt.physical_keycode = pair[1]
		InputMap.action_add_event(pair[0], alt)
