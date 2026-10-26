# Stranded - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/STRANDED.PRG` (Oleg Yuschuk), 24 fps, 800x600. German in-game texts kept.
Run: open the folder in Godot 4.7, main scene `scenes/main.tscn`.

## Controls (physical key positions, as in the original)
- Walk: **S** up, **X** down, **Z** left, **C** right (hold to keep walking; one cell = 5 frames).
- **D** search the cell you stand on (takes ~4 s, you cannot move meanwhile), **F** take/pick up/drink,
  **A** sleep (only late in the day, otherwise "Zu Frueh!").
- **V / B / G** choose the action mode: Essen (eat), Benutzen (use), Kombinieren (combine) - the `-->` arrow shows it.
- Number keys 1-9 = inventory items. Eat mode: 1 grain (+4 hunger), 2 berries, 7 herb, 8 flour, 9 dough.
  Use mode: 1 sow grain on empty grass, 8 flour -> dough while standing on a spring.
  Combine mode (press two/three keys together): 1+4 = flour (3 grain + stone), 3+4 hammer, 3+6 fishing rod, 3+4+6 axe.
- Esc does nothing (the original had no menu; quit the window).

## Mapping DIV -> Godot
| DIV | Godot |
|---|---|
| GLOBAL variables, eat/plant/combine/search/take rules, hunger/thirst/health/sun timers | autoload `scripts/game.gd` (`Game`) with signals; counters are `Timer`s (hunger every 121 frames, thirst 61, health 73, sun step 12 frames) |
| `Held` process | `scenes/hero.tscn` + `hero.gd`: walks cell by cell in `_process` at 96 px/s, input via `_unhandled_input` (held walk keys tracked from press/release events), `Camera2D` child with limits 0..5000 = the scroll window |
| `Begehbar`, `OpenCard`, `Draw_all`, `Refresh_all`, maps 101/103/104 | `scripts/island.gd` (`Island`, RefCounted): field map, object map, fog map as byte arrays; generates the island exactly like Draw_all (18001 random placements, same odds) |
| big 5000x5000 ground graphic painted with `map_put` | three `TileMapLayer`s in `world.tscn` (ground, object, overlay), tiles from the 20x20 FPG graphics |
| scroll background graphic 55 + `WaterMove` | `water.gd` on a CanvasLayer behind the world: tiled water texture drifting 24 px/s right, 12 px/s down |
| `HeldSucht` / `HeldNimmt` / `Schreiben` | `Game.search_result()` (2 x 49 frame `Timer`, aborted at night), `Game.take()`, `Game.say()` -> HUD popup shown 96 frames |
| `ShowItems`, bars, radar, sun | `hud.tscn` + `hud.gd` (CanvasLayer): `PixelLabel` rows (system bitmap font), bar sprites slide in from the left like the original (`x = value - 100`), radar = `ImageTexture` rebuilt per changed cell, sun sprite moves along the radar header |
| `TimeSun` night, `Fade_Off/Fade_On`, `NachtStop` | `Game._begin_night()` (health loss 25+-5, 15+-5 under a tree, input blocked) + `fader.tscn` tween: fade out, `Island.refresh_all()`, 30 frames black, fade in |
| AntiFastClick | `_locked` in `hero.gd`: one action per key press, released when F/A/1-9 are all up |

Only the graphics the game uses were converted (23 tiles/sprites + system font + the field map as `assets/data/fieldmap.bin`);
the 5000x5000 ground graphic (100) and the 250x250 object/fog maps (103/104, which are empty/solid colour at start)
are not shipped. Web export is about 7 MB (almost all wasm).

## Deviations / guesses
- **Hero marker on the radar:** in the original `PunktM` has no graphic (and uses `Held_id.x` for y), so no hero dot was visible.
  I draw a 3x3 red dot at the hero's cell so the radar is usable.
- Water background: `Scroll[0].ratio=400` has no effect in the original (the background only moves through `WaterMove`
  because the view is set manually), so the water is screen-fixed and just drifts.
- Fade length (about 8 frames each way) is a guess; the black pause is FRAME(3000) = 30 frames.
- Combination keys: DIV polled the keys each frame; here a key press starts a one-frame wait, then all held 1-7 keys
  are evaluated, so pressing the keys together works.
- Walking: the original could chain a second direction inside the same frame; here a new step starts the frame after one ends.
- Radar overlay layering of two sprites per cell (picked berries over bush etc.) is approximated with two overlay layers.
- Debug-only: none in the original apart from the commented-out `cursor` process (not ported).

## Original bugs / unfinished features kept
- Health below 0 only swaps the hero sprite to the "Dead" graphic and clamps to 0: there is no game over, you keep playing.
- The sun reaching the right edge costs health every day whether or not you slept; sleeping just skips the remaining day.
- Keys H (axe), N (rod) and J (build with the hammer) are listed once made but do nothing; the original never finished
  fishing, chopping or building. Those lines still appear in the right-hand list when the tool is crafted.
- Hammer/rod/axe can only be made once; 'Teig Hergestellt' message only appears the first time.
- A search/take on a decoration tile (graphic 65) says nothing found, decoration has no object entry.
- The starting cell is not uncovered on the radar until the hero moves (OpenCard is only called after a step).

## Verified vs. needs a human play-test
Verified: `godot --headless --import` and a 300-frame headless run are clean (no errors/warnings); web export succeeds
(wasm brotli-compressed, `.pck` contains the data files); `scripts/debug/autotest.gd`
(`godot --path . -- --autotest [--screenshot=f.png]`, `--tour` just walks) drives real input events: walking, standing on a
spring, flour->dough, taking grain, combining flour and axe, eating, sowing, searching, sleeping too early/late, night
fade and refresh, death at 0 health - all assertions pass with no runtime errors. Windowed screenshots checked visually.

Needs a human: the feel of the walking/key handling, night fade timing, balance of the stat timers (converted from 24 fps frame
counts), and whether the island generation looks like the original.
