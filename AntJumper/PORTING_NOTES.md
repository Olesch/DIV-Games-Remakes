# AntJumper - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/ANT.PRG` (Olesch), DIV default 18 fps (no `set_fps`), 1024x768.
Assets: `div_convert.py game` -> `assets/fpg/ant` (one graphic, 1024x768) and `assets/fnt/system` (UI font).
Main scene `scenes/main.tscn`. Web slug `antjumper`.

## Controls
- WASD / arrow keys / drag with the left mouse button: move the picture (DIV: W = y+5 etc., so W looks up).
- Alt (original), E, PgUp, +, mouse wheel: zoom in. Ctrl (original, desktop only), Q, PgDn, -: zoom out.
  Home: reset view.
- Space: pause. R: restart. O or Esc: options overlay. H: hide the bar with controls/status at the bottom.

## What the original does (read carefully - it is not classic Langton's ant)
The main process shows graphic 1 of `Ant.fpg` at (512,384) and starts one `Ant(512,384,0)`. Each ant
step: move one pixel in `Dir`, read the pixel colour, `state = Anticolour[colour]`, `Dir += KI[state]`,
paint `Colour[(state+1) mod 3]`. After 3001 steps (`counter>3000`) it does one `FRAME`.

The tables as written: `KI[2]=0,1` -> KI = 0,1,0; `Colour[2]=0,15` -> 0,15,0; `Anticolour[15]=0,1`
-> only colour 1 maps to state 1, everything else (including the white 15 the ant paints) to state 0.
So on black the ant goes **straight**, paints white, and white also reads as "black". And graphic 1 of
Ant.fpg is completely colour 0. Result: in its first frame the ant draws a 384-pixel white line straight
up from the centre to the top edge and walks off the picture forever. The comments in the PRG
(`-1< 0^ 1>`, the commented-out Anticolour row) show a real turmite was intended.

## Owner's decision 2026-10-26: default = the original with the slip fixed (Langton's ant)
Fixing only the colour-table slip (`Anticolour[15]=1` instead of `Anticolour[1]=1`, so the white the
ant paints reads as state 1) is **not enough**: `KI[0]=0` still means "straight on black", and on the
all-black picture the ant never meets white in front of it, so it draws the very same line. The port
therefore also corrects `KI[0]`: `KI = 1,-1` (right on black, left on white). Those corrected tables
(`AntRule.original_fixed()`) are exactly the rule string "RL" with colours 0/15, which is now the default
(`Settings.DEFAULT_RULE`); the autotest checks the two are identical. Everything else stays original:
picture, start (512,384) facing up, step order (move, read, turn, paint), 3001 steps per frame, keys,
black/white. Result: ~10000 steps of chaos round the centre, then the diagonal "highway" runs off to the
lower left (visible within the first seconds at 100%).
The uncorrected tables stay selectable as the last rule preset, "Original's bug - straight line" (cheap:
they were already implemented and tested; the autotest still checks the 384-px line).

