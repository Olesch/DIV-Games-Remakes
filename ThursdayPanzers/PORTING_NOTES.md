# Thursday Panzers - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/THURPANZ.PRG`, 24 fps, 800x600. Assets converted with `div_convert.py game`
into `assets/` (fpg/thurpanz, fnt/thurpanz). Main scene `scenes/setup.tscn` (setup screen), match `scenes/main.tscn`.

## Controls
- Player 1 (left window, green team): arrow keys steer/accelerate/reverse, Enter fires.
- Player 2 (right window, red team): A/D turn, W/S forward/reverse, Q fires.
- Setup screen (new, see owner's decisions): player 1 arrow keys edit the team 1 column, player 2 W/S/A/D the
  team 2 column (Up/Down = line, Left/Right = value); Enter / Space / Q start the match (on REINFORCEMENTS /
  ORIGINAL VALUES they toggle / reset), Esc starts too. Mouse: left/right half of a value = less/more, right
  button = less, wheel; click START MATCH / ORIGINAL VALUES / the reinforcement value.
- Esc in the match: back to the setup screen (new; the original could only be quit with Ctrl+Esc), so Esc Esc
  is the old quick restart.
- No Ctrl key is used, so no web-specific key remap was needed.

## Structure
| DIV | Godot |
|---|---|
| (new) setup screen | `scenes/setup.tscn` + `scripts/setup.gd` (PixelLabels in the Thurpanz font, help in the system font) |
| hard-coded Panzer(...) arguments, row loops, commented-out LOOP | autoload `Options` (`scripts/options.gd`, session only, not saved) |
| main program, Draw() | `scenes/main.tscn` + `scripts/main.gd`: spawns the tanks, builds the grass map, reinforcements |
| two scroll windows + regions 1/2 | two `SubViewportContainer`/`SubViewport` (390x590 at 5,5 and 405,5) sharing one `World2D`, one `Camera2D` each (limits = 1600x1200 map) |
| GLOBAL Panzersteama/b | autoload `Game` (`team_count`, `player_tank`, `player_life`) |
| PROCESS Panzer | `tank.tscn` / `tank.gd` (Area2D, group `tanks`) |
| PROCESS Schuss | `shot.tscn` / `shot.gd` (Area2D, mask = tank layer, uses `area_entered`) |
| PROCESS Explode | `explosion.tscn` (AnimatedSprite2D, graphics 60..65 at 24 fps, scaled by size%) |
| write_int texts | `Hud` CanvasLayer with `PixelLabel`s (Thurpanz.FNT bitmap font) |

Timing: physics tick rate is 24 Hz (`physics/common/physics_ticks_per_second=24`), one tank/shot
step = one DIV frame, so all constants stay in DIV units (move = 1/100 px per frame, angle =
1/1000 degree). Physics interpolation is on so it renders smoothly at the display rate.
The grass (random palette colours 34..37 per pixel) is a random R8 texture quantised by
`ground.gdshader`.

## Faithful details
- Tank acceleration `+velo`, reverse `-2*velo`, max `velo*20` / `-velo*5`, turn rate `velo*50 + move*2`,
  friction `near_angle(move,0,velo/2)`, reload 24 frames, shot 20 px ahead then `5 px + move` per
  frame for 40 frames, shot damage `power` (x5 and AI retreat for 50 frames when hit from behind),
  friendly fire `power/5`, overlapping tanks (<30 px) are pushed 5 px apart each.
- AI: nearest enemy, turns to it, drives towards it while farther than 150 px, fires when aimed within 20 degrees.
- When a player's tank dies, the camera/controls pass to the first living computer tank of the team.
- DIV's `get_id(TYPE Panzer)` never returns the calling tank (checked in the released DIV source,
  `src/runtime/f.c`: `if (i!=id && ...)`), so a tank only slows down (Move*2/3) when another tank is
  within 30 px. Top speed is the `velo*20` cap: 8 px/frame for player tanks, 6 for AI tanks.
- Original quirk kept: the "behind" test compares unwrapped angles, so some rear hits count as front hits.

## Deviations / additions
- The original starts the second player tank with `player=0` (team 2 had no human, window 2 never
  followed anything). The intent is obviously player 2, so it is `player=2` here.
- Winner message ("TEAM n WINS - ESC TO RESTART") when a team has no tanks left; the original had no end.
- Collision uses a rectangle (40x22, the opaque part of the tank sprite) vs. a circle for the shot
  instead of pixel-exact collision; one tick of ordering differences vs. the DIV process order.
- Life/counter texts keep the original positions (they overlap slightly, as in the original).
- A dying player tank shows its last life value (not memory of a dead process).

## Owner's decisions (2026-10-26)
- New setup screen before every match (and after Esc) for the values the original hard-codes. Defaults are
  exactly the original match; "ORIGINAL VALUES" restores them, the status line says whether anything differs.
  | Option (per team) | Default team 1 / team 2 | Range, step |
  |---|---|---|
  | TANKS (total incl. the player's tank, as the HUD counter) | 22 / 28 (rows every 80 / 60 px) | 1..61, 1 |
  | PLAYER LIFE / DAMAGE / SPEED (`life`, `power`, `velo`) | 300 / 10 / 40 both | 25..3000 step 25, 1..100 step 1, 5..100 step 5 |
  | COMPUTER LIFE / DAMAGE / SPEED | 200 / 5 / 30 both | same ranges |
  | REINFORCEMENTS (both teams) | OFF | ON / OFF |
- Tank rows: at the original team size the original spacing is kept (team 2's row ends at x=1560 as in DIV);
  any other size is spread evenly over 0..1600 (1 computer tank: x=800). Same `rand(-10,10)` / `rand(-15,15)`
  jitter and rows at y=300 / 900.
- Reinforcements = the commented-out loop at the end of the DIV main program: every 24 ticks (`FRAME(2400)` at
  24 fps = 1 s), starting at once, `Panzer(rand(0,1600),rand(0,1200),75,5,25,0,2)` then the same for team 1.
  Their values are fixed (75/5/25, as in that code). New: the spawning stops once a team has won (the original
  has no win). A player whose last team tank died does not get a reinforcement tank (as in DIV).
- Winner text is now "TEAM n WINS - ESC FOR NEW MATCH".
- Verified: import + `--quit-after 300` clean; `--autotest` still 22 vs 28 tanks with the defaults; temporary
  headless tests (deleted) set non-default values and checked every tank's life/power/velo, team sizes and
  reinforcement pairs after 3 s, plus keyboard/mouse editing and the setup -> match -> Esc -> setup flow;
  windowed screenshot of the setup screen checked.

## Verified / unverified
- Verified headless/windowed with `-- --autotest [--screenshot=path]` (skips the setup screen, original values): spawn (22 vs 28 tanks), movement,
  firing, hits and damage, death, camera hand-over, split screen rendering, web export.
- Needs a human play-test: tank speed feel, AI behaviour over a full match.
