# Canonball Riding - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/CBRIDE.PRG` (Oleg Yuschuk, 23/07/2004), 640x480, `set_fps(24)`.
Assets: `div_convert.py game` -> `assets/` (fpg/mini2, fnt/mini2, dat/cbscore1|2.json). The unused system font
and `indices.bin` files were deleted. Run: main scene `scenes/main.tscn`.

## Controls
- Title: `1` one player, `2` two players, `Esc` quits (desktop only; ignored in the web build).
- Player 1: Left / Right arrows (or keypad 4 / 6). Player 2 (two-player game): `A` / `D`.
  Each key press changes the horizontal speed by 1 px/frame per frame (max 25); wind pushes the riders.
- `Esc` during play ends the run (like the original); `Esc` after game over returns to the title (new).
- No Ctrl keys are used, so the web build needs no key changes.

## Mapping
| DIV | Godot |
|---|---|
| GLOBAL (Wind, score, Hiscore1/2, Playercount), save files | autoload `scripts/game.gd` (`Game`), input actions registered there |
| main code menu + game loops, `escproc`, `PlayerMinus` | `scenes/main.tscn` + `main.gd`: state machine MENU / PLAYING / GAME_OVER |
| cannon shot loop, `KanShotRate` | `battery.gd` (`Battery` node, emits `ball_fired`) |
| `WindRegulator` | `wind_regulator.gd` |
| `player` | `player.tscn` (Area2D, polygons built from the sprite's opaque pixels) |
| `Cannonball` | `cannonball.tscn` (Area2D circle, scaled with size, group `cannonballs`) |
| `cloud`, `explode` | `cloud.tscn`, `explosion.tscn` (AnimatedSprite2D, 6 frames x 1.5 frames, 500 %) |
| `write`/`write_int` | `hud.tscn` with `PixelLabel` (Mini2 bitmap font at 32 px) |

Timing: the game logic is per-tick, so `physics_ticks_per_second = 24` with physics interpolation on (smooth on
60 Hz+ screens); one `_physics_process` call = one DIV frame, all values are the original integers
(x_inc, angle in 1/1000 deg, `size`, `z` -> `z_index = -z`). Physics layers: 1 player, 2 cannonball.
Hiscores: raw int32 files `user://CbScore1.sav` / `CbScore2.sav` (same format as the DIV .sav files), seeded from the
original saves (1 player 210, 2 players 78) when missing.

## Faithful details kept
- Riders move |x_inc|+1 pixels per frame using x_inc from *before* the key presses of that frame (one-frame lag);
  walls at x<1 / x>639 bounce and negate x_inc.
- Rider collision (player 1 detects): speeds are swapped, the mover gets +-15 extra that frame, 3-frame cooldown;
  if player 1's old speed was 0 player 2 gets no change (`speedchange<>0` test).
- Cannonball: start y=500, size 5-15 % growing +1 per frame, y_inc +1 per frame; dangerous only when size > 50.
  A hit costs a life (3 lives, 4th hit kills), 24 frames of invulnerability. Lives are not displayed (as in the original).
- The score counts +1 per fired cannonball while playing; the first death (or Esc) ends the run, also in two-player
  games (the other rider keeps flying and being hit, the score stops). The big final score and the hiscore save happen
  at the next cannon shot after game over, as in the original.
- Shot interval `KanShotRate/100` frames: 48 at start, falling by 1-2 per frame until 12, then 1, then 0-1 per frame (min 3 frames).
- Wind: 15 clouds move by `Wind*(size/50)` px/frame (very fast at strong wind); wind target changes after 240 calm frames, 1 step per 12 frames.

## Deviations / guesses
- `rand(-25,-35)` has reversed bounds in the original; I use -35..-25.
- Collision uses `get_overlapping_areas()` of Area2D shapes, so it is one tick delayed; with several overlapping balls
  any dangerous one counts (DIV took the first overlapping one only).
- Esc after game over returns to the title instead of exiting; Esc on the title exits (not on web). The exit message
  "Ride Canonballs again soon!" is not shown.
- The original starts the wind regulator and clouds at program start; same here, they keep running through menu and games.
- Skipped: nothing gameplay related (no debug features in CBRIDE). MINI2.PRG's third player is not ported.

## Verification
- `--import` and `--quit-after` runs are clean (no errors/warnings).
- `-- --autotest` (headless and windowed) plays a 2-player game, forces hits until a rider dies, checks scoring, game over,
  hiscore saving and a 1-player run: 0 failures. `--screenshot=<path>` stores a frame.
- Needs a human play-test: feel of steering at 24 ticks with interpolation, hit fairness vs. pixel collision.
