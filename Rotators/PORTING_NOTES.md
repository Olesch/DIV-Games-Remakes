# Rotators (Dreher) - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/SPACE2.PRG` (`PROGRAM Tutorial_1`; the header still credits Antonio Marchal's DIV
tutorial it was built from), 100 fps, 1024x768. Graphic: `Schluessel.map` -> `MAP\SCHLUESS.MAP` (a 100x25
"key"/bone with control point 0 at the left knob (12,12) and point 1 at the right knob (87,12)).
Assets converted with `div_convert.py game` into `assets/` (map/schluess, fnt/system).
Web slug: `rotators`. Main scene `scenes/main.tscn`.

## What the original does
A chain of 22 spinning keys hangs from the screen centre: the first one (Dreher1) rotates around its left
knob at (512,384); each next one (20 x Dreher2, then one Dreher3) is fastened to the right knob of the
previous one and spins faster (5, 6, 7 ... 26 degrees per frame at size 50%). Every frame each key leaves a
white pixel (palette colour 15) where its right knob is, on the background, which is never cleared. There is
no input at all in the original (the keyboard camera code is commented out).

## Controls
TAB/O/F1 options, SPACE/P pause, C/Backspace clear trails, R restart, N randomise, 0 original settings,
H hide the on-screen text, ESC close options (desktop: quit when options are closed; never quits on web).
Options overlay: Up/Down select, Left/Right change, Enter/Space activate; mouse: click the < > arrows and
the buttons (hovering selects a row).

## Options (all original values are the defaults; "Original" restores them)
| Option | Original | Notes |
|---|---|---|
| Speed mode | Counted (DIV `Mode=2`) | Random = `Mode 0` (first key +/-2.5, others +/-4.5 deg/frame), Table = `Mode 1` (`Speeds[]` table, see quirks) |
| Rotators | 22 (`Howmuch_counts=20` + first + last) | 2..64 |
| First speed | 5.00 deg/frame (`Dreher1(...,5000)`) | Counted mode only |
| Speed step | +1.00 deg/frame (`Rotsp+1000`) | Counted mode only |
| Random range | +/-4.5 deg/frame (`Rand(4500,-4500)`) | Random mode only; first key gets 5/9 of it like the original 2500/4500 |
| Size | 50 % (`Size_ins`) | also the arm length (75 px x size) |
| Trails | All rotators (`Modeb=0`) | Last only = `Modeb=1` (Dreher3 ignores Modeb); Off is new |
| Trail colour | White (colour 15) | Rainbow / Greys are new |
| Show rotators | Yes | new |
| Frames/second | 100 (`set_fps(100,0)`) | sets `Engine.physics_ticks_per_second` |
Changing a structural option restarts the pattern; trails/colour/visibility/fps apply live. Options are kept
in `user://rotators.cfg` (never written while `--autotest` runs).

## How it maps to Godot
| DIV | Godot |
|---|---|
| GLOBAL section (Mode, Modeb, Speeds, Howmuch_counts, Size_ins) | autoload `scripts/options.gd` (`Options`): values, defaults, ranges, randomise/reset, speed per rotator, InputMap |
| Dreher1 / Dreher2 / Dreher3 | one scene `scenes/rotator.tscn` + `scripts/rotator.gd` (`Rotator`, `kind` enum FIRST/MIDDLE/LAST) |
| `get_real_point(1, ...)` | child `Marker2D` "Tip" at point1 - cp0 = (75,0); its global position, rounded to whole pixels |
| `father.pa_x` | `leader.tip` |
| priority-1 per generation | each successor is a child node (`top_level`), so tree order runs a key after the one it hangs on |
| creating the next process at start | the successor is instantiated in `_ready`, and every rotator does its first step in `_ready` after its successors (DIV runs a new process before its creator continues) |
| `put_pixel` on the background | `scripts/trail_canvas.gd` (`TrailCanvas`): a 1024x768 `Image` + `ImageTexture`, updated once per rendered frame |
| main code | `scenes/main.tscn` + `scripts/main.gd` (builds the chain, HUD, options overlay `scenes/options_panel.tscn`) |
Timing: the pattern is a set of discrete dots per frame, so the logic is per tick: physics runs at 100 ticks/s
and one `_physics_process` call is one DIV frame (angles in thousandths of a degree, integer pixel tips).

## Original behaviour kept on purpose
- **One-frame lag in the middle keys:** Dreher2 reads its knob position *before* moving to its leader's knob,
  Dreher3 after. So each middle key's dot comes from last frame's position - part of the pattern.
- **Start-up splash in the top-left corner:** at creation the successors run first, while every leader's knob
  is still (0,0), so the first frames leave a few dots near the top-left corner that sweep towards the centre.
- **Table mode overrun:** `Speeds[12]` has 13 entries but the pointer counts up to 21, so keys 13-21 read the
  following globals: Howmuch_counts (20), Size_ins (50), Speed_Pointer (15), Howmuch (15), score, speed (0),
  Schl (1000 = map code), then memory behind the globals (assumed 0). Those keys barely move.

## Guesses / deviations
- `get_real_point` rounding: positions rounded to the nearest pixel (DIV returns integers; its exact rounding is unknown).
- Value at memory behind the last global (table mode, keys 20+) assumed 0.
- Unused leftovers of the tutorial (`new_coordinates` process with 640x480 wrap values, `score`, `speed`,
  commented-out camera keys) are not ported. The "640x480" comment on `set_mode(m1024x768)` is wrong in the original.
- All options, the HUD text and the keys are new (the original had no input).

## Verification
- `--import`, `--quit-after 300`: clean.
- `godot --headless --path . -- --autotest`: checks 22 rotators, trail dots, the options overlay via simulated
  keys (Tab, Up/Down, Left/Right, Esc), table speeds, every trail mode, chain length 0, randomise, reset -> OK.
  `user://` stays empty (file logging is disabled in project.godot).
- Windowed screenshot (`-- --autotest --screenshot=<png>`, 8 s of the original pattern) = `screenshot_gameplay.png`;
  the options overlay and a rainbow custom pattern were checked visually too.
- Web export to `../_web/public/rotators/` succeeds (wasm brotli-compressed). Not run in a browser.
- Needs a human look: whether the original on DOSBox looked the same (100 fps may have run slower there).
