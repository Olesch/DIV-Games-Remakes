class_name Defs
extends RefCounted
## Constants of Lommings (original: LOMMINGS.PRG by Oleg Yuschuk, DIV Game Studio).

## DIV: set_fps(24, 0). The game logic runs once per physics tick (project setting: 24 ticks/s),
## because the original is built from frame counters.
const FPS := 24

const FIELD_SIZE := Vector2i(640, 190)  # level graphics 900-950 and the playfield graphics 1/2
const PANEL_Y := 190                    # skill panel (graphic 20) occupies y 190..239
const SCROLL_STEP := 4                  # DIV: Levelxpos +-= 4 per frame
const SCROLL_MIN := -320                # DIV: Levelxpos in -320..0

## DIV: terrain test map_get_pixel(0,2,x,y)==113 -> "free" (palette index 113 = sky colour).
const AIR_COLOR := Color8(44, 24, 0)

const EXIT_RADIUS := 15                 # DIV: fget_dist(exit, lomming) < 15
const DEATH_FALL_HEIGHT := 80           # DIV: Fallen > 80 -> dead on landing
const DEATH_Y := 189                    # DIV: y >= 189 -> dead (fell out of the level)
const EXPLODE_TICKS := 117              # DIV: Explode counter 1..117, digits change every 24
const MIN_EMERGE := 4                   # DIV: lommingsemerge minimum (also set by the Backspace nuke)
const TURBO_EXTRA_STEPS := 4            # DIV: Speedup=4 -> 5 simulation steps per frame
const PICK_RADIUS := 8                  # DIV: shortestdist < 8
const LADDER_PIECES_MAX := 15           # DIV: Fallen used as "pieces built"; piece 16 is the last

## Mouse actions (DIV: Mouseaction 1..9; keys 1..9).
enum Skill { NONE, CLIMB, UMBRELLA, JUMP, EXPLODE, LADDER, STOPPER, DIG_FRONT, DIG_DIAGONAL, DIG_DOWN }

## DIV: AvailableLevels[] (1000 = end marker, "BYE!")
const LEVEL_ORDER: Array[int] = [900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 920, 950, 1000]
const END_LEVEL := 1000
const LEVEL_COUNT := 13                 # playable entries of LEVEL_ORDER (without the end marker)

## DIV: the level graphics store their parameters in the first pixels of row 0 (palette indices):
## [lemmings-1, emerge interval max, time/5 (s) (original multiplies by 5), to save (saved must be GREATER),
##  climb, umbrella, jump, explode, ladder, stopper, dig>, dig\, digV] and use control points
## 1 = entrance, 2 = exit. Extracted from assets/fpg/lommings/indices.bin while porting.
## "name" is the graphic's name in LOMMINGS.FPG (the only level names the original has), shown on the level select.
const LEVELS := {
	900: {"name": "Level1", "params": [25, 99, 60, 25, 26, 0, 0, 0, 0, 0, 0, 0, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(193, 105)},
	901: {"name": "Level2", "params": [25, 99, 60, 25, 0, 26, 0, 0, 0, 0, 0, 0, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(362, 103)},
	902: {"name": "Level3", "params": [25, 99, 60, 25, 0, 0, 52, 0, 0, 0, 0, 0, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(362, 103)},
	903: {"name": "Level4", "params": [25, 99, 60, 10, 0, 0, 0, 99, 0, 0, 0, 0, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(362, 103)},
	904: {"name": "Level5", "params": [25, 99, 60, 25, 0, 0, 0, 0, 99, 0, 0, 0, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(362, 103)},
	905: {"name": "Level6", "params": [25, 99, 60, 25, 0, 0, 0, 0, 0, 99, 0, 0, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(463, 155)},
	906: {"name": "Level7", "params": [25, 99, 60, 25, 0, 0, 0, 0, 0, 0, 99, 0, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(362, 103)},
	907: {"name": "Level8", "params": [25, 99, 60, 25, 0, 0, 0, 0, 0, 0, 0, 99, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(463, 155)},
	908: {"name": "Level9", "params": [25, 99, 60, 25, 0, 0, 0, 0, 0, 0, 0, 0, 99], "spawn": Vector2i(47, 29), "exit": Vector2i(463, 155)},
	909: {"name": "Level10", "params": [25, 99, 30, 25, 1, 0, 0, 0, 0, 0, 0, 0, 3], "spawn": Vector2i(47, 29), "exit": Vector2i(463, 155)},
	910: {"name": "Level11", "params": [9, 150, 15, 9, 10, 0, 10, 0, 0, 20, 0, 0, 0], "spawn": Vector2i(47, 29), "exit": Vector2i(356, 25)},
	920: {"name": "Level21", "params": [74, 99, 27, 74, 1, 1, 1, 0, 1, 5, 2, 1, 1], "spawn": Vector2i(47, 29), "exit": Vector2i(463, 155)},
	950: {"name": "Level51", "params": [9, 100, 26, 9, 10, 10, 20, 20, 1, 0, 0, 1, 1], "spawn": Vector2i(115, 29), "exit": Vector2i(595, 144)},
}
