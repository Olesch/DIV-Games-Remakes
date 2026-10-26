extends Node
## Autoload "Game": level hardness map, bunny pixel mask and the InputMap actions.

const TERRAIN_PLATFORM := 22    # top edge of a block: bunnies land on it (unless rising fast)
const TERRAIN_CEILING := 41     # bottom edge of a block: bunnies bounce off it
const TERRAIN_WALL_LEFT := 54   # left edge of a block (hit while moving right)
const TERRAIN_WALL_RIGHT := 73  # right edge of a block (hit while moving left)

const BUNNY_TEXTURE := preload("res://assets/fpg/bunyjump/2.png")
const BUNNY_CP0 := Vector2i(15, 31)  # control point 0 of graphic 2 (meta.json): the feet
const MAX_EXTRA_BUNNIES := 50  # options screen limit (the commented-out original loop made 11)

## Extra computer bunnies chosen on the options screen; 0 = the original game (not saved to disk).
var extra_bunnies: int = 0

var terrain: IndexMap
var _bunny_mask: Image


func _ready() -> void:
	terrain = load("res://assets/terrain.res") as IndexMap
	terrain.unpack()
	_bunny_mask = BUNNY_TEXTURE.get_image()
	_setup_input()


## DIV map_get_pixel(0, 1, x, y)
func terrain_at(x: int, y: int) -> int:
	return terrain.index_at(x, y)


## DIV collision(TYPE Bunny): pixel-exact overlap of two bunny graphics placed at control points a, b.
func bunnies_overlap(a: Vector2i, b: Vector2i) -> bool:
	var size := _bunny_mask.get_size()
	var ta := a - BUNNY_CP0
	var tb := b - BUNNY_CP0
	var x0 := maxi(ta.x, tb.x)
	var x1 := mini(ta.x, tb.x) + size.x
	var y0 := maxi(ta.y, tb.y)
	var y1 := mini(ta.y, tb.y) + size.y
	for py in range(y0, y1):
		for px in range(x0, x1):
			if _bunny_mask.get_pixel(px - ta.x, py - ta.y).a > 0.0 \
					and _bunny_mask.get_pixel(px - tb.x, py - tb.y).a > 0.0:
				return true
	return false


func _setup_input() -> void:
	# Original: bunny 1 on _up,_down,_left,_right, bunny 2 on _w,_s,_a,_d.
	# DIV scan codes are shared with the keypad, so numpad 8/2/4/6 also work for player 1.
	var keys := {
		"p1_up": [KEY_UP, KEY_KP_8], "p1_down": [KEY_DOWN, KEY_KP_2],
		"p1_left": [KEY_LEFT, KEY_KP_4], "p1_right": [KEY_RIGHT, KEY_KP_6],
		"p2_up": [KEY_W], "p2_down": [KEY_S], "p2_left": [KEY_A], "p2_right": [KEY_D],
	}
	for action: String in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code: Key in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = code
			InputMap.action_add_event(action, ev)
