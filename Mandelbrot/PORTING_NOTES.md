# Mandelbrot - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/MANDBROT.PRG` (Olesch), 1024x768, no `set_fps` -> DIV default 18 fps.
Assets: `div_convert.py game` -> `assets/` (palette `pal/mandbrot` from `PAL\MANDBROT.PAL`; maps
`olegs\mandbrot.map` / `olegs\over.map` resolved to `MAP\MANDBROT.MAP` / `MAP\OVER.MAP`).
Run: open the folder in Godot 4.7, main scene `scenes/main.tscn`. Web slug: `mandelbrot`.

## Controls (all keys act every frame while held, like DIV's `key()`)
- F1 draw the whole screen (progressively, column by column from the left).
- F2 quick preview of the centre half (every 5th point as a 3x3 block), F3 preview of the centre third (every 10th point).
- Arrows move the view 100 px, `+` / `-` (the keys right of 0; keypad +/- added) zoom by 1.5x / 2/3 around the
  screen centre. They only change the view; press F1/F2/F3 to redraw.
- W/A/S/D move and 1/Q zoom in/out *and* draw a small preview of the centre sixth.
- F4 clears the screen (stamps `over.map`, a flat picture of palette colour 1).
- 3 / 4 change the variable `malen` (no visible effect, see below).
- H hides/shows the key hint line (new).

The original has no on-screen help and starts with an empty white screen. I added a one-line key hint at the
bottom (Godot default font on a dark strip, CanvasLayer `HintLayer/Hint`), toggled with H.

## How the DIV code maps to Godot
| DIV | Godot |
|---|---|
| GLOBAL `zoom`, `xshi`, `yshi` | `FractalCanvas.zoom / shift_x / shift_y` (ints, 32-bit wrap like DIV) |
| main LOOP reading `key()` once per FRAME | `main.gd` `_physics_process`, physics tick = 18 Hz (one tick = one DIV frame), InputMap actions with physical keycodes |
| background screen + `put_pixel` | `FractalCanvas` (Sprite2D + Image/ImageTexture), palette indices kept in a `PackedByteArray` |
| PROCESS `Draw(x,y,stepp,divisor)` | `FractalCanvas.request_draw(step, divisor)` starts a draw job; `_process` continues it every frame |
| GLOBAL `stop` (only one Draw at a time) | `FractalCanvas.is_drawing()`; requests while drawing are ignored |
| PROCESS `Rechne(rc,ic)` used as a function | `FractalCanvas.point_color()` / `_iterate()` |
| `put(0, over, 512, 384)` | `FractalCanvas.stamp_overlay()` (fills with colour 1) |
| `load_pal("Mandbrot.pal")` | palette read from `assets/pal/mandbrot/palette.json` (listed in the export `include_filter`) |

### Faithful details
- Iteration exactly as `Rechne`: fixed point with 1.0 = `zoom` pixels, start a=b=0, loop while
  `a*a+b*b < 4*zoom*zoom`, `a'=(a*a-b*b)/zoom+rc`, `b'=2*a*b/zoom+ic`, at most 30 iterations, colour = count*8
  (indices 8..240; inside the set = 240, dark navy; palette 0 = white background). `rc = x+xshi`, `ic = y+yshi`
  with x,y the pixel relative to the screen centre. Integer division truncates toward zero as in DIV.
- 32-bit overflow is reproduced: when the view could overflow (zoom >= about 8000 or far shifts, i.e. after holding
  `+` for about a second) the wrapped loop is used and gives the same garbage/blank pictures DIV would. Below that
  bound plain 64-bit math is provably identical and faster (`_is_overflow_free()`).
- Draw order and grids as in `Draw`: columns left to right, each column top to bottom; previews use
  `x = -512/divisor .. <512/divisor step stepp` (same for y with 384) and paint 3x3 blocks, leaving gaps that show
  the old picture. Nothing is cleared before drawing.
- The view globals are read live while a draw runs: moving with the arrows during an F1 draw makes the rest of
  the picture use the new position (as in the original, where Rechne read the globals per pixel).
- Zoom keys also scale the shift so the centre stays put; repeated `-` stops at zoom 2 (2/3 = 0).
- Held keys repeat every frame (18x per second): a long press on `+` zooms 1.5^18 = ~1500x per second.

### Timing / web responsiveness
The original draws 30001 points per DIV frame (`IF(counter>30000) FRAME`). The port allows at most
30001 x 18 points per second (a full picture in about 1.5 s) **and** at most 8 ms of rendering per Godot frame
(`FRAME_BUDGET_USEC`), so a slow browser just draws slower instead of freezing. The real speed of the DOS
original (every `Rechne` call created a DIV process) was certainly slower; unknown.

## Deviations / guesses
- `mandbrot.map` (loaded as the main process' graphic) is entirely colour 0, i.e. fully transparent, so it is
  not shown at all; `over.map` is entirely colour 1, so F4 is implemented as a fill with colour 1.
- `malen` (keys 3/4): kept as `main.gd color_mode`, but the formula that used it is commented out in the
  original (`//farbe=(counter*malen+127*(1-malen))*8;`), so it changes nothing.
- The commented-out old F1 loop and the unreachable second `LOOP FRAME; END` are not ported.
- Added: key hint line + H to toggle it; keypad +/- as extra zoom keys.
- Zoom can wrap around to negative values after holding `+` for ~2.3 s (as in DIV); a wrapped zoom of exactly 0
  (which would be a DIV division-by-zero error) is ignored instead.
- Function keys F1-F4 in a browser: Godot's web build prevents the default browser action for keys it receives
  (F1 help, F3 find); not tested in a real browser.

## Fun facts found while porting
- In preview mode `Draw` calls `Rechne` nine times for the same point (once per pixel of the 3x3 block), always
  getting the same answer.
- The program loads a full-screen 1024x768 picture as its own graphic that is completely transparent.
- "Clear screen" (F4) is done by stamping a second full-screen picture that is one flat colour.

## Verified vs. needs a human play-test
Verified on this machine:
- `godot --headless --import` and `--quit-after 300`: no errors or warnings.
- Autotest `godot --path . -- --autotest [--screenshot=<file.png>] [--shot-view=zoom,xshi,yshi]`
  (`scripts/debug/autotest.gd`) presses the real actions tick by tick: F2, F1 (full draw ~1.5 s), arrows and `+`
  (checks zoom 150 / xshi 300 and no draw), F3, D (checks xshi and preview start), holding 1 for 30 frames
  (overflow path) + F2, holding Q/-/up/left/3 (checks malen = 13), F4 (checks colour 1). Every drawn area is
  checked at 400 random grid points against the formula. Result: PASS, no runtime errors; it writes no files
  (desktop file logging is disabled in project.godot so `user://logs` is not created; the engine still creates the
  empty user data folder).
- Windowed screenshots: default view (small set in the middle of the white screen) and
  `screenshot_gameplay.png` (`--shot-view=337,-200,0`, reachable with + + + and two left presses) look right.
- Web export builds; `index.pck` contains `palette.json`; wasm brotli-compressed.

Not verified: the web build in a real browser (speed of the GDScript renderer in wasm, F-key handling),
key feel at 18 repeats per second.
