extends Node
## Global state (DIV GLOBAL section): score, topscore, worm length, apple counter.
## Also owns the input actions, the saved topscore and the wall lookup (DIV get_pixel on the background).

signal score_changed(value: int)
signal topscore_changed(value: int)

const FPS := 20                       # DIV: set_fps(Frames,0); also the physics tick rate (project.godot)
const STEP := 8                       # DIV: ix/iy = +-8 pixels per frame
const START_CELL := Vector2i(8, 96)   # DIV: worm_head(8,96,8,0)
const START_LENGTH := 8               # DIV: worm_length=8
const MAX_SEGMENTS := 129             # DIV: worm_segment chain n=128..0
const POINTS_PER_APPLE := 20          # DIV: score+=Frames
const BACKGROUND_POS := Vector2i(160, 140)  # put_screen centres the 320x200 graphic on the 640x480 screen
## The original (set_mode 640x480 but a 320x200 background) plays on screen coordinates, so the worm
## starts left of the frame and most of the field is black. true (the default here) shifts the whole play field
## into the frame so the game is playable; false reproduces the original layout.
const FIT_TO_FRAME := true
const SAVE_PATH := "user://snake.cfg"

var score: int = 0
var topscore: int = 0
var worm_length: int = START_LENGTH
var apples: int = 0
## Autotests switch this off so no file is left in user://.
var persist: bool = true

var _wall_image: Image


func _ready() -> void:
	_wall_image = (load("res://assets/fpg/tutor4/1.png") as Texture2D).get_image()
	_setup_input()
	if "--autotest" in OS.get_cmdline_user_args():
		persist = false
	_load_topscore()


## Offset of the play-field coordinates (the DIV x,y) on the screen.
func field_origin() -> Vector2i:
	return BACKGROUND_POS if FIT_TO_FRAME else Vector2i.ZERO


## DIV: get_pixel(x,y)!=0 on the background screen (only the frame graphic is drawn there).
func is_wall(cell: Vector2i) -> bool:
	var p := cell + field_origin() - BACKGROUND_POS
	if p.x < 0 or p.y < 0 or p.x >= _wall_image.get_width() or p.y >= _wall_image.get_height():
		return false
	return _wall_image.get_pixelv(p).a > 0.0


func eat_apple() -> void:
	apples -= 1
	worm_length += 1
	score += POINTS_PER_APPLE
	score_changed.emit(score)


## The worm died: keep the best score, start over.
func reset_round() -> void:
	if score > topscore:
		topscore = score
		topscore_changed.emit(topscore)
		_save_topscore()
	score = 0
	worm_length = START_LENGTH
	score_changed.emit(score)


func _load_topscore() -> void:
	if not persist:
		return
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		topscore = int(cfg.get_value("snake", "topscore", 0))
		topscore_changed.emit(topscore)


func _save_topscore() -> void:
	if not persist:
		return
	var cfg := ConfigFile.new()
	cfg.set_value("snake", "topscore", topscore)
	cfg.save(SAVE_PATH)


## Original keys (physical positions): cursor keys + the diagonals E Q Z C.
func _setup_input() -> void:
	var keys := {
		&"move_right": [KEY_RIGHT, KEY_KP_6],
		&"move_left": [KEY_LEFT, KEY_KP_4],
		&"move_down": [KEY_DOWN, KEY_KP_2],
		&"move_up": [KEY_UP, KEY_KP_8],
		&"move_up_right": [KEY_E, KEY_KP_9],     # DIV _e
		&"move_up_left": [KEY_Q, KEY_KP_7],      # DIV _q
		&"move_down_left": [KEY_Z, KEY_KP_1],    # DIV _z
		&"move_down_right": [KEY_C, KEY_KP_3],   # DIV _c
	}
	for action: StringName in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code: int in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = code as Key
			InputMap.action_add_event(action, ev)
