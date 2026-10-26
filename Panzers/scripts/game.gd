extends Node
## Autoload "Game": the input map (DIV key codes -> physical keys), screen constants and the
## settings of the options screen. The DIV program has no global state at all (no score, no
## win/lose); hits, life, the round end and the options are new (owner's decision 2026-10-26).

const SCREEN_SIZE := Vector2(1024, 768)  # DIV: set_mode(m1024x768)
const FPS := 24.0                        # DIV: set_fps(24,0)

const FONT_PATH := "res://assets/fnt/system/font_bmfont.fnt"
const FONT_SCALE := 2                    # DIV system font is 6x8; drawn at 2x on the 1024x768 screen

## Player 1 (DIV: _j _l _k _u _o _i), player 2 (DIV: _a _d _s _q _e _w).
const KEYS := {
	&"p1_left": KEY_J, &"p1_right": KEY_L, &"p1_forward": KEY_K,
	&"p1_turret_left": KEY_U, &"p1_turret_right": KEY_O, &"p1_fire": KEY_I,
	&"p2_left": KEY_A, &"p2_right": KEY_D, &"p2_forward": KEY_S,
	&"p2_turret_left": KEY_Q, &"p2_turret_right": KEY_E, &"p2_fire": KEY_W,
}

## Choices of the "Life" option: hits a tank survives; 0 = off (sandbox, the original: shells hurt nothing).
const LIFE_CHOICES: Array[int] = [0, 1, 5, 10, 20, 30, 50, 100]
## One held fire key = 24 shells/s, so 30 hits = 1.25 s of fire that stays on target: a grazing
## burst does not kill, a sustained one does.
const DEFAULT_LIFE := 30

## Hits a tank takes before it is destroyed; 0 = sandbox (no hits, no round end).
var life: int = DEFAULT_LIFE
## DIV Graszeichner(1)/(2): tanks painted with the grass colours (the original look).
var camouflage: bool = false


func _ready() -> void:
	for action: StringName in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = KEYS[action] as Key
		InputMap.action_add_event(action, event)


func is_sandbox() -> bool:
	return life <= 0


## Theme with the converted DIV system font at an integer scale.
func make_theme() -> Theme:
	var font := load(FONT_PATH) as FontFile
	font.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	var theme := Theme.new()
	theme.default_font = font
	theme.default_font_size = 8 * FONT_SCALE
	return theme


## Quit the desktop game; in the web build quitting freezes the page, so do nothing there.
func quit_game() -> void:
	if not OS.has_feature("web"):
		get_tree().quit()
