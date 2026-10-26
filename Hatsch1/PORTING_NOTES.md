# Hatsch1 - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/HATSCH1.PRG`, set_fps(40), 800x600. Assets converted with `div_convert.py game`.
Run: main scene `scenes/main.tscn`. Web slug `hatsch1`.

## Controls
- Player 1 (top-left start): Left/Right turn, Up thrust, Down = fire (hold to charge, release to shoot).
- Player 2 (bottom-right start): A/D turn, W thrust, S fire.
- Player 3 (bottom-left start): J/L turn, I thrust, K fire.
- Enter: restart the round (new; the original had no end/restart and could only be quit with Ctrl+Esc).
- No Ctrl/Alt keys are used, so no web key remapping was needed.

## Mapping
- Logic runs in `_physics_process` with `physics_ticks_per_second=40` = DIV set_fps(40); one call = one DIV frame,
  so all constants (turn 4 deg, thrust 5 px, shot 10 px, cooldown 5, power = held frames/10 min 2) are unchanged.
  Physics interpolation is on for smooth rendering at the display rate.
- `scripts/ship.gd` (Area2D): process `ship`. `scripts/shot.gd` (Area2D, layer shot, mask ship): process `shot`,
  hit via `area_entered`, ignores its shooter. Shot scale = power*50 %, damage = power. `scripts/explosion.gd`:
  graphics 10..14 at 40 fps, size 50 % on hit, 500 % on ship death. `scripts/main.gd` + `main.tscn`: arena,
  background, life counters (HUD CanvasLayer, `PixelLabel` with the digits-only font in the corners as original).
- Ship collision shape = full 30x40 graphic rectangle (approximation of DIV's pixel overlap).

## Deviations / original bugs
- Original: ship 3 was created with `player=2`, so it started at (700,500) exactly on top of ship 2. Fixed: it starts
  at (100,500) (the evidently intended player 3 slot); counter stays bottom-right as in the original. It uses
  ship graphic 2 (as in the original; graphic 3 would have been the background).
- Kept: no game end, ships wrap with strict `<0`/`>800` comparisons, recoil can push a ship through the wrap.
- Shot spawns one tick later than in DIV (first move happens next tick instead of immediately).
- Debug-only `Framers` process (F1-F5 fps changes) and the commented-out CLONE code are not ported.
- Dead ship's counter shows 0 (DIV read the dead process' stale variable, which also ended at 0).

## Verified
- Headless import and run clean; `-- --autotest` (with `--fixed-fps 40`) checks damage, a direct shot hit (-3 life),
  ship death and removal, windowed screenshot looks right.
- Needs a human play-test: feel of charge timing and ship speed, shot collision vs the original pixel overlap.
