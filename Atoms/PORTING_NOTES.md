# Atoms (ATOME) - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/ATOMS.PRG` (Oleg Yuschuk, edited Oct 2026), DIV default 18 fps, 640x480.
Assets: converted with `div_convert.py game` into `assets/` (fpg/atoms, fnt/atoms, fnt/system).
Run: open the folder in Godot 4.7, main scene `scenes/main.tscn`. Web slug: `atoms`.

## Controls (as in the original; keypad 2/4/6/8 = arrows, keypad Enter = Enter)
- Intro: Enter continues, H shows the rules (picture, Enter, key list, Enter).
- Option screens: `1` / `2` choose; Left/Right change a value (one step per 1/18 s while held), Enter confirms.
- Game: arrows move the cursor (or, after placing an atom, add bonds in that direction), Enter places an atom,
  Backspace uses a bomb on the atom under the cursor, Esc ends the round and returns to the option screens.
  Esc on the first option screen ("Modus waehlen") quits.

## Rules text / language
The in-game texts are German in the original and stay German (menu texts are drawn with the converted
`Atoms.FNT`; the rules page is the bitmap graphic 4 "Regeln" of the FPG, shown unchanged). Not translated.
Unchanged texts include the typos-free ASCII spelling (`waehlen`, `Groesse`, ...).

## Structure
| DIV | Godot |
|---|---|
| GLOBAL variables, Kill scoring, pre-set atom scatter, hiscores, rand, InputMap setup | autoload `scripts/game.gd` (`Game`) |
| `STRUCT AtX[7].AtY[7]`, `Check`, `KILL` | `scripts/atom_board.gd` (`AtomBoard`, plain RefCounted, unit-tested) |
| main code (intro, rules, option screens, round, exit) | `scripts/main.gd`: small state machine (`enum State`, `_enter(state)` builds a screen, `_unhandled_input` dispatches per state) in `scenes/main.tscn` |
| `Cursor` process | `scripts/cursor.gd` (Sprite2D, `_unhandled_input`, Tween slide) |
| `Repaint` + `Background` (map_put into graphic 1) | `scripts/board_view.gd` (drawn live: black, background 114-Field, atoms 102, bonds 103..106) |
| `write` / `write_int` | `scripts/pixel_label.gd` (`PixelLabel`, DIV alignment codes, optional live getter) |

No frame loops, tick signal or key polling: all input is event based (InputMap actions through
`_unhandled_input`; `echo` gives key repeat on the value selectors and cursor arrows), delays are timers and a
Tween, nothing depends on frame counts, default physics rate. DIV delays converted at 18 fps: intro 72/18 s
(input ignored meanwhile, `create_timer`), cursor move 4/18 s Tween per cell (input ignored while it runs), a finished
molecule stays visible 2/18 s (`create_timer`) before it is removed, thanks screen 3 s.

## Faithful details / original quirks kept
- Points = number of atoms removed (not bonds). A bomb is awarded when the collected points reach the threshold
  (only one bomb per removal even if more points are collected).
- Easy mode: a bond into the border counts as satisfied. Hard mode: it is open (and hard mode also restricts
  pre-set atoms to the interior).
- Only the molecule of the atom just completed is checked; other atoms with dangling bonds stay. Bombs remove the
  atom only, neighbours keep their bonds pointing at the now empty cell (so such a molecule can never be completed
  until an atom with a matching bond is placed there). The board can fill up; there is no game over, only Esc.
- Pre-set atoms: placed at random with random bonds; if one completes a molecule right away it is removed and the
  counter gives it back, so exactly the chosen number of atoms stays (verified by the autotest).
- Quad option: "fewer 4s" uses `rand(3,13)/3` (~18 % fours instead of 25 %).
- `Exit("Thanks! Your Score:", Points)` prints to the DOS prompt; the port shows the text for 3 s and quits
  (web build: returns to the intro, since a browser page cannot quit).

## Deviations / additions (all small)
- Hiscores: the original declares HiEasy/HiHard and `Saves\ATSCEA.DAT` / `ATSCHA.DAT` but the saving code is
  commented out. Port: best score per mode is saved at the end of a round (Esc) and on exit as one int32 in
  `user://ATSCEA.DAT` / `user://ATSCHA.DAT` (same file names/format as the original would have used), and shown as
  small "Rekord: N" text on the mode menu (new; the original never displayed it).
- Key repeat comes from the OS echo (initial delay, then ~30/s) instead of the original's one step per frame (18/s)
  from the first frame; value selectors therefore need a short wait before a held key runs.
- Pre-set atoms are scattered instantly (original: one frame per placed atom, invisible anyway).
- Smooth Tween instead of 4 discrete 10 px steps for the cursor.
- One key event does one thing (the original could process several keys in the same frame).
- No debug features existed in ATOMS (no fps keys); nothing skipped.
- H shows the rules only on the intro screen (as in the original).

## Verified
- `godot --headless --import` and `--quit-after` clean (no SCRIPT ERROR / warnings).
- Autotest (`godot --headless --path . --quit-after 40000 -- --autotest`, optional `--screenshot=<png>`,
  `--shotdir=<dir>`): board-rule unit tests (easy/hard wall rule, chains, open bonds, one-sided bonds), then plays
  through intro, rules, all option screens with simulated InputMap events, an easy 8x8 round (pre-set atoms count
  invariant, bomb, scoring, cursor movement incl. input blocked during the slide, random play, Esc reset, hiscore file) and a hard round (fewer 4s, 10
  shown atoms, random play), then quits. All checks pass; it writes `user://autotest_*.dat` instead of the real
  hiscore files.
- Windowed screenshots of every screen inspected; web export succeeds (`../_web/public/atoms/`, wasm brotli-compressed).

## Needs a human play-test
- Feel of the key-repeat speed on the selectors and of the cursor slide in the browser.
- Exact vertical text alignment versus the DOS original (label height = font line height 54; DIV's own rule for
  centring on y is not documented).
- Width of the space glyph in the Atoms font (converter guess 13 px; visible in `<        >`).
