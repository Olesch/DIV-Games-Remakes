# S-Type - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/S-TYPE.PRG` (Oleg Yuschuk), 800x600, set_fps(40). Assets converted with
`div_convert.py game` into `assets/` (fpg/s-type, fnt/s-type + s-type2/3/4 digit fonts, fnt/system).
Run: open the folder in Godot 4.7, main scene `scenes/menu.tscn`.

## Controls
Start menu: Up/Down select, Left/Right change, Enter/Space/Esc start. In game Esc returns to the menu (new).

| Player | move | fire | buy | change weapon |
|---|---|---|---|---|
| 1 | arrows (or keypad 8/4/6/2) | Ctrl (Space in the web build) | Right Shift | Enter (keys 1-4 pick a weapon directly) |
| 2 | S / Z / X / C (up, left, down, right) | A | W | Q |
| 3 | I / J / K / L | H | U | Y |
| 4 | G / V / B / N | F | T | R |

Physical key positions are used (the original was written on a German keyboard).
Menu options: players 1-4, shared lives, "Graphikstufe" and "Spieler 4 Joystick" (both shown but unused in the
original, kept for fidelity), passive weapons lost on death.

## Mapping
- Fixed physics tick of 40 Hz (= set_fps(40)); all DIV per-frame values stay per tick (px = DIV value / 100,
  resolution=100). Frame counters (fire rates, amplitudes, timers) are therefore the original numbers.
  Physics interpolation is on so it looks smooth at 60+ Hz.
- `scripts/game.gd` autoload `Game`: menu settings, `Player[]` table (`PlayerState`), `psh`, input actions.
- Level script (main code) -> `scripts/level_script.gd`: a list of steps with Timers (DIV FRAME(n) = n/4000 s);
  loops (`LOOP ... until boss dead`, the 50x spawn loop) are steps with an `until` condition. No coroutines.
- Ship, Compain (4 chained pods), CenterPoint (weapon-4 reticle), shots (`Shot` kinds normal/red/gatling/rear/flak,
  `CenterMissile`, `BoingLaser`, `FlameShot`), `Charger` (boing charge / boss laser charge particles), `Ghost`
  (afterimages), `Explosion`, `Pickup` (money/life/shield/companion), enemies `Snake` (snake_colony, + `SnakeCannon`
  children), `Boomer`, `JumpShooter`, `Bomb` + `Blast`, `Boss` (+ `BossShield`, `BossCannon`, `BossLaser`).
- Collision: Area2D + shapes (rectangles from the opaque bounding box of each sprite, shrunk a little) on layers
  player / enemy / boss_shield. As in DIV the colliding side checks (`Hit` does synchronous shape queries): shots test
  for enemies in sub-steps (2 or 3 per tick), enemies/pickups/bullets test for ships. The bomb `Blast` is a ring in the
  graphic, so it is tested geometrically (ring band), not with a shape. The boss shield is four arc polygons
  (gaps rotate around).
- DIV z (lower = on top) -> z_index = -z: background -500, explosions 10, pickups/cannons/pods 1, buy line 50.
  Texts are on a HUD CanvasLayer with the converted bitmap fonts (font 1 = S-Type, 2/3/4 = digit fonts, 0 = system).

## Faithful details
- Costs are the "buy line": every money pickup advances your cursor one slot (speed, rear, red, gatling, flak, boing,
  flame, targeting, shield, [10 nothing], 11 = companion automatically). Buy key spends it. Speed upgrades stop above 1030.
- Hit = lose a life, ~2.9 s ghost mode; without shield you also lose one level of the active weapons (and passive
  ones if the menu option is on); a shield charge is used up instead of the weapons (lives are still lost).
- Boss cannons are invulnerable and the shield absorbs shots until it breaks (original behaviour).
- Enemies that exit left/top/bottom just vanish; boomers burn out over time.

## Deviations / guesses
- Menu: the original's pointer was one row off from the option it changed and repeated every frame; the pointer now
  matches the selected row and changes one step per key press.
- GAME OVER / winning level 2: the original called `exit()` / simply stopped spawning. Here: fade to black and back to the
  menu (6 s after "Level 2 Won!!").
- Dead player lives count shows 0 instead of -1. Companions/overlays of a dead ship are removed with it.
- Hit shapes are approximations of the pixel-exact DIV collision; ships have a smaller hit box than the sprite.
- Shots fired at spawn time take their first step immediately (DIV runs a new process at once).
- Multiple overlapping targets: the original OR-ed process ids (garbage); here the boss shield wins, else the first.
- Cheats (kept as in the original): hold O to max every ship's weapons, shield, pods and speed (+1 life per frame
  while held, `Ship._cheat_max`); hold A+L+E+X for two extra snake colonies every 9 frames (`World._physics_process`).
- Skipped debug features: F1-F5 fps changes, the `Gatta` debug counter at the top, the Ctrl+Esc exit.
- Original quirk kept: slot 10 of the buy line does nothing.
- Browser: player 1 fires with Space instead of Ctrl in the web build, because browsers never pass Ctrl+W/T/N (players 2 and 4 use those letters) to the page.

## Verified / not verified
- Verified: imports and runs clean headless; `godot --headless --fixed-fps 400 --path . -- --autotest` plays 4 players
  through both levels (jumps to both bosses, buys all weapons, ships die and the game ends) without script errors;
  windowed screenshot looks right; web export succeeds.
- Needs a human play-test: feel of speeds/difficulty, boss shield/laser behaviour, hit-box fairness, 2-3 player
  keyboard ghosting, shared-lives mode, boing gun charge feel.
