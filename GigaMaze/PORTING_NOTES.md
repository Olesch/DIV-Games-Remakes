# GigaMaze - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/GIGAMAZE.PRG` (440 lines, unfinished), 640x480, `set_fps(40,0)`.
Assets: `div_convert.py game` into `assets/` (fpg/gigamaze, fnt/gigamaze). Main scene `scenes/main.tscn`.

## Controls (4 players, all always present, no AI)
Original keys are passed as process parameters `ship(player, up, down, left, right, shot)`; mapped to InputMap actions
`p<N>_up/down/left/right/fire` (physical keys, created in `scripts/game.gd`).

| Player | Colour | up / down / left / right | fire |
|---|---|---|---|
| 1 | blue | Arrows (or keypad 8/2/4/6) | Ctrl (web build: Space) |
| 2 | yellow | 2 / W / Q / E | 1 |
| 3 | green | 9 / O / I / P | 8 |
| 4 | red | H / N / B / M | G |

Esc quits (original: Esc = `exit`). **Web:** Ctrl is replaced by Space for player 1, because browsers swallow
Ctrl+W / Ctrl+N / Ctrl+T / Ctrl+1..9 and those keys are other players' controls.
A direction key sets the heading and the ship keeps flying that way until blocked (original behaviour: `dir` is
never reset on key release). Fire is edge-triggered (`AnFaSho`).

## Mapping
| DIV | Godot |
|---|---|
| GLOBAL `Stat[]`, `Level` | autoload `Game` (`scripts/game.gd`) + `PlayerStats` (signal `changed` drives the HUD) |
| level graphic 500, `map_get_pixel`, `get_point` | `LevelData` (`level_data.gd`) reads `indices.bin` + `meta.json`; colour index 1 = floor, anything else (6, 81, 89) = wall |
| `Ship` | `ship.tscn` (Area2D) - 4 px per tick in 1 px sub-steps with the original 3 wall probes (nose +7, +-6 sideways) and the 14x14 ship-vs-ship blocking test; screen wrap |
| `Patron` | `shot.tscn` (Node2D) - 1 px sub-steps, speed 8 (bullet) / 7 (green laser), hit test then wall test then move |
| `Crystal` | `crystal.tscn` (Area2D) - +200, then jumps to a random diamond place (control points 5..10) |
| `Item(n)` | `pickup.tscn` (Area2D); created for control points 11..55 that exist and lie inside 640x440 |
| `Leiste` + `Write_int` | `hud.tscn` + `PixelLabel` (Gigamaze font, DIV alignment codes); layout identical to the original positions |
| main code | `main.tscn` / `main.gd` |
| `Framers` (F1-F5 fps debugging) | skipped (debug only) |

Timing: `Engine.physics_ticks_per_second = 40` and the logic runs once per physics tick, i.e. one DIV frame
(per-tick logic like the original's integer sub-steps). Ship 160 px/s, bullet 320 px/s, laser 280 px/s.
Rendering is at 40 Hz like the original (no physics interpolation).

## Original quirks kept (check them against the original before "fixing")
- Only 14 control points exist in level 500: players 1-4, six diamond places and **four green-laser items (points 11-14)**.
  Players 2 and 4 spawn right on top of items 11/12 and start with the green laser (weapon 1, ammo 10).
- Weapons 2-5 (red laser 5 ammo, stunner, nuke, "Life+50" which gives weapon 5!) are pickups only in the code;
  `Patron` handles only weapon 0 (bullet, 5 damage, +10 score) and 1 (green laser, 10 damage, +20 score). Other
  weapons burn ammo and shoot nothing (the original spawned an invisible harmless process). Rockets, shield and teleporters
  have no pickup code. None of these items exist in level 500 anyway.
- Firing before the first move (heading -1) wastes ammo and shoots nothing.
- Life can go negative; there is no death, no win/lose and no game end - just score (+200 diamond, +10/+20 hits).
- Leaving the maze through the top gap (x 236..390) wraps to y=439, but the bottom gap is only x 232..273, so a ship
  that comes out outside it is stuck inside the bottom wall forever (same for the other gaps: left/right gaps are
  not aligned either). Not fixed.
- Ammo of the active special weapon running out resets to the bullet with 99 ammo.
- Pickups are not respawned.

## Deviations
- Direction keys are handled as input events (last pressed key wins) instead of the original's per-frame priority
  up > right > left > down when several are held.
- Collision of ships with items/diamond uses 14x14 rectangles (original: pixel-exact, ship graphics are almost full squares).
- Export preset has `include_filter="*.bin, *.json"` so the level index map and metadata are in the pck.
- No shield/teleport/stunner implementation (not in the original either).

## Verification
- `godot --headless --path . -- --autotest` (also `--screenshot=<png>`): checks spawn points, wall stop, bullet
  damage/score/ammo, laser damage, ship blocking at distance 14, weapon pickup, diamond, empty-weapon reset. ALL PASS.
- Windowed screenshot checked: level, ships, items, diamond and HUD layout look right.
- Not verified by a human: feel of the movement speed (160 px/s from fps 40), real keyboard play with 4 people,
  web build in a browser.
