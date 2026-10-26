# Lommings - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/LOMMINGS.PRG` (Oleg Yuschuk, Lemmings clone), 24 fps, 320x240.
Assets: `div_convert.py game` into `assets/` (fpg/lommings, fnt/lommings, fnt/system).
Run: open the folder in Godot 4.7, main scene `scenes/level_select.tscn` (the game itself is `scenes/main.tscn`).
Web export slug: `lommings`.

## Level select (owner's decision 2026-10-26)
- New start screen `scenes/level_select.tscn` + `scripts/level_select.gd`: the 13 levels of `AvailableLevels[]` in two
  columns, each shown as its graphic code and its graphic name in LOMMINGS.FPG (the only names the original has):
  900 Level1, 901 Level2, 902 Level3, 903 Level4, 904 Level5, 905 Level6, 906 Level7, 907 Level8, 908 Level9,
  909 Level10, 910 Level11, 920 Level21, 950 Level51. Below: a 1/4 size preview of the level graphic and the numbers the
  panel will show (Lommings / To save / Time).
- Up/Down (Left/Right jumps between the columns) or hovering with the mouse chooses, Enter/Space or a left click plays.
  The first entry (level 900) is highlighted at start, so Enter right away plays exactly like the original's start.
- Playing continues from the chosen level through `AvailableLevels[]` as in the original (win -> next entry, fail ->
  same level; after 950 the "BYE! YOUR LEVEL: 13" screen). Starting from the list resets skill selection, turbo and pause.
- `Esc` in the game (also on the end screen, as do Enter/click) goes back to the list, which then highlights the level
  that was being played. No passwords. Original font (DIV font 1 for the title and the list, system font for the help).
- The kept quirks are unchanged (nuke counting saved lemmings, reversed +/- emerge keys, stopper removal cost).

## Controls
- Mouse: pointer; the lemming within 8 px of the pointer is the target (pointer turns to the open hand).
- Select a skill with keys `1`..`9` (or click its icon on the panel - new), then **left click** a lemming:
  1 climb, 2 umbrella, 3 jump (will jump instead of falling), 4 explode (5 s countdown), 5 build ladder,
  6 stopper (left click on a stopper releases it), 7 dig forward, 8 dig diagonal, 9 dig down.
  **Right click**: with 3 jump right now, with 6 turn the lemming around. Holding the button keeps applying
  (climb/umbrella/jump/explode to everything under the pointer; ladder/stopper/dig once per click).
- Left/Right arrows scroll the 640 px wide level (4 px per frame). `+`/`-` (keypad too) change the emerge interval
  (`+` = slower), `Backspace` = nuke (lemmings explode one after another, emerging every 5 frames),
  `O` = turbo (5 steps per frame), `P` = pause.
- Panel clicks (new): the turbo ">>", pause, `-`, `+` (steps of 5) and BACK (nuke) icons on the right of the panel.
- Win a level when MORE than "to save" lemmings (the number shown on the panel) reach the exit before time runs out
  or all lemmings are gone. Failing restarts the level. After level 950 the game says "BYE! YOUR LEVEL: 13"
  (the original exited); click/Enter/Space/Esc returns to the level select.
- `Esc`: back to the level select (new).

## How the DIV code maps to Godot
| DIV | Godot |
|---|---|
| GLOBAL vars (skill counts, time, saved, ...) | autoload `scripts/game.gd` (`Game`), `stats_changed` signal |
| main code (level loop, win/lose, levels 900..950) | `scenes/main.tscn` + `scripts/level.gd` (`Level`) |
| `STRUCT Lomming[99]` + big `SWITCH` in process Lomminger | `scenes/lemming.tscn` + `scripts/lemming.gd`, `enum State` + `step` (animation phase) |
| graphic 2 "Level Now" (map_get_pixel / map_put) | `scripts/terrain.gd`: `Image` + `ImageTexture` + air-flag byte array |
| graphic 1 "Playfield" (lemmings drawn with map_xput each frame) | each lemming is a `Sprite2D` over the terrain sprite (same look, no re-blitting) |
| Shower (scroll) / Items (panel) / Cursor | `World` node x offset / `Panel` sprite / `scripts/cursor.gd` + the picking code in `level.gd` |
| write_int texts | `scripts/hud.gd` with `PixelLabel` (bitmap font), updated on `stats_changed` |
| level parameters | the first 14 pixels of each level graphic's row 0 (palette indices) were read once from `indices.bin` and baked into `Defs.LEVELS` together with control points 1 (entrance) / 2 (exit) |

