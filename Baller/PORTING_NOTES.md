# Baller - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/BALLER.PRG` (Oleg Yuschuk), 640x480, `set_fps(40)`, `resolution=100`.
Run: open the folder in Godot 4.7, main scene `scenes/menu.tscn`.
Web slug: `baller` (export preset in `export_presets.cfg`).

## Controls
- Menu (new): Up/Down choose a level, Enter starts.
- Game: arrow keys (or keypad 8/2/4/6) steer the small guide ball (they change its *velocity*, there is no
  braking, counter-steer). The big ball follows the guide like on a rubber band. Touch the blue
  "win" pixels (colour 41) to win, red "death" pixels (22) to lose.
- R: pull the guide ball back onto the big ball (costs +24 frames, then a 100-frame cooldown).
- Esc: back to the level list (new). Enter after the level ended: retry (new). Ctrl is not used (no browser shortcut clash).

## How the DIV processes map to Godot
| DIV | Godot |
|---|---|
| main code (tuning from level pixels, `Time`, texts) | `scenes/game.tscn` + `scripts/world.gd` (`World`), HUD = `CanvasLayer` with `PixelLabel`s (system font) |
| `SmallBall` (+ `scroll.camera=id`) | `scenes/guide_ball.tscn` / `guide_ball.gd` (`GuideBall`) with a child `Camera2D` limited to the level size |
| `Ball` + `Walls` (called 5-9 times per frame) | `scenes/ball.tscn` / `ball.gd` (`Ball`); `_touch_terrain()` = `Walls` |
| `map_get_pixel(level,x,y)` | `level_map.gd` (`LevelMap`): palette indices from `assets/levels/<code>.idx` (see below) |
| `HiTimes[30]` / `saves\Ballers.dat` | autoload `scripts/game.gd` (`Game`), file `user://ballers.dat` (31 int32, same layout as the original) |
| `start_scroll` | the level PNG as a `Sprite2D` at (0,0) + `Camera2D` |
| `Framers` (F1-F5 fps debugger) | not ported (debug only) |

Timing: the logic is integer and per frame (friction counters, `Time` in frames, sub-pixel integer
velocities), so the physics tick rate is set to 40 (`physics/common/physics_ticks_per_second=40`) and
every `_physics_process` call is exactly one DIV frame. Physics interpolation is on, so rendering at
60 Hz is smooth. Positions/velocities are kept as `Vector2i` in 1/100 pixel exactly like the original.
The time shown is the frame count (40 per second), as in the original; best times are in frames too.

Terrain (all read from the level's pixel colours, indices from `indices.bin` of the converter):
22 death, 41 win, 54 wall (bounce when moving into it, probes 4 px away), 73 hole (yellow, pulls the ball
in, probes 8 px away, strength `YellowStr`), 89 hill (purple, pushes away, strength `LilaStr`).
Per-level tuning is read from the first pixels of the level graphic: (0,0) `Speedup`, (1,0) `Speedmul`,
(2,0) `YellowStr`, (3,0) `BBGrav` (x10), (4,0) `Reibung`, (2,1) `LilaStr`; value 54 = default, 255 = 54.
`get_index` returns 0 outside the picture (like `map_get_pixel`).

## Assets
Converted with `div_convert.py game`; only what the game uses is shipped: `1.png`/`2.png` (balls), the 8
level graphics in the FPG (codes 100, 101, 102, 105, 110, 115, 116, 117) and the system font.
The 4 MB `indices.bin` was replaced by one zlib-compressed index file per level (`assets/levels/*.idx`,
about 17 KB in total, decompressed at load with `PackedByteArray.decompress`). The export preset has
`include_filter="*.idx"` so these non-resource files get exported (the only change to the standard preset apart
from path and size). Level size and start point (control point 1) are constants in `game.gd`.

## Deviations / guesses
- The original hard-codes `Level=117`; there is a new level list (all 8 levels of the FPG), default selection 18 (code 117).
  Best times of the original `Ballers.dat` are the initial values until a user file exists.
- Esc (menu), Enter (retry) are new; the original could only be left with Ctrl+Esc and had no restart.
- The original kept running after win/lose with the guide ball still steerable and the camera following
  it; this is kept (the ball is frozen). Both texts ("You LOOSE" sic, "You WIN!") are the original's.
- Unfinished-feature notes in the PRG (FPS saving, cannons, 2-player mode, more terrains) were never implemented.
- When the ball touches a death and a win pixel within one frame the original would show both texts; here the first wins.
- Camera: scroll `speed` is 0 in the original, assumed to mean "instant"; the camera is centred on the guide ball and clamped to the level.
- F1-F5 fps keys skipped.

## Verified / needs a human play-test
- Verified headless (`-- --autotest`): all 8 levels load, tuning values read from the pixels are plausible
  (e.g. level 105: speedup 4, speedmul 9, gravity 1500), steering, R recall (+24 frames), win and
  death results, best-time saving to a test file (not the real one), no errors or warnings. Windowed screenshot checked.
- Not verified by hand: real play feel (acceleration, lag of the ball vs. DIV on a real machine - 40 fps assumed exact),
  whether levels are actually winnable with these constants (they are the original's), the web build in a browser.
