# Balls - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/BALLS.PRG` (Olesch), 1024x768, `set_fps(100,0)`, `resolution=10`.
Assets: `div_convert.py game` -> `assets/fpg/ball` (1 = ball 15x15, 2 = "Mappa" 1024x768 with the seed ball,
3 = a 10x10 ball that is never used) and `assets/fnt/system` (only for the added hint line).
Web slug: `balls` (export to `_web/public/balls/`).

## Controls
None in the original (it just runs). Added: **R** clears the picture and starts again; a one-line hint
"R - restart" (DIV system font, 2x) sits in the bottom-left corner.

## What it does
A ball is released at a random point of a random screen edge every 6 frames and flies straight at the
centre; it sticks as soon as it touches the seed ball, a stuck ball, or another flying ball. The stuck balls
grow into a branching tree (diffusion-limited aggregation without the random walk).

## Structure
| DIV | Godot |
|---|---|
| main program LOOP (spawning) | `scripts/spawner.gd` (`Spawner`, node in `main.tscn`), counts physics ticks |
| PROCESS Ball | `scenes/ball.tscn` + `scripts/ball.gd` (`Ball`, group `flying_balls`) |
| PROCESS MAPPA + graphic 2 + `map_put` | `scripts/cluster.gd` (`Cluster`, a Sprite2D showing an `Image`/`ImageTexture`; stuck balls are blended into the image with `blend_rect`) |
| `collision(TYPE MAPPA)` | `Cluster.is_blocked()`: a precomputed "blocked" byte field (one lookup per step). Stamping a ball marks its pixel-exact self-overlap footprint (all offsets b2-b1 of the ball's opaque pixels), so the test is exactly DIV's pixel overlap of two balls |
| `collision(TYPE Ball)` | `Cluster.balls_overlap()` against the few flying balls (same footprint table) |
| main | `scripts/main.gd` (R restart) |

Timing: per-tick logic. `physics_ticks_per_second = 100` (= set_fps 100); one `_physics_process` call is one
DIV frame. Each frame a ball takes up to 40 steps of `advance(10)` (1 px each, 4000 px/s) and checks for
contact before every step. Spawning: `x = rand(1,4)`; sides 1-3 release one ball, side 4 (right edge)
releases four balls 4 frames apart; then 6 frames pause. A newly spawned ball moves in its spawn frame
(a new DIV process runs immediately), `Ball.fly()` guards against moving twice in one tick.

Positions are kept as integers in tenths of a pixel, with the original's direction arithmetic:
`fget_angle` (truncated thousandths of a degree), then `advance` steps of `(int(cos*10), int(-sin*10))`
tenths. This quantisation matters for the look (see quirks).

## Original quirks kept
- **Right edge gets 4x the balls**: only branch 4 of the spawn code contains the burst of four, so the
  tree always grows lopsided towards the right.
- **Quantised directions**: because each step is truncated to whole tenths of a pixel, balls only move in a
  few dozen directions and most do not aim exactly at the centre. Early balls often miss the seed and leave
  the screen (that is the only time the off-screen check `x<-50 OR x>10290 ...` fires). The branches show
  these preferred directions.
- **Mid-air clumps**: two flying balls that touch stop for good, so small free-floating clusters appear
  away from the tree.
- The screen eventually fills completely (after ~2-3 minutes); there is no end. R restarts.

## Deviations
- In the original, only balls that touch the seed graphic are `map_put` into it; balls that touch a stuck
  or flying ball (checked first) never die and stay on screen as frozen sprites forever (thousands of live
  processes after a few minutes). The port stamps every stuck ball into the image and frees the node. The
  picture and the behaviour are the same (a stuck ball is always drawn at the same spot as its stamp).
- Flying balls are drawn unrotated (the original rotated the round ball sprite towards the centre; it is a
  disc, so only dithering details would differ) and collisions ignore rotation.
- Dead code not ported: `Kill=1` after `BREAK`, the unused `Stay` parameter, the commented `load_fnt`.
- `set_fps(100)` is used as requested; on 2000s hardware it may have run slower (it is a toy, the speed
  barely matters).
- `fget_angle` rounding (truncate vs round) is a guess; it only changes rare edge directions.

## Verification
- `godot --headless --path . --import` and `--quit-after 300`: clean.
- `godot --headless --path . -- --autotest` (`scripts/debug/autotest.gd`): fast-forwards 150 s of game
  time by raising the tick rate, checks spawn count (~19.5 balls/s, matching the expected 1.75 balls per
  9-frame cycle), stuck balls, escaped balls, bookkeeping, then sends the `restart` action and checks the
  reset. Result: PASSED (spawned ~2920, stuck ~2910, escaped ~10). Add `--screenshot=<path>` (windowed run)
  to save a picture after 45 s; it writes nothing to `user://` (file logging and the shader cache are
  disabled in project.godot; Godot itself still creates the empty `app_userdata/Balls` folder).
- Real-time speed measured headless: 100 ticks/s held.
- Web export builds (`_web/public/balls/`, wasm brotli-compressed); not tested in a browser.
- Needs a human look: web build in a browser, overall feel compared with the DOS original.
