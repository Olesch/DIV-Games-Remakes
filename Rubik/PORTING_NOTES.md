# Rubik - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/RUBIK3X3.PRG` (Oleg Yuschuk), 640x480, 18 fps. No graphics files: the original only
uses the system font and `put_pixel`. Assets: system font (`assets/fnt/system`, via `div_convert.py game`)
and the default DIV palette (`assets/pal/div`, from `DIV/PAL/DIV.PAL`) for the dot colours.
Main scene: `scenes/main.tscn`. Web slug: `rubik`.

## Controls
- Left / Right (or keypad 4 / 6): move the cursor around the 12 border positions (wraps 12 <-> 1).
- Enter (or keypad Enter): rotate the three numbers next to the cursor (columns for 1-3 / 7-9, rows for 4-6 / 10-12).
- M: scramble (random cursor position + one move; the cursor jumps there, as in the original).
- Esc: quit on desktop (new; ignored in the web build, which never calls `quit()`).
- Holding a key repeats at the OS key-repeat rate (the original acted every frame, i.e. 18 times/s).

## Mapping
| DIV | Godot |
|---|---|
| globals `Pos[]`/`newPos[]`, process `Move()` | `scripts/puzzle.gd` (`Puzzle`): 9 cells, 12 cyclic shift tables, `apply_move()`, `is_solved()`, `changed` signal |
| main loop, `Cursor`, keys | `scripts/main.gd` on `scenes/main.tscn`; InputMap actions created in code; handled in `_unhandled_input` |
| `repaint()` texts (`write`, `write_int`) | `PixelLabel` nodes (system font, DIV anchor/alignment), numbers refreshed on the `changed` signal |
| `Pix[]` + `put_pixel` dots | `scripts/pixel_field.gd` (`PixelField`, `_draw()` of 1x1 rects; steps at 18 Hz accumulated from `delta`) |

The dots only appear while the board is solved (1..9 in order), as in the original; Clear_Screen each frame
corresponds to redrawing only the latest step's pixels.

## Deviations / guesses
- DIV `put_pixel` with a negative colour index (`(col-1) mod 256` can reach -1): wrapped with `& 255`.
- Dots whose coordinate goes negative (C-style `mod`) stay off-screen until they respawn, like the original.
- The original starts with one random move (`cursor=rand(1,12); Move()`); kept, so the game starts one move from solved.
- Palette: DIV's default palette (`DIV.PAL`) assumed for `put_pixel` colours.
- No hiscores or save files; nothing is written to `user://`.

## Verified / not verified
- Verified headless (`-- --autotest`): every move is a 3-cycle, inverse move pairs (1/9, 2/8, 3/7, 4/12, 5/11, 6/10),
  scramble + undo returns to solved, cursor wrap, InputMap action reaches the handler, dots on/off with solved state.
  The test writes no files and quits itself except in web builds.
- Screenshot (`screenshot_gameplay.png`) of the solved state with the dot animation.
- Needs a human play-test: key-repeat feel, dot animation speed vs. the DOS original.
