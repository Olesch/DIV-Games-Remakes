# Kochkurve - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/KOCHKURV.PRG` (Oleg Yuschuk), 1024x768, no `set_fps` (irrelevant: nothing moves).
Assets: `div_convert.py game` -> `assets/` (map/mandbrot, map/over, fnt/system). Main scene `scenes/main.tscn`.
Web slug `kochkurve` (export to `../_web/public/kochkurve/`, scale-switch 1024x768).

## Controls
- `1` or `F1`: draw the Sierpinski triangle.
- `2` or `F2`: meant to draw a Koch curve - draws the same Sierpinski triangle (original behaviour, see below).
- After one drawing every key is ignored; reload the page / restart to draw again (original behaviour).

The original already shows its keys on screen (`1 - Sierpinski`, `2 - Koch`, system font, top-left),
so no extra hint line was added.

## Structure
| DIV | Godot |
|---|---|
| main code (menu texts, key checks, start triangle) | `scripts/main.gd` on `scenes/main.tscn`; InputMap actions `draw_sierpinski` / `draw_koch` (physical keys), `_unhandled_input` |
| background screen + `put_pixel` | `scripts/pixel_canvas.gd` (`PixelCanvas`, Sprite2D showing a 1024x768 Image; texture updated once per frame) |
| `PROCESS Draw_Line` (Oleg's own Bresenham) | `PixelCanvas.draw_line_div()`, step for step identical (counter starts at half the major axis) |
| `PROCESS Sirpienski` (recursive) | `scripts/sierpinski.gd`, static recursive functions with `Vector2i` integer midpoints (same truncation) |
| `write(0,...)` | `scripts/pixel_label.gd` (system bitmap font at 1:1, copied from the Rubik port) on a CanvasLayer above the drawing |

Timing: none of the drawing processes executes `FRAME`, so in DIV the whole figure (1 + 3 + ... + 3^6 = 1093
recursion steps, about 3300 line processes) is finished inside a single frame. The port also draws it
instantly in one call - there is no draw-over-time animation in the original.

Colour: every line uses palette index 15 of MANDBROT.MAP = white (255,255,255); background palette 0 = black.

## Original quirks kept / deviations
- Key 2 runs the exact same code as key 1 (copy-pasted block calls `Sirpienski`). `PROCESS Koch` is
  unfinished: it computes two of the four points (the second one twice), never recurses and draws nothing,
  so it is not ported.
- After drawing, the main code enters `LOOP FRAME; END` forever: no second drawing, no clear. Kept.
- `graph=load_map("olegs\mandbrot.map")` is shown at the screen centre, but that 1024x768 map is entirely
  colour 0 (transparent), so it is invisible - not instantiated in the port. `over.map` (a flat dark grey
  1024x768 map) is loaded but never used - not used either. Both are excluded from the web export
  (`exclude_filter` `assets/map/*`); the converted files stay in `assets/` for reference.
- The unused alternative line routine `Draw_lineb` (slope/intercept version, never called) is not ported.
- `Draw_Line` would loop forever on a zero-length line; that never happens here, the port draws one pixel.
- No quit key in the original (DOS Ctrl+Esc); none added. The port never calls `quit()` except in the
  desktop autotest.
- `project.godot` disables Godot's file logging so test runs do not leave logs in `user://`.

## Verification
- `--import`, `--quit-after 120`: clean, no errors/warnings.
- `-- --autotest` (headless): checks the line routine (pixel count, end points, zero-length guard), sends
  the `draw_koch` action, verifies 30925 lit pixels and the triangle corners/edge, verifies a second key press
  changes nothing; 0 failures. Writes nothing to `user://` (screenshot only with an explicit `--screenshot=<path>`).
- Windowed screenshot `screenshot_gameplay.png` checked visually (white depth-7 Sierpinski triangle, menu texts).
- Web export builds (`index.wasm` brotli-compressed to `index.wasm.br`), not tested in a browser.
- Needs a human check: real keyboard input in the browser (trivial).
