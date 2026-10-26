# Huhnshot - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/HUHNSHOT.PRG`, 24 fps, 800x600. Assets: `div_convert.py game` into `assets/` (fpg/huhn, fnt/huhn).
Run: open the folder in Godot 4.7, main scene `scenes/main.tscn`. Web export: `_web/public/huhnshot/`.

## Controls
- Mouse aims (crosshair, OS cursor hidden). Left click = shoot (one shot per click), right click = reload.
- Scroll the panorama: Left/Right arrows (or keypad 4/6), or push the mouse to the left/right screen edge.
- Hold M + G (after the "ALL BONUSES FOUND" bonus) = machine-gun mode (autofire while left button held, free reload at -10 score).
- Game over screen: click (or Enter) to play again.

## Structure
| DIV | Godot |
|---|---|
| GLOBALs | autoload `scripts/game.gd` (`Game`), popup signal |
| main code (setup, 1 s loop, bonuses) | `scenes/main.tscn` + `main.gd` (Timer `SecondTimer`, spawning) |
| scroll + Front | `World` node moved by `-scroll_x0`; Background (z -512) and Front (z_index 50) sprites |
| Bird | `bird.tscn` / `Bird` (group `birds`) - per-tick random-walk flight, size = depth (z_index = size) |
| SpecialItems | `special_item.tscn` / `SpecialItem` (group `specials`): flowers, hills, castle parts with extra "life" hits |
| cursor + Cursordeko | `cursor.tscn` / `Cursor` on its own CanvasLayer: shooting, reload, scrolling, MG mode |
| Munition, write_int, Text/Textb | `hud.tscn` / `Hud` + `PixelLabel` (Huhn bitmap font) + `FloatingText` |
| SCORER | final score screen in the HUD (`Hud.show_game_over`) |
| COMBER | `Main._update_combo_bar` |

Timing: physics tick rate is set to 24 (= DIV fps) with physics interpolation, because the original flight AI, combo bar
and scrolling are per-frame (`Bird` keeps the original tenths-of-pixel integer maths: speeds `size*rand(4,6)/10`,
y speed random walk +-7, clamp +-30, bounds -50..2450 x / -50..650 y). Floating texts rise 1 px / 3 frames for 30 steps.
The 1-second loop (`FRAME(2400)`) is a 1 s Timer.

Hit testing replaces `collision()`: pixel-exact alpha test of the bird / item graphic (scaled, mirrored) at the mouse point.
As in DIV, one click hits at most one bird (the oldest in creation order that overlaps, including falling dead birds)
plus at most one special target. A bird needs 1 hit to fall, then 5 more hits on the falling body for the "dead bird" payout.

## Deviations / guesses
- After time runs out (Time < 0) the original kept the game running and only froze the shown ENDSCORE; this port freezes
  the round and shows score / birds shot / accuracy with a "click to play again" prompt (original had no restart).
- Debug F1-F5 fps keys omitted. The 1x1 pointer graphic (graph 1) is not drawn, only the crosshair (graph 2).
- Scroll is clamped to 0..1600 (original engine stops at the graphic edges).
- Text is drawn in screen space at creation position (like DIV's `x-=scroll.x0`); long banner texts such as the machine-gun hint
  are wider than the screen in the original too.
- Machine-gun autofire: every 3rd tick while M+G+left held (original resets the click lock every 3rd frame).
- Original quirks kept: reloading costs `50+Flowers` score (49 once flowers are done), score never negative, `Maxmunition`
  grows with each bonus (HUD shows at most 16 ammo icons), clock bonus at top-left corner (x<50, y<25) needs a shot with ammo.

## Verified / not verified
- Headless import + 300-frame run clean. `-- --autotest` plays a full round (shoots birds, reloads, destroys all static targets to
  trigger flower/hill/castle/combo/machine-gun states, ends the round) without errors. Windowed screenshot checked visually.
- Web export succeeds. Not play-tested by a human: feel of speeds, edge-scrolling with the real mouse in the browser,
  right-click reload in the browser, balance of bird spawn rate.
