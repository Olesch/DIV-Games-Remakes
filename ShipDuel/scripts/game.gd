extends Node
## Autoload "Game": the GLOBAL section of the DIV program (the settings edited on the first screen)
## plus the input map. Entities read the settings from here while a match runs.

signal settings_changed

# --- DIV GLOBAL values, English names (original name in the comment) ---
var max_hits: int = 5               # MaxHits: hits a ship survives (it dies when lives < 0)
var max_turn_speed: int = 17000     # Maxspeed: maximum turn rate, 1/1000 degree per frame
var turn_accel: int = 600           # Beschleunigung: turn rate gained per frame while a key is held
var auto_brake: int = 75            # AutoBremse: turn rate lost per frame
var shot_explosion_size: int = 40   # Kugelexplode: explosion size of a shot, percent
var ship_explosion_size: int = 200  # Playerexplode: explosion size of a ship, percent
var shot_life: int = 8              # shotlife: wall-contact budget of a shot (2 per frame in contact)
var shot_delay: int = 10            # ShotStop: frames between two shots
var fast_fire: int = 0              # Fastfire
var own_shots_hit_ship: int = 1     # Eigenkilla: 0 = a ship is immune to (and swallows) its own shots
var shots_hit_own_shots: int = 1    # Eigenkillb: 0 = shots of one ship do not destroy each other
var margin_h: int = 150             # Playx: distance of the ships from the left/right edge
var margin_v: int = 100             # Playy: distance of the ships from the top/bottom edge
var shield_mode: int = 1            # shieldmod: 1 = every ship has a shield

## DIV: Pinselgr - how much one left/right press changes the selected setting.
var brush: int = 1:
	set(value):
		brush = value
		settings_changed.emit()


func _ready() -> void:
	_register_input_actions()
	# debug: `-- --set=shield_mode=0` overrides a setting from the command line (used by the autotest)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--set="):
			var pair := arg.substr("--set=".length()).split("=")
			if pair.size() == 2 and pair[0] in self:
				set(pair[0], int(pair[1]))


## Add `amount` to one of the settings (the original lets every value run freely, also below zero).
func adjust(key: StringName, amount: int) -> void:
	set(key, int(get(key)) + amount)
	settings_changed.emit()


func _register_input_actions() -> void:
	# settings screen (DIV: Key(_up/_down/_left/_right), Q W A S Z X E R T Y U I)
	_add_keys(&"set_up", [KEY_UP, KEY_KP_8])
	_add_keys(&"set_down", [KEY_DOWN, KEY_KP_2])
	_add_keys(&"set_dec", [KEY_LEFT, KEY_KP_4])
	_add_keys(&"set_inc", [KEY_RIGHT, KEY_KP_6])
	_add_keys(&"brush_minus_1", [KEY_Q])
	_add_keys(&"brush_plus_1", [KEY_W])
	_add_keys(&"brush_minus_10", [KEY_A])
	_add_keys(&"brush_plus_10", [KEY_S])
	_add_keys(&"brush_minus_100", [KEY_Z])
	_add_keys(&"brush_plus_100", [KEY_X])
	_add_keys(&"brush_set_1", [KEY_E])
	_add_keys(&"brush_set_5", [KEY_R])
	_add_keys(&"brush_set_10", [KEY_T])
	_add_keys(&"brush_set_50", [KEY_Y])
	_add_keys(&"brush_set_100", [KEY_U])
	_add_keys(&"brush_set_1000", [KEY_I])
	_add_keys(&"start_game", [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER, KEY_SPACE])
	_add_keys(&"back_to_settings", [KEY_ESCAPE])  # new: DIV could only quit with Ctrl+Esc
	_add_keys(&"confirm", [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE])

	# Players (DIV: player(x, y, graph, angle, left, right, shoot, manashoot)).
	# DIV scan codes are shared by the arrow keys / keypad, and _end = _c_end (79), so End / KP1 was
	# both player 1's explosion-shot key and player 3's turn-left key. Owner's decision (2026-10-26):
	# player 1's explosion shot moved to Down (+ KP2, its keypad twin), unused during a match.
	_add_keys(&"p1_left", [KEY_LEFT, KEY_KP_4])
	_add_keys(&"p1_right", [KEY_RIGHT, KEY_KP_6])
	_add_keys(&"p1_shoot", [KEY_UP, KEY_KP_8])
	_add_keys(&"p1_mana", [KEY_DOWN, KEY_KP_2])  # DIV: _end (clashed with player 3)
	_add_keys(&"p2_left", [KEY_A])
	_add_keys(&"p2_right", [KEY_D])
	_add_keys(&"p2_shoot", [KEY_W])
	_add_keys(&"p2_mana", [KEY_Q])
	_add_keys(&"p3_left", [KEY_END, KEY_KP_1])        # _c_end
	_add_keys(&"p3_right", [KEY_PAGEDOWN, KEY_KP_3])  # _c_pgdn
	_add_keys(&"p3_shoot", [KEY_KP_5])                # _c_center
	_add_keys(&"p3_mana", [KEY_DELETE, KEY_KP_PERIOD])  # _del
	_add_keys(&"p4_left", [KEY_J])
	_add_keys(&"p4_right", [KEY_L])
	_add_keys(&"p4_shoot", [KEY_I])
	_add_keys(&"p4_mana", [KEY_U])


func _add_keys(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key: int in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key as Key
		InputMap.action_add_event(action, event)
