extends Node
## Autoload: global state (DIV GLOBAL Stat[], Level), constants, graphics cache and input map.

const FPS := 40                      # DIV set_fps(40,0); physics tick rate is set to this in project.godot
const LEVEL_CODE := 500              # DIV: Level+=500
const PLAYERS := 4
const PLAY_W := 640                  # playfield 640x440, HUD bar below (y >= 440)
const PLAY_H := 440
const GFX_DIR := "res://assets/fpg/gigamaze/"

# Level control points (see header comment of the original)
const POINT_PLAYER_FIRST := 1        # 1-4 players
const POINT_DIAMOND_FIRST := 5       # 5-10 diamond places
const POINT_DIAMOND_LAST := 10
const POINT_ITEM_FIRST := 11         # 11-55 items
const POINT_ITEM_LAST := 55

const START_LIFE := 100
const START_AMMO := 99
const DIAMOND_SCORE := 200

## Weapon number -> projectile data (DIV Patron(Art)): px per frame, damage, score for the shooter.
## Weapons 2..5 (red laser, stunner, nuke, health item) exist as pickups in the original but their
## shots were never written: they use up ammo and do nothing.
const SHOTS := {
	0: {"speed": 8, "damage": 5, "score": 10, "graph_h": 50, "graph_v": 50},
	1: {"speed": 7, "damage": 10, "score": 20, "graph_h": 51, "graph_v": 52},
}

## Item graphic -> [weapon, ammo] granted on pickup (DIV Item).  Rockets (59), shield (62) and
## teleporters (63/64) have no pickup code in the original.
const PICKUPS := {
	53: [1, 10],   # green laser
	56: [2, 5],    # red laser
	58: [3, 1],    # stunner
	60: [4, 3],    # nuke
	61: [5, 1],    # "Life+50" (gives weapon 5 in the original!)
}

var level: LevelData
var stats: Array[PlayerStats] = []
var _textures: Dictionary = {}


func _ready() -> void:
	level = LevelData.load_graphic(LEVEL_CODE)
	for i in PLAYERS:
		stats.append(PlayerStats.new())
	_setup_input()


func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [GFX_DIR, code])
	return _textures[code]


func reset_stats() -> void:
	for s in stats:
		s.life = START_LIFE
		s.ammo = START_AMMO
		s.weapon = 0
		s.score = 0


## Original: ship(0,_up,_down,_left,_right,_Control) ship(1,_2,_w,_q,_e,_1) ship(2,_9,_o,_i,_p,_8)
## ship(3,_h,_n,_b,_m,_g); physical keys (US positions).
func _setup_input() -> void:
	var p0_fire: Array = [KEY_SPACE] if OS.has_feature("web") else [KEY_CTRL]  # browsers eat Ctrl+W/T/N/1..9
	var keys := [
		[[KEY_UP, KEY_KP_8], [KEY_DOWN, KEY_KP_2], [KEY_LEFT, KEY_KP_4], [KEY_RIGHT, KEY_KP_6], p0_fire],
		[[KEY_2], [KEY_W], [KEY_Q], [KEY_E], [KEY_1]],
		[[KEY_9], [KEY_O], [KEY_I], [KEY_P], [KEY_8]],
		[[KEY_H], [KEY_N], [KEY_B], [KEY_M], [KEY_G]],
	]
	var names := ["up", "down", "left", "right", "fire"]
	for p in PLAYERS:
		for a in names.size():
			var action := StringName("p%d_%s" % [p, names[a]])
			InputMap.add_action(action)
			for code: Key in keys[p][a]:
				var ev := InputEventKey.new()
				ev.physical_keycode = code
				InputMap.action_add_event(action, ev)
