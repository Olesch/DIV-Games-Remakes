# Fort - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/FORTKEEP.PRG` (166 lines), 24 fps, 800x600. Assets: `div_convert.py game` -> `assets/fpg/fortkeep`, `assets/fnt/system`.
Main scene: `scenes/main.tscn`.

## Controls
- Mouse: a crosshair follows the pointer; left click fires one shot from the fort towards it (one shot per click, like the original's anti-fast-click flag).
- No quit key (the original had none; the web build must never call `quit()`).

## Mapping
| DIV | Godot |
|---|---|
| main loop `Enemy(NORMAL); Enemy(ZIGZAG); FRAME(1000)` | `main.gd` + `SpawnTimer` (100/24 s ~ 4.17 s; original 10/24 s, see Deviations), one wave immediately at start |
| Festung | `fort.tscn`/`fort.gd` (Area2D, elliptical shape 100x80); each touching enemy = `damage++` and the enemy is destroyed |
| Cursor | `Cursor` Sprite2D on its own CanvasLayer, OS pointer hidden |
| Schuss | `shot.tscn` (Area2D, 16 px/frame x 24 = 384 px/s), dies on first enemy hit or when leaving the screen |
| Enemy | `enemy.tscn` (Area2D, `kind` NORMAL/ZIGZAG), 6 px/frame x 24 = 144 px/s, dies on its 2nd hit |
| GLOBAL FESTUNG_ID, Festung.damage | autoload `Game` (`damage`, `damage_changed`) |

Spawn edge: each of left/right/top/bottom with probability 1/4, 20 px outside the screen. NORMAL enemies aim at the fort every frame and have `size = distance/3 %` (they shrink as they approach). ZIGZAG enemies start flying to the right (angle 0, an original quirk, kept) and re-aim at the fort +-30 degrees whenever their counter (+rand(0,2) per frame) exceeds 70. Shots and enemies are Area2Ds on physics layers `enemy`/`shot`/`fort`, polled in `_physics_process`.

## Deviations
- **Owner decision 2026-10-26: 10x fewer enemies.** The original spawns one NORMAL + one ZIGZAG enemy every 10 frames (`FRAME(1000)`, 10/24 s); the owner considers that a leftover from experimenting, so `SPAWN_INTERVAL` is now 100/24 s (~4.17 s). This is the only spawn path (no waves/difficulty in the original). Enemy speed, hits and everything else unchanged. Measured over 60 s at 60 fps: 144 waves (288 enemies) before, 15 waves (30 enemies) after.
- Added a small "Schaden: N" counter (system font, top left): the original only counted damage in an invisible variable, so nothing on screen reacted to hits. There is still no game over.
- Pixel-exact `collision()` replaced by circle / ellipse shapes (enemy radius 17 scaled by size, shot radius 4).
- Zigzag counter uses a per-second random increment (mean 1 frame^-1) instead of a literal per-frame loop; the shot/enemy motion is delta-based, not per-tick.
- Enemies that fly off screen (zig-zag ones heading away at the start) are not removed, as in the original; they turn back toward the fort later.

## Verification
- `--import` and runs clean (no script errors/warnings). `-- --autotest` fires at random enemies for 10 s, reports shots/kills/fort damage and fails (push_error) if there are no kills or no damage. It writes nothing to `user://` (the game has no saves/hiscores). It quits only when not on web.
- Screenshot: `screenshot_gameplay.png`. Web export checked (`../_web/public/fort/`, wasm brotli-compressed). Not deployed.
- Needs a human play-test: feel of enemy speed and shot speed relative to the original at 24 fps.
