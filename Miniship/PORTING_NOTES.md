# Miniship - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/MINISHIP.PRG` (Oleg Yuschuk), 800x600, set_fps(30).
Assets: `div_convert.py game` -> `assets/fpg/miniship`, `assets/fnt/system` (the game only uses the DIV system font).
Run: main scene `scenes/menu.tscn`. Web slug `miniship`.

## Controls
Menu: Up/Down select a row, Left/Right change the value (key repeat works), Enter starts (needs 2+ players ON/PC),
Esc quits (desktop only). Rows: ships A..D (OFF / ON / PC Easy / PC Normal / PC Hard / PC King), start energy
200..3000, planet gravity 3000..16000, particles (None/Normal/Much), laser type (7), energy load (5),
game type (Standart / Simple / Hold the Flag), asteroids 0..9. The menu picture is the original and still
mentions F1/F2 and Alt-X (not ported).

Game (Backspace or Esc = back to the menu):
| Player | Thrust | Turn left | Turn right | Fire |
|---|---|---|---|---|
| A (Ship 1) | Up | Left | Right | Ctrl (desktop) / Right Shift (also in web) |
| B | W | A | D | Left Shift |
| C | Num 5 | Num 1 | Num 3 | Num 0 |
| D | I | J | L | Space |

Turn left + turn right together = shield (3 energy/frame). Shield + fire = rocket. Tap both turn keys again
2..8 frames after letting go = teleport (50 energy). The web build does not bind Ctrl at all (Ctrl+W - player B thrust
while A fires - would close the browser tab); player A fires with Right Shift there. Num-pad players need a keyboard
with a num pad.

## Mapping
| DIV | Godot |
|---|---|
| GLOBAL options, points, shipa..d/tot | autoload `scripts/game.gd` (`Game`): options, `points`, `ships[4]` (alive ship or null), input actions, `points_changed` signal |
| Main code menu + `Moover` + texts | `scenes/menu.tscn` + `menu.gd` (input via `_unhandled_input`) |
| Main code match loop | `scenes/world.tscn` + `world.gd`: phase state machine (GET_READY 18 frames, SETTLE 4, PLAYING, ENDING 4, RESPAWN 72) driven by one `Timer` |
| Ship / Shot / Rocket / Asteroid / Planet / Flag | one scene + script each (`ship.gd`, ...), common base `space_body.gd` (positions in 1/100 px, velocity, wrap, circle collision) |
| Particeleffect / Laserspec / shieldspec / telspecin/out | `effects.gd`: one node holding particle arrays and one-frame sprites, drawn in `_draw()` |
| Energyline, write_int of the points, GET READY | `hud.tscn` + `hud.gd` (CanvasLayer, `PixelLabel` = DIV `write` with the 6x8 system font) |
| `put_pixel` stars | `stars.gd` (300 white pixels per match) |
| `get_id(TYPE ship)` etc. | groups `ships`, `rockets`, `asteroids`, `gravity_bodies`, `round_entities` |
| `newstart=1` (round over) | `call_group("round_entities", "end_round")` |
| `collision()` | circle overlap (`SpaceBody.overlaps`): ship 9 px, rocket 4, shot 7, flag 6, asteroids 10/15/20, planet 39*size%. Shots move up to 21 steps within a frame, so Area2D could not be used |

Timing: `physics_ticks_per_second=30`, physics interpolation on; gameplay code runs once per physics tick with the
original integer maths (resolution 100: x += xinc/10 per frame, thrust +100, gravity
`weight*dx/ (isqrt(dx^2+dy^2))^3` with dx in 10 px units, all integer-truncating like DIV). Ship turn rate 11.25 deg/frame.
Timers (GET READY etc.) convert frames/30.

## Faithful details / original quirks kept
- Laser types: Laser (hit 50), Durable (10, cost 3, full auto), Lasershot (60, slow bolt), Machinelasershot (45, slow bolt,
  fire every 3 frames), Spreader (30, curling), Sniper (500, 70 frame cooldown), GravitLaser (90, always fires at the planet).
  All but Lasershot/Machinelasershot are instant beams in the original (`FRAME(1)` lets 100 loop passes run per frame), ported as such.
  Shield reflects a beam (+-20 degrees, loses 6 steps); rockets ignore shields; lasers shoot rockets down.
- Types 0/2/6 fire once per key press (the cooldown only resets on release); AI ships never "release" so they fire every frame.
- AI (Easy..King): flies at the nearest ship (or flag / flag carrier in Hold the Flag), turns away if the planet is in line, shoots
  with chance `1/((3-level)*5+2)` per frame within 260 px, shields (+rocket) against shielded targets, teleports when within
  55*size% of the planet or randomly 1/1001. The original `fget_angle(x,xinc,y,yinc)` argument bug is replicated, so the AI almost always thrusts and
  burns its energy (energy bars of PCs sit near 0 a lot).
- Wrap to 1 / 79999 like the original; Planet kills ships on touch (energy -500).
- Rounds: points when at most one ship survives (needs `dead >= 3` counting OFF ships); ships return after only 22 frames. Hold the Flag:
  no rounds, -1 per death, +3 to the flag carrier whenever another ship dies, respawn 72 frames, one at a time.
- Asteroid hitting the planet vanishes 70 frames and restarts at (0,0).

## Deviations / guesses
- Collision uses circles instead of pixel overlap (radii guessed from the sprites).
- Velocity swap on ship/asteroid collisions is protected for two frames (original: `changed=1; changed--` in the same frame, so the
  partner process could swap again and cancel the bounce depending on process order).
- Backspace in the original left the ships alive and restarted the menu (buggy `signal(son, s_kill_tree)`); here it cleanly returns to the menu. Esc quits in the original; here Esc returns to the menu in-game and quits only from the menu on desktop.
- Menu keys repeat through OS key repeat (original: one step per frame while held).
- Skipped: F1-F5 fps debug keys, `Framers`, the unused "Autozielen"/Fadenkreuz code, unused `Schusshold`.
- Division by zero in gravity at exactly zero distance is guarded.

## Verification
- `godot --headless --fixed-fps 30 --path . -- --autotest` plays 8 scenarios (all laser types, play types, particle levels, 0-9 asteroids,
  4 PCs, human key actions) and prints a summary; no script errors. Also checks left/right shift map to different players.
- Windowed screenshot with `scripts/debug/capture.gd` (`godot --path . --script res://scripts/debug/capture.gd -- out.png 6`).
- Needs a human play-test: feel of speeds/gravity, AI difficulty feel, multi-player keyboard ghosting, web build in a browser, circle collision sizes.
