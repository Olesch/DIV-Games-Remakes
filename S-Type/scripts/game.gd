extends Node
## Autoload "Game": the GLOBAL section of the DIV program (settings from the start menu, the
## Player[] table, Psh) plus input registration and scene changes.

## DIV set_fps(40,0): all per-frame values of the original are per physics tick here
## (project setting physics/common/physics_ticks_per_second = 40).
const FPS := 40.0
const SCREEN := Vector2(800, 600)

# --- start menu settings (DIV: Playersnummer, dealedlifes, Speceffects, Joystick4, Passivloose)
var player_count: int = 1       # Spielerzahl 1-4
var shared_lives: int = 0       # Gemeinsame Leben 0=nein 1=ja
var graphics_level: int = 0     # Graphikstufe (displayed, never used by the original)
var joystick4: int = 0          # Spieler 4 Joystick (displayed, never used by the original)
var passive_loss: int = 1       # Passive Waffen beim Tod weg? (DIV: Passivloose)

## Players still alive minus one (DIV: Psh = "Playersstillhere"; -1 = nobody).
var psh: int = -1
var players: Array[PlayerState] = []
var world: Node2D = null        # the running World scene (entities are added to world.entities)
var autotest: bool = false
var ticks: int = 0  # physics ticks since start (DIV frames)

## Keys per player: left, right, up, down, fire, buy, weapon switch (DIV: Ship(nummer,links,rechts,
## oben,unten,Schuss,Kauf,Waffewechsel); physical keys, so positions match a German keyboard).
const PLAYER_KEYS := [
	[KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_CTRL, KEY_SHIFT, KEY_ENTER],  # _left _right _up _down _Control _r_shift _enter
	[KEY_Z, KEY_C, KEY_S, KEY_X, KEY_A, KEY_W, KEY_Q],                         # _z _c _s _x _a _w _q
	[KEY_J, KEY_L, KEY_I, KEY_K, KEY_H, KEY_U, KEY_Y],                         # _j _l _i _k _h _u _y
	[KEY_V, KEY_N, KEY_G, KEY_B, KEY_F, KEY_T, KEY_R],                         # _v _n _g _b _f _t _r
]
const ACTION_NAMES := ["left", "right", "up", "down", "fire", "buy", "weapon"]


func _ready() -> void:
	autotest = "--autotest" in OS.get_cmdline_user_args()
	_register_input_actions()
	new_game()


func new_game() -> void:
	psh = -1
	players.clear()
	for i in 4:
		players.append(PlayerState.new())


func _register_input_actions() -> void:
	for p in 4:
		for k in ACTION_NAMES.size():
			var action := StringName("p%d_%s" % [p + 1, ACTION_NAMES[k]])
			InputMap.add_action(action)
			var key: int = PLAYER_KEYS[p][k]
			# Browsers never hand Ctrl+W/T/N to the page (they close the tab or open a new one),
			# and players 2 and 4 use those letters, so on the web player 1 fires with Space.
			if p == 0 and k == 4 and OS.has_feature("web"):
				key = KEY_SPACE
			var ev := InputEventKey.new()
			ev.physical_keycode = key as Key
			if p == 0 and k == 5:
				ev.location = KEY_LOCATION_RIGHT  # DIV _r_shift
			InputMap.action_add_event(action, ev)
			if p == 0:
				# the arrow keys and the keypad share DIV scan codes
				var kp := {0: KEY_KP_4, 1: KEY_KP_6, 2: KEY_KP_8, 3: KEY_KP_2, 6: KEY_KP_ENTER}
				if kp.has(k):
					var ev2 := InputEventKey.new()
					ev2.physical_keycode = kp[k] as Key
					InputMap.action_add_event(action, ev2)
	# the original's cheats: O maxes every ship, A+L+E+X sends two extra snakes (see World)
	var cheats := {&"cheat_max": KEY_O, &"cheat_a": KEY_A, &"cheat_l": KEY_L, &"cheat_e": KEY_E, &"cheat_x": KEY_X}
	for action: StringName in cheats:
		InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = cheats[action] as Key
		InputMap.action_add_event(action, ev)
	# player 1 may pick a weapon directly with the keys 1-4 (DIV key(_1).._4)
	for n in 4:
		var action := StringName("p1_select_%d" % (n + 1))
		InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.physical_keycode = (KEY_1 + n) as Key
		InputMap.action_add_event(action, ev)


## DIV: searchplayer=rand(0,Playersnummer); re-rolled while that player is gone (lives==-1).
func pick_target() -> int:
	var last := player_count - 1
	var i := randi_range(0, last)
	var guard := 0
	while players[i].lives == -1 and psh != -1 and guard < 50:
		i = randi_range(0, last)
		guard += 1
	return i


## Ship node of player `i` if it still exists.
func ship_of(i: int) -> Ship:
	var s := players[i].ship
	if s != null and is_instance_valid(s) and s.is_inside_tree():
		return s
	return null


func add_entity(node: Node) -> void:
	world.entities.add_child(node)
	# _ready() of most entities sets rotation/scale (and children) after entering the tree: show that
	# at once instead of interpolating from the scene defaults during the first tick
	node.reset_physics_interpolation()


func start_game() -> void:
	new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func go_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _physics_process(_delta: float) -> void:
	ticks += 1