Timing: the logic is frame-count based (animation phases, dig every 10th frame, ladder every 17th, 24-frame digits), so
`physics_ticks_per_second = 24` and every lemming advances once per physics tick, exactly like one DIV frame. The turbo
key runs five logic steps per tick like the original (`Speedup=4`). Sprites are rendered at the display rate.

## map_xput / map_put anchor (the open question in the guide)
The game places 16x16 lemming sprites (control point (7,12)) at the lemming's feet position and loads whole levels with
`map_put(0,2,Level,320,95)` into a 640x190 graphic: 320,95 is the centre of a 640x190 graphic with no cp0 and the level
only fits if the **control point (centre if undefined) is placed at x,y**. Hole graphics (81/82/83, cp (7,12)/(15,16)) are
stamped at the lemming position and only look right with cp placement too. So both map_put and map_xput use control point 0.

## Deviations / guesses
- Added: skill icon highlight, panel mouse buttons, "Try again!" banner (0..1 s) when a level is failed (original restarted silently),
  end screen instead of exiting the program, level select + Esc (see above; the original always started at 900).
- Lemmings that have not yet emerged (parked at 0,0 in the original) cannot be picked with the pointer (the original could
  accidentally give them skills).
- Cheat `O`+`G` wins the level (sets saved to 500 and the time to 0, as in the original; `Level._check_level_end`).
- Mouse-driven only for picking; skills were never mouse-selectable in the original (keys only).

## Original quirks kept
- `Lommingsnumber` is "count - 1": a level with value 25 has 26 lemmings, "to save" is shown as value+1 and you need
  saved > value (so all 26 when value=25).
- The `+` key makes lemmings emerge slower (it increases the interval) although it sits to the right of `-`.
- Un-stopping a stopper costs another stopper; the right-click turn costs one too.
- The Backspace nuke also resets `Explode` of lemmings that are already saved or dead; a saved lemming whose countdown
  runs out is turned into a dead one (saved count drops) - a bug of the original.
- The emerge loop stops at the first lemming that has not yet emerged (`CASE 0: BREAK` leaves the loop), so lemmings that
  were nuked before emerging only start counting down once they appear.
- Falling more than 80 frames kills, falling out of the level (y >= 189) kills; umbrella cancels the fall counter.
- Time runs 25 frames per second-unit (1.04 s per "second").

## Verification
- `godot --headless --import`, `--quit-after 300` clean (no script errors).
- `--autotest` (`godot --headless --path . --fixed-fps 600 --quit-after 200000 -- --autotest`): drives the mouse override,
  presses every skill (left and right click), nuke, turbo, pause, and forces level wins through all 13 levels to the end screen;
  prints a summary, no runtime errors. `-- --autotest --noclick` shows lemmings walking unassisted (level 900 needs climbers).
- Windowed screenshot checked (`screenshot_gameplay.png`).
- Level select (2026-10-26): a temporary headless test (deleted afterwards) drove the list with key events (Down/Up/Enter,
  Esc back) and mouse hover + click, loaded all 13 levels from it (checked level code, lemming count, exit), won 905 ->
  906 with O+G and checked Esc highlights 906, won 950 -> end screen -> Enter back to the list; no script errors.
  `--autotest` still runs (the list starts level 900 straight away with that flag). Windowed screenshot of the list looked at.
- Web export succeeded (wasm brotli compressed); not run in a browser.
- Needs a human play-test: feel of walking/falling speed, each skill's behaviour in all 13 levels (levels were not solved
  by hand), the guessed panel button regions on the right of the panel.
