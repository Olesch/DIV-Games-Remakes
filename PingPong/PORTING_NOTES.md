# PingPong - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/PINGPONG.PRG`, 640x480 at 24 fps. Assets from `PingPong.fpg` (1 field, 2 bat, 3 ball),
converted into `assets/` with `div_convert.py game`. Main scene `scenes/options.tscn` (options screen, new),
the match is `scenes/main.tscn`. Web slug `pingpong`.

## Controls
Player 1 (left bat): Q / A. Player 2 (right bat): Up / Down (keypad 8/2 also).
Options screen: Up/Down select, Left/Right change, Enter/Space start (on "Original settings": restore defaults);
mouse: hover selects a row, click left/right of a value (or wheel, right click = back) changes it, click an action runs it.
In the match: Enter/Space after a win, or Esc at any time, returns to the options screen (Start is preselected,
so Enter, Enter = rematch). No Ctrl keys are used, so no browser shortcut conflicts.

## Options (owner's decision 2026-10-26; defaults = the original's hard-coded values)
Values in the `Game` autoload, kept for the session only (not saved). `scripts/options.gd` draws the screen in the
6x8 system font (PixelLabel, 2x/4x), over the field graphic, selected row in the field's green.
| Option | Default (original) | Choices |
|---|---|---|
| Balls | 70 (`FOR x<35`, two per pass) | 2,4,6,8,10,14,20,30,40,50,60,70,80,100,120,160,200 (pairs) |
| Ball speed (`Activity`) | 4 = 16 px/frame | 1, 2, 3, 4, 6 |
| Points to win (lead) | 500 | 50,100,200,300,500,750,1000,2000 |
| Classic one-ball mode | Off | On/Off |
| Left bat / right bat | Human (`Ki=1`) | Human / Computer (`Ki=2`) |
- Activity scales everything it scales in the PRG: ball and bat steps (4*Activity) and the pair release interval
  `FRAME(300/Activity)` (integer division; spawner works in integer percent of a frame, identical at 75).
- Speeds 5, 7 and 8+ are not offered: balls only collide with a bat at whole-frame positions, and with those steps
  the x lattice (320 + k*step, or 8 + k*step after a one-ball-mode bat hit) has no position overlapping a bat
  (e.g. 7: x 12 -> -16), so balls would pass through. The same would happen in DIV (pixel collision per frame).
- Classic one-ball mode = the commented-out `LOOP` in the main code: every frame `rand(0,50)==0` releases one ball,
  side `rand(0,1)`, `Ball(+-4, rand(0,1)*8-4)`, i.e. 4 px/frame regardless of Activity; the ball's own bounce code then
  sets 4*Activity (y at the first wall, x at the first bat). The original loop is endless (and skipped the win
  check that follows it); here the release stops at the Balls value ("up to N") and the win check stays.
  The separately commented `balla=Ball(4,..)`/`ballb=Ball(-4,..)` two-ball start is not used.
- Computer bat = the unused `IF(ki==2)` block: among the balls flying towards the bat (xinc>0 right, <0 left) it
  follows the one nearest to it in x (the PRG compared only Balla/Ballb, which the 70-ball game never sets; here all
  balls are candidates). Both moves are separate IFs as written (y>ball.y AND y>40: up; then y<ball.y AND y<440:
  down), so within one step of the ball the bat steps up and back down and stays put. No ball coming: no move.
  Keys are ignored for a computer bat (the PRG's key tests required `ki==1`).

## Mapping
| DIV | Godot |
|---|---|
| GLOBAL Pointsa/Pointsb, scoring rules, win | autoload `scripts/game.gd` (`Game`), signal `winner_declared` |
| GLOBAL Activity, hard-coded 35 pairs / 500 | `Game` option vars + `options.tscn` / `options.gd` (new screen) |
| Main code (spawning 35 pairs, FRAME(75)); commented-out random LOOP | `ball_spawner.gd` (4 pairs per 3 ticks; one-ball mode) |
| Main code win check + 5x `Write` | `main.gd` banner of 5 `PixelLabel`s (system font) |
| Bat (Ki=1 keys, Ki=2 computer) | `bat.tscn` (Area2D, layer "bat"), `computer` flag, `_follow_ball()` |
| Ball + `collision(TYPE Bat)` | `ball.tscn` (Area2D, group "balls", mask "bat", `has_overlapping_areas()`) |
| Background | Sprite2D at z_index -5 |

Timing: `physics_ticks_per_second = 24` (= set_fps); bat and ball logic run once per tick with the original
16 px/frame steps, because the bounce/score tests depend on those discrete positions (balls would otherwise
tunnel or bounce at different spots). No physics interpolation, like the original's 24 fps look.

## Original behaviours kept
- Bats stop at y=32 / y=448 (move only while y>40 / y<440, in steps of 16 from 240).
- Balls bounce at y>=468 / y<=12, so they leave the screen by up to 12 px.
- Pointsb is the left player's score, Pointsa the right player's (a ball leaving on the right gives Pointsb).
  The scorer gets 3 points when behind, else 2. Win when 500 ahead (strict). Scores are never displayed.
- After a win the banner ("   Wins > " / " < Wins   ", written 5 times at y 220..260) stays and the balls
  keep playing, as in the original (main process just returned).
- Balls spawned in the same tick are identical and overlap exactly.

## Not ported / new
- Bat `ki==2` computer-player code was unreachable (both bats are created with ki=1); now an option (see above).
- New: options screen; Enter/Space after a win and Esc in the match go back to it.

## Verification
- 2026-10-26 (options): import, `--quit-after 300` and `-- --autotest` (defaults; the options screen hands over
  to the match at once with `--autotest`) clean. Temporary headless test (deleted): keyboard and mouse change values,
  "Original settings" restores; match with 20 (and 4) balls, Activity 2, lead 50, one-ball mode, both bats computer:
  balls appear at random at 4 px/frame, speed up to 8 after bouncing, stop at the cap; computer bats move alone,
  a bat ignores balls moving away and climbs to a ball in 8 px steps; win at lead 50; Enter after the win returns
  to the options screen. Windowed screenshots of the options screen checked.
- Needs a human play-test: options screen mouse use in the browser, feel of the computer bats.
- `--import` and `--quit-after` clean; `-- --autotest` (70 balls, bat limits, scoring, win banner) passes,
  screenshot via `--screenshot=<path>`; web export succeeds (wasm brotli-compressed).
- Needs a human play-test: feel of ball speed (16 px/frame at 24 fps = 384 px/s), bat collision edge cases.
