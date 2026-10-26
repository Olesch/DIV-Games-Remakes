# Snake - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/SNAKE.PRG` (DIV "Tutorial 4" by Daniel Navarro Medrano, modified by Oleg), 20 fps, 640x480.
Assets: `div_convert.py game` -> `assets/` (fpg/tutor4 = frame 1, worm segment 2, apple 3; fnt/system).
Run: open the folder in Godot 4.7, main scene `scenes/main.tscn`. Web export slug: `snake`.

## Controls
Cursor keys (or keypad 2/4/6/8) = straight, **E Q Z C** (or keypad 9/7/1/3) = diagonals (physical key positions,
like DIV scan codes). The worm never stops; it can also reverse into itself (= death, as in the original).
No other keys (the original has none; Esc does nothing).

## Rules (all as in the original)
- Worm moves 8 px per frame, 20 frames/s (physics tick rate is set to 20, one `Worm.step()` per tick).
- Start length 8, starts at (8,96) heading right. One apple at a time, at `rand(1,38)*8, rand(3,23)*8`.
- Apple: length +1, score +20 (`Frames`). Death: head on a non-zero background pixel (the frame) or on its own body,
  then 0.4 s fade out, 0.4 s fade in, topscore updated, score 0, length 8, new worm. The apple stays.
- Segments: the worm body is the head's trail, `worm_length-1` visible cells (max 129 like the 129 original segments).
  The head itself is invisible (`size=0`). The apple is eaten one step after the head enters its cell (the original
  tests the collision before moving); wall/body are tested after the move.

## Mapping DIV -> Godot
| DIV | Godot |
|---|---|
| GLOBAL worm_length/apples/score/topscore | autoload `scripts/game.gd` (signals for the score labels, wall lookup, input actions, topscore file) |
| main code (apple spawner, texts) | `scenes/main.tscn` + `main.gd` |
| worm_head + worm_segment x129 | `worm.gd` (one node, trail array, `_draw()`); input via `_unhandled_input` |
| apple | `apple.tscn` (Sprite2D, group `apples`) |
| `get_pixel(x,y)!=0` | alpha of the converted frame PNG (index 0 = transparent) |
| write_int | `PixelLabel` (system font, updated by signals) |
| fade_off/fade_on | tween on a black `ColorRect` in a CanvasLayer |

## Deviations / decisions
- **Layout quirk fixed:** the original sets 640x480 but the background is only 320x200, and `put_screen` centres it
  (confirmed by DIV help). All game coordinates are screen coordinates, so the worm starts left of the frame, most of
  the playfield is black void, the score numbers sit outside the frame and apples/worm can leave the screen (no wall
  outside the frame; a worm that runs off screen is simply gone until you steer back). `Game.FIT_TO_FRAME = true`
  shifts the play field by (160,140) so it matches the frame exactly (apparently what the tutorial intended); this is the default. Set it to false for the original layout.
- Input is event based (last pressed direction wins, applied at the next step). The original polls held keys every frame
  (arrow keys override diagonals); a tap shorter than one step (50 ms) is not lost here but was in the original.
- Topscore is now saved in `user://snake.cfg` (original: session only). The autotest disables saving.
- Head `size=0`: in DIV collision with an invisible process may never fire; the port assumes the tutorial worked.
- Fade speed is a guess (8 frames each).
- Skipped debug features: none (the `Frames` variable is only used for speed/points).

## Verification
- `godot --headless --path . --import` and `--quit-after` runs clean (no errors/warnings).
- `-- --autotest` (headless and windowed): bot eats 3 apples (score 60, length +3), wall crash -> restart with
  topscore 60, self-bite via a 4-move loop, input event path, and no file left in `user://`. All pass.
  `--screenshot=<path>` saves a gameplay image (`screenshot_gameplay.png`).
- Web export succeeds; not run in a browser by me. Needs a human play-test: feel of the 20 fps stepping and keys.