## Options (new, owner's request; defaults = original, except the rule: RL, see above)
Overlay panel (`OptionsPanel`), keyboard (Tab/arrows/Enter) and mouse; values in autoload `Settings`
(not saved to disk):
- Rule: presets **RL (Langton's ant, default)**, RLR, LLRR, LRRRRRLLR, LLRRRLRLRLLR, RRLLLRLLLRRR,
  RRLRLLRLRR, "Original's bug - straight line" (the unfixed tables above), or a custom string
  (1-16 letters L/R/S/U).
  Letter n = turn on colour n, the ant paints colour n+1 (mod length) - the same table scheme as the PRG.
  Colours: 0 black, 15 white (as the original), then bright DIV default-palette colours.
- Steps per frame per ant: 1, 10, 100, 1000, **3001**, 10000, 30000.
- Ants: 1-9. Ants 2-5 start at the positions of the commented-out `Ant(...)` calls, using their last
  value as the direction (in the PRG it is the `priority` parameter, so they would all have faced up);
  6-9 on the diagonals.
- Start canvas: the start picture (original) or random dots (5% of pixels in colours the rule reacts to;
  for the original's-bug tables that is colour 1, so you can see its "turn right" case).
- Edges: off the picture (original: the ant reads black and paints nothing) or wrap around.
- Restart / Defaults / Close buttons. Rule, ant count and canvas restart the run; speed and edges are live.

## Structure
| DIV | Godot |
|---|---|
| main code (graph=1, x, y, size, key loop) | `main.gd` on `Main` (Node2D): moves/scales the `AntCanvas` sprite, input via InputMap actions, restart |
| graphic 1 + map_get_pixel/map_put_pixel | `ant_canvas.gd` (`AntCanvas`, Sprite2D): palette indices in a `PackedByteArray` (from `indices.bin`), uploaded as an R8 texture once per frame; `shaders/palette.gdshader` maps indices to the palette, index 0 transparent |
| PROCESS Ant | `ant.tscn` / `ant.gd` (`Ant`, Node, invisible): cell + direction; each physics tick calls `AntCanvas.run_ant(self, steps)` (the loop lives in the canvas so the pixel array is edited in place) |
| KI / Colour / Anticolour | `ant_rule.gd` (`AntRule`): `turns`, `colours`, `state_of_colour`, `paint` |
| hard-coded values | autoload `settings.gd` (`Settings`) + `options_panel.gd` |
| (none) | `hud.gd`: status + controls bar |

Timing: per-tick logic. `physics_ticks_per_second = 18` (DIV default fps); one physics tick = one DIV frame
= 3001 steps per ant. Pan 5 px/frame -> 90 px/s, zoom 10 %/frame -> 180 %/s, delta based in `_process`.
Pause disables the `Ants` node.

## Deviations
- Zoom is clamped to 10..3200% (DIV let `size` reach 0 and negative: the picture vanished).
- Web build: Ctrl is not a zoom key (Ctrl+W would close the browser tab); Q/PgDn/- zoom out. Alt still
  zooms in on the web (Alt+letter browser shortcuts might interfere in some browsers - not seen in Chrome test).
- Added mouse drag/wheel, Home, pause, restart, options, the HUD bar (H hides it).
- Off-picture reads return colour 0 (assumed DIV behaviour of `map_get_pixel` outside the graphic;
  in the original the ant would otherwise have crashed or read garbage - unverified).
- Colours above 15 would index past `Anticolour[15]` in DIV (no bounds check); unreachable with the shipped
  picture, mapped to state 0 here.
- Heavy settings (9 ants x 30000 steps) exceed what GDScript does in 1/18 s; the simulation then runs slower
  than "per frame" (measured ~1.7 M steps/s headless).

## Verification
- `--import`, `--quit-after 300` headless: clean.
- `godot --headless --path . -- --autotest`: PASS (default is RL and paints a Langton pattern; fixed
  ANT.PRG tables == RL; original's-bug line = 384 white px at x=512, y 0..383, ant off the top; tables;
  RL first step and 11000 steps; pause; 9 ants + LLRR + random dots + wrap; pan; zoom; Home; defaults).
  `--screenshot=<abs path> [--shot-rule=LLRR --shot-ants=1 | --shot-default] [--shot-options]` saves a PNG
  (`--shot-default`: the untouched default run after 6 s).
- 2026-10-26 (RL default): `--import`, `--quit-after 300` clean, autotest PASS; windowed `--shot-default`
  screenshot shows the Langton blob at the centre and the diagonal highway to the lower left; with
  `--shot-options` the panel shows "RL - Langton's ant (default)". Web build not re-exported.
  Writes nothing to `user://` (file logging and shader cache disabled; the engine may still create empty
  folders).
- `screenshot_gameplay.png`: rule LLRR, 1 ant, 300% zoom (taken before RL became the default; still a valid option shot).
- Web export built and tested locally in a browser: runs, options popup works by keyboard, RL renders
  (palette shader on WebGL2 OK), no console errors. Mouse clicks in the browser pane could not be
  tested reliably (tool coordinate issue), needs a human check.
- Needs a human play-test: feel of zoom/pan speeds, options panel mouse use, Alt on web.
