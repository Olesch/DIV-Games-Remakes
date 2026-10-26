# Ballkill - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/BALLKILL.PRG`, 800x600, `set_fps(18)` is NOT in the PRG (DIV default 18 fps).
Assets converted with `div_convert.py game` into `assets/` (fpg/ballkill, fnt/ballkill digits font).
Run: open the folder in Godot 4.7, main scene `scenes/main.tscn`.

## Controls
- Mouse only. Left click = hit with the pin (every ball under the pin loses 1 life). Hold the right mouse
  button = the hair-dryer at the top moves right, release = it drifts back left (it does NOT follow the mouse).
- The OS cursor is hidden; the pin graphic is the pointer.

## Rules (as in the original)
- Level starts at 0 and becomes 1 on the first frame; level n lasts `100*n` frames (5.5 s * n at 18 fps).
  There are always `Level` balls alive (one new ball per frame while fewer).
- Ball: life = rand(0,Level), size = 100% + 10%*life, rises at `max(rand(0,Level),1)` px/frame from y=600 at a random x.
  Under the dryer (+-40 px) it is slowed by 7/100 px per frame^2 (-10 +3) and can be pushed back down.
- Hit: life-1, score+1; life<1 kills the ball for another +1. A ball leaving the top ends the game: hiscore is
  saved, a "Game Over" graphic falls down the screen (120 frames), then the original quit to DOS.

## Mapping
| DIV | Godot |
|---|---|
| GLOBALs | autoload `scripts/game.gd` (`Game`): level, score, hiscore, ball_count, signals, hiscore in `user://ballkill.dat` |
| main LOOP | `scenes/main.tscn` + `main.gd`: spawning, level timer, click handling, game over |
| Ball | `ball.tscn` / `ball.gd` (group `balls`), logic per physics tick |
| Foen | `foen.tscn` / `foen.gd` |
| Leveltext + Write_int | `hud.tscn` (CanvasLayer, `PixelLabel` with the digits bitmap font) |
| mouse.graph=3 | `cursor.tscn` (top CanvasLayer) |

Timing: `physics/common/physics_ticks_per_second=18` with physics interpolation: one physics tick = one DIV
frame, so all per-frame constants (and the 1/100 px integer positions, `resolution=100`) are kept unchanged.
Collision with the mouse is pixel-exact like DIV (pin pixels vs the ball's alpha, ball scaled by its size);
no physics shapes are used.

## Deviations
- After the Game Over animation the game restarts after 2 s (the original exited via `exit("Nice playing", Score)`).
- The hiscore is loaded from `user://` at start (the original `Load` line is commented out, so it always began at 0).
  The shipped `BALLKILL.DAT` (459) is not used.
- A click is handled the moment it happens instead of on the next frame; a click shorter than one frame is not lost.
- The dying ball shows the "Pop" graphic for one 18 fps frame, as in the original.

## Verified vs needs play-test
Verified: clean import/run, `--autotest` (clicks balls, blows with the dryer, reaches game over, saves hiscore),
windowed screenshot, web export.
Needs human play-test: feel of the 18 Hz physics with interpolation, click accuracy with the pin, difficulty curve.
