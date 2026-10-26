# Tutorial 1 (ship duel) - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/MINI1.PRG` (PROGRAM Tutorial_1, "Tutorial 1" by Oleg Yuschuk, 17/07/2004), 24 fps, 640x480.
Title used: **Tutorial 1** (the only title in the PRG; folder/slug `ShipDuel` / `ship-duel` are working names).
Assets: `div_convert.py game` -> `assets/` (fpg/mini1, fnt/mini1, fnt/system). Mini1Bak.FPG is a backup, not used.
Graphic 17 (BACK1.MAP) is unused by the original (put_screen is commented out); not used here either.

## Controls
- Settings screen (first screen): Up/Down select row, Left/Right change value by the step ("Pinselgr", top right),
  Q/W -1/+1, A/S -10/+10, Z/X -100/+100 step; E R T Y U I set step 1/5/10/50/100/1000 (physical key positions, US layout).
  Esc / Enter / Space start the match.
- Match, 4 ships in the corners (turn only, shoot along heading): P1 Left/Right, Up = shot, Down = explosion shot
  (original: End, see below); P2 A/D, W, Q; P3 keypad 1/3 (End/PgDn), keypad 5, Del; P4 J/L, I, U.
  Esc returns to settings. No Ctrl keys are used, so no web remap.

## Structure
| DIV | Godot |
|---|---|
| GLOBAL settings | autoload `Game` (`game.gd`), rows listed in `Defs.SETTING_ROWS` |
| main code settings LOOP | `settings.tscn` / `settings.gd` (+ new title block in the empty lower half) |
| main code match setup, put_pixel stars, `screen` process | `arena.tscn` / `arena.gd` (star Image, Level sprite, wall bitmap in `WallMap`) |
| player | `ship.tscn` (Area2D, polygon from sprite alpha) |
| playershield | `shield.tscn`, child of the ship (turns with it) |
| shot / Exploshot / explode / shrink | `shot.tscn`, `exploshot.tscn`, `explosion.tscn`, `fading_shot.tscn` |

Timing: `physics_ticks_per_second=24` and physics interpolation on, so one `_physics_process` = one DIV frame and the
integer logic (angles in 1/1000 degree, counters) is kept literally; interpolation only smooths drawing.
Layers: 1 ship, 2 shot, 3 shield, 4 explosion; overlaps are polled with `get_overlapping_areas()` (one tick behind DIV's
immediate check), except shot vs shield, which is an immediate shape query at the shot's new position (see below). Shot vs wall uses the map pixels (`WallMap`, shot silhouette), like `collision(TYPE screen)` / `map_get_pixel==55`.
`advance()` truncates to whole pixels per step (diagonal shots are slower), emulated.

## Deviations / guesses
- Added: winner banner ("Spieler N gewinnt"/"Unentschieden") when <=1 ship is left, Esc/Enter back to settings, title text. The original never ends.
- Settings pointer is clamped to the 14 rows (original ran off the list); keys repeat via OS key repeat instead of once per frame.
- Explosion collision: discs for graphics 11-14 only; the sparse debris frames 15/16 do not collide. Ship/shield use alpha polygons, shots/explosions circles.
- Rows 10/11: the original labels were swapped vs. the code; now fixed (see owner's decisions): row 10 (Eigenkilla) =
  "Eigenzerstoerung Schiffe" = own shots hurt their own ship (0 = swallowed, shrink away); row 11 (Eigenkillb) =
  "Eigenzerstoerung Schuesse" = shots of one ship destroy each other (0 = same owner's shots pass).
- Fonts: texts use the 6x8 system font like the original (font 1 is loaded but unused there); Mini1 font only for the new title/banner.

## Original bugs kept
- `Clicked` is reset by the other fire key's ELSE branch, so a single held fire key always auto-fires every ShotStop frames and Fastfire only matters with both keys held.
- Mana is never spent (`Mana`/`Manamax` unused); the explosion shot only needs `shotwait < 1-ShotStop*3-20` (about 2.5 s without shooting). It only destroys shots, never ships.
- Arrow keys and keypad share scan codes (Up/KP8 etc.), kept. (End/KP1 conflict: fixed, see owner's decisions.)
- Settings are unbounded (negative lives, zero speeds ...).
- Debug features: none in the original besides the above.

## Owner's decisions (2026-10-26, after play-test)
- Shield bug fixed (port bug): DIV turns a shot that touches a shield around (`angle += 180000; advance(6)`), checked at the
  position just reached. The port used the one-tick-old `get_overlapping_areas()`, which still reported the shield after the
  turn-around, so the shot flipped every tick (+7 / -6 px) and hung in the shield forever. `Shot._touches_shield()` now does
  an immediate `intersect_shape` on layer 3 at the new position; the shot bounces back off the shield like the original.
- Key conflict: End/KP1 (DIV scan code 79) was both P1's explosion shot and P3's turn-left. P1's explosion shot moved to
  Down (+ KP2, its keypad twin), unused in the match and next to P1's Up = shot; P3's keypad cluster stays intact.
  Settings help text updated.
- Settings rows 10/11 labels swapped back to match the code (values/mapping unchanged).
- Kept on purpose: Fastfire doing nothing with one key, explosion shot not costing mana, unbounded settings.

## Verification
- 2026-10-26: temporary headless test fired a shot straight at ship 2's shield: before the fix it stayed at 35 px from the
  ship flipping its angle every tick; after it turns around once and flies away (ship unhurt). Test deleted. Import,
  `--quit-after 300` and the autotest (default + Eigenkill 0/0) clean.
- Headless import and 300-frame run of the settings scene: clean. `scenes/arena.tscn -- --autotest` (probe shot bounce,
  4 ships firing, explosion shots, ship deaths) passes for default settings and three variants (`--set=key=value`).
- Windowed screenshots checked (`screenshot_gameplay.png`). Needs human play-test: feel of speeds, polling lag of overlaps,
  web export in a browser.
