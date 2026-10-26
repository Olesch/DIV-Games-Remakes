# Brief for porting one DIV game to Godot

You rewrite one of Olesch's old DIV Game Studio games as an idiomatic Godot 4.7 game
(GDScript). The reference port is **D:\Prog\Godot\DivRemake\Microcosm\** — look at its
structure, project.godot, export_presets.cfg and PORTING_NOTES.md before you start, and
follow the same patterns.

## Read first
- `_shared\DIV_PORTING_GUIDE.md` — how to read DIV code, units/timing, Godot structure rules, checklist.
- `_shared\GAMES_INDEX.md` (your game's row) and `_shared\DIV_HELP_REFERENCE.md` for DIV built-ins.
- Your game's source in `DIV\PRG\Olegs\` — read ALL of it before designing.
- Do not modify anything under `DIV\` or `_shared\`, or other games' folders.

## Rules
- **Rewrite, don't emulate.** No DIV-style process/FRAME framework, no line-by-line translation.
  Typical Godot: one scene + typed script per entity, an autoload for global state, signals,
  groups, collision shapes and physics layers (or a tile/bitmap lookup where the original tests
  pixel colours), Timers/tweens, InputMap actions, delta-based movement with speeds converted
  per-frame → per-second (DIV value × the game's set_fps). English identifiers, German original
  in a comment where useful.
- **No frame-coroutines or key polling.** Do not write `while ...: await <tick signal>` loops,
  a global "tick" signal standing in for DIV's FRAME, or `_wait_pressed`/`_wait_ticks` helpers.
  Screens/menus are separate scenes or a small state machine; input arrives through
  `_unhandled_input` / InputMap actions (`echo` for key repeat); movement in `_process(delta)` or
  tweens; delays with Timers / `get_tree().create_timer()`. A fixed physics tick rate is fine where
  gameplay depends on frame counts, but the code must still read like normal Godot code.
- **Faithful gameplay:** same rules, constants, costs, spawn rates, AI, levels, menus, scoring,
  win/lose. Hiscores/saves → `user://`.
- **Assets:** convert with `python D:\Prog\Godot\DivRemake\_shared\tools\div_convert.py game <PRG> <project>\assets`
  (see the guide). Sprites use control-point offsets; text uses the converted bitmap fonts.
- **Display:** viewport size = the game's set_mode resolution, `window/stretch/mode="viewport"`,
  `window/stretch/aspect="keep"`, nearest filtering, `gl_compatibility` renderer.
- With `physics/common/physics_interpolation` on, call `reset_physics_interpolation()` after every discontinuous jump
  (placing a node after `add_child`/in `_ready`, screen wrap, respawn, teleport, flipping via negative scale), or the
  jump is drawn as a slide across the screen.
- Skip debug-only features (F-key fps changes, test modes); list them in your notes.
- Unfinished originals: port what works, keep it playable, document what the original lacked.

## Web export (the game goes on olesch-div-games.pages.dev)
Add `export_presets.cfg` copied from Microcosm's, changing only:
- `export_path="../_web/public/<slug>/index.html"` (`<slug>` = lowercase game name, e.g. `castle`)
- `html/head_include="<script src=\"../scale-switch.js?w=<W>&h=<H>\"></script>"` with your viewport size
- keep `html/canvas_resize_policy=0` and `variant/thread_support=false`. Do not add scaling code to the game; the page does it.
Run `godot --headless --path <project> --export-release "Web"` once at the end to check it exports,
then `brotli -f -q 11 -o index.wasm.br index.wasm` and delete `index.wasm` in that output folder.
Browsers never pass Ctrl+W/T/N (and Ctrl+Shift+W/T/N/Q) to the page: if a held Ctrl key can meet
those letters (e.g. one player fires with Ctrl and another uses W), give the web build a different key
via `OS.has_feature("web")` and note it.
Raw data files read with `FileAccess` (`.bin`, `.idx`, `.dat`, …) are not Godot resources and are left out of
the export unless the preset's `include_filter` lists them; check the `.pck` contains them.
Only write inside `_web\public\<slug>\`. **Do not deploy** and do not edit `_web\public\index.html`.

## Verify
- `godot --headless --path <project> --import`, then run the main scene with `--quit-after N`; fix all errors/warnings that matter.
- Add a debug autotest (like Microcosm's `scripts/debug/autotest.gd`, triggered by `-- --autotest`) that exercises the main gameplay headlessly and reports runtime errors.
- Take a windowed gameplay screenshot (like Microcosm's `--screenshot=<path>`) and look at it with your Read tool; iterate until visuals are right. Save the best one as `<project>\screenshot_gameplay.png` (it goes on the website).
- Write `<project>\PORTING_NOTES.md`: controls, how mechanics map to the new structure, deviations/guesses, original bugs kept, what's verified vs. needs a human play-test.

## Final reply
Concise: what was built, verification results (honest about anything unverified or broken),
controls in one line, a one-sentence game description for the website, open questions.
