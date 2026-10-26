extends Node
## Autoload "Game": global state of the original (GLOBAL section) and input map setup.

signal stats_changed

const SELECT_SCENE := "res://scenes/level_select.tscn"
const LEVEL_SCENE := "res://scenes/main.tscn"

var level_counter := 0                  # DIV: Levelcounter
var select_index := 0                   # level select: highlighted entry of Defs.LEVEL_ORDER (new; 0 = level 900)
var selected_skill := Defs.Skill.NONE   # DIV: MouseAction
var skill_counts: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  # DIV: ClimbNr .. DigDownNr, index = Skill
var time_left := 0                      # DIV: Time (seconds)
var lemming_total := 0                  # DIV: LommingsNumber (= number of lemmings - 1, original quirk)
var to_save := 0                        # DIV: ToSave (need strictly MORE than this)
var saved := 0                          # DIV: Lommingssaved
var emerge_interval := 0                # DIV: Lommingsemerge
var emerge_max := 0                     # DIV: Lommingsemergemax
var turbo_extra := 0                    # DIV: Speedup (0 or 4)
var paused := false                     # DIV: Pause


func _ready() -> void:
	_setup_input()


func _setup_input() -> void:
	for i in 9:
		_add_action("skill_%d" % (i + 1), [_key(KEY_1 + i), _key(KEY_KP_1 + i)])
	_add_action("scroll_left", [_key(KEY_LEFT)])
	_add_action("scroll_right", [_key(KEY_RIGHT)])
	_add_action("emerge_slower", [_key(KEY_EQUAL), _key(KEY_KP_ADD)])        # DIV: key(_plus)  -> interval +1
	_add_action("emerge_faster", [_key(KEY_MINUS), _key(KEY_KP_SUBTRACT)])   # DIV: key(_minus) -> interval -1
	_add_action("nuke", [_key(KEY_BACKSPACE)])
	_add_action("turbo", [_key(KEY_O)])
	_add_action("cheat_g", [_key(KEY_G)])  # with O held: win the level
	_add_action("pause", [_key(KEY_P)])
	_add_action("confirm", [_key(KEY_ENTER), _key(KEY_KP_ENTER), _key(KEY_SPACE)])
	_add_action("back", [_key(KEY_ESCAPE)])  # new: back to the level select
	var left := InputEventMouseButton.new()
	left.button_index = MOUSE_BUTTON_LEFT
	_add_action("click_left", [left])
	var right := InputEventMouseButton.new()
	right.button_index = MOUSE_BUTTON_RIGHT
	_add_action("click_right", [right])


## Starts a fresh game at entry `index` of Defs.LEVEL_ORDER (new level select; the original always began with
## Levelcounter = 0). Progression continues from there through AvailableLevels like the original.
func new_game(index: int) -> void:
	select_index = index
	level_counter = index
	selected_skill = Defs.Skill.NONE
	turbo_extra = 0
	paused = false
	get_tree().change_scene_to_file(LEVEL_SCENE)


func show_level_select() -> void:
	if level_counter < Defs.LEVEL_COUNT:
		select_index = level_counter  # highlight the level that was being played (after the end: the chosen start)
	get_tree().change_scene_to_file(SELECT_SCENE)


func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	return e


func _add_action(action: StringName, events: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for e: InputEvent in events:
		InputMap.action_add_event(action, e)
