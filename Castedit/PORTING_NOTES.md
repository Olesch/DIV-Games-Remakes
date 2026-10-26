# Castedit - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/CASTEDIT.PRG` (659 lines), Oleg's room editor for CASTLE. 800x600, `set_fps(24,0)`.
Context: `TRANSLAT.PRG` (one-off tool that turned the old room graphics 900-926 of CASTLE.FPG into `saves/Level1.dat`;
those graphics are no longer in the FPG).
Assets: `div_convert.py game CASTEDIT.PRG assets` -> `assets/fpg/castle` (indices.bin removed), `assets/fnt/system`,
`assets/dat/level1.dat`, `level2.dat` (raw int32; the JSON copies were removed). Main scene `scenes/title.tscn`.
Web slug `castedit`; the export preset has `include_filter="assets/dat/*.dat"` and the exported `index.pck` was checked
to contain both .dat files.

## Level sets, user slots, export / import (addition, not in the original)
The original's Ctrl+S overwrote `saves/LevelN.dat`. In the port sets 1 and 2 are Oleg's originals and always load
from the shipped files (read-only); sets 3 and 4 are user slots stored as `user://CastleLevel3.dat` /
`user://CastleLevel4.dat` in the original format (raw `Map[]`, 86400 little-endian int32 = 345600 bytes). The
`CastleLevel` prefix is required: all games of the web site share one browser storage.
- Start screen: "1, 2 - originals   3 - saved/empty   4 - saved/empty". Opening an empty slot asks "Start from a copy
  of set 1 or 2?" (any other key cancels); the copy is written on the first Ctrl+S. `D`, then `3`/`4`, then `Enter`
  deletes a slot (any other key cancels).
- Ctrl+S in slot 3/4 saves straight back ("Saved to slot 3"). Ctrl+S in set 1/2 asks "Save to slot 3 (empty) or
  4 (overwrite)?  Other key: cancel"; after saving, that slot is the open set. The editor pauses while it asks.
- `Ctrl+E` exports the open set (1-4) as `CastleLevelN.dat`: web = browser download (`JavaScriptBridge.download_buffer`),
  desktop = native save dialog. `Ctrl+O` imports a .dat file into the open set in memory (web: hidden
  `<input type=file>` read as an ArrayBuffer; the bytes come back through `JavaScriptBridge.eval` as a
  PackedByteArray; desktop: native open dialog). Wrong size -> toast "name: N bytes, a level set has 345600", nothing
  changes. Ctrl+S then saves it as above. Code: `level_files.gd`.
- `CastleLevel1.dat` / `CastleLevel2.dat` written by the previous version of this port (which saved over sets 1/2) are
  ignored and left where they are (never loaded, never deleted).
- Ctrl means Cmd on a Mac (`command_or_control_autoremap`). Godot's web build calls `preventDefault()` on every key
  event that reaches the canvas, so the browser's own Ctrl+S/E/O do not fire while the game has focus.
- Castle (port) plays slots 3/4: Godot gives every project its own `user://` folder
  (web: `/userfs/godot/app_userdata/Castedit/`), but on the web all of `/userfs` is one IndexedDB database per origin
  that every Godot game loads completely at start-up, so Castle reads `.../app_userdata/Castedit/CastleLevelN.dat`
  next to its own folder (desktop: same layout under `%APPDATA%/Godot/app_userdata/`).
- Edits that are not saved are lost on Esc or page reload (no "unsaved changes" warning).

## Controls
- Start screen: `1` / `2` = original level set (original text "Welches Mapset? 1,2"); new: `3` / `4` user slots,
  `D` delete a slot, and the controls list below.
- Arrows (or keypad 4/6/8/2): move the cursor. `Z` floor chooser, `X` object chooser (physical keys: Z is the key labelled
  Y on German keyboards, like the original's scan codes). `Enter`: in a chooser pick the brush, in the room place it
  (hold Enter + an arrow to draw lines). `Del`: floor cell -> plain floor (6), object cell -> nothing (0).
  `I J K L`: room up / left / down / right in the 6x6 room grid. `Ctrl+S`: save (to slot 3/4, see above). New: `Ctrl+E` export,
  `Ctrl+O` import (see above).
- New: `H` or `F1` toggles a help overlay (controls + level set, room, mode, brush and the values under the cursor);
  `Esc` goes back to the level set choice. The original had no on-screen help at all.

## Structure
| DIV | Godot |
|---|---|
| GLOBAL Map/stage/set | autoload `game.gd` (`Game`): `PackedInt32Array` map, index `((room*2+layer)*40+x)*30+y`, `load_levelset()`, InputMap setup |
| main code (map set question) | `title.tscn` / `title.gd` (`_unhandled_input`) |
| Background (graph 100) + Levelzeichner + Potion/Enemy | `room_view.gd`: tiles blitted into a persistent 800x600 `Image`; one marker `Sprite2D` per object |
| Painter + Chooser + Back | `editor.tscn` / `editor.gd` (cursor, choosers, all edit actions) |
| get_Object + value lists | `tiles.gd` (`Tiles`: chooser tables, value -> graphic, English names) |
| (none) | `hud.gd`: help overlay and toasts; `pixel_label.gd`: DIV `write()` with the 6x8 system font |
| save (Ctrl+S) | `Game.load_levelset()` / `start_slot_from()` / `save_to_slot()` / `delete_slot()`, slot prompt in `editor.gd`; export/import in `level_files.gd` (new) |

Timing: `physics_ticks_per_second = 24`; one editor tick = one DIV frame. Held keys act every tick (cursor 1 cell per
tick), Enter/Del/room changes cost one extra tick (the original's `FRAME` between the erase pulse and the redraw), picking
from a chooser costs 3 extra ticks (`FRAME(300)`). Taps come in through `_unhandled_input`, repeats from
`Input.is_action_pressed` in `_physics_process`.

## Original behaviour kept
- The room image is never cleared (graph 100): floor values without a picture keep what was drawn there before.
- Every redraw (each placed/erased cell) re-rolls the random floor/wall variants (1 in 11), so the decoration flickers.
- Floor value 0 is drawn as a wall and written back as 22 in memory (17 empty rooms of set 1 show up as solid walls).
- Bottom-right cell always gets tile 113 (Oleg's name brick).
- Editor-only tiles: 136 secret passage, 134 trapdoor closer, 135 open trapdoor (the game draws them as wall/floor).
- Picking an empty chooser slot: in DIV `get_Object` then returned its own process id, which got painted as an invisible
  value; LEVEL1.DAT (90143, once) and LEVEL2.DAT (90241, 10 cells) contain such values. Here the empty slot paints -1,
  also invisible.
- Object values 10 and 15 ("Leveleditors help" fields, 1400+ cells in set 1) are not shown, like in the original.
- The brush is shared by both layers; Z/X while a chooser is open switches chooser without moving the cursor.
- `K` only works while room < 29 (original `Stage<29`), so room 35 is reachable only from room 34.
- Del while a chooser is open makes all object markers vanish until the next redraw (erase pulse without redraw).
- Holding Enter a little longer after picking places the new brush at once at the restored cursor position.

## Deviations
- Key repeat: a key acts on press and repeats (at the original 24/s) only after 6 ticks (0.25 s). The original repeated
  from the first frame, so a tap often moved 2-3 cells. `Editor.REPEAT_DELAY_TICKS = 0` restores it.
- Saves go to user slots 3/4 (`user://CastleLevelN.dat`) instead of over `saves/LevelN.dat`; slots, export and import
  are new (see above).
  Help overlay, toasts (room number, save/import messages) and Esc are new.
- `difficulty` (always 0) and the random potion/enemy strengths passed to Potion/Enemy are irrelevant in the editor and
  dropped; the markers only show the graphic. Ghost transparency (spec 4/5) is never used by the editor's enemies.
- Graphic 850 "EditRaster" (a grid) is in the FPG but unused by the PRG; not used here either.

## Verified / needs a human
- `godot --headless --path . -- --autotest`: exit 0, all checks ok (both sets load, room 13 shows 118 markers, cursor,
  both choosers, place/erase on both layers, empty slot, hold-to-draw line, room changes incl. the room-29 limit,
  Ctrl+S on set 1 asks for a slot and another key cancels, 3 saves to slot 3 in the original format, set 1 is still
  the original (an old `CastleLevel1.dat` planted by the test is ignored and left alone), Ctrl+S in slot 3 saves
  straight back, import of a wrong-size and a right-size file, Ctrl+E/Ctrl+O dialogs, help, Esc, "3 - saved /
  4 - empty", empty slot 4 started from set 2, D/4 cancels, D/3/Enter deletes). `CastleLevel1..4.dat` the user
  already had are moved aside during the test and put back; the test checks user:// is unchanged at the end.
  `--quit-after 300` and import: no errors/warnings.
- Screenshots checked (room view, chooser with help, start screen). Web export ok, `index.pck` contains the .dat files.
- Checked in a Chromium tab on a local server (with the previous 1/2-saving version; the file code is unchanged): Ctrl+S writes `/userfs/godot/app_userdata/Castedit/CastleLevel1.dat`
  into IndexedDB, Castle on the same origin sees it, revert removes it from IndexedDB, Ctrl+E produces a
  345600-byte `CastleLevel1.dat` download, Ctrl+O's picker input delivers the bytes (file set by script, the native
  picker itself was not driven), wrong size is refused.
- Needs a human: key feel in a browser; the native file picker / download prompt in Firefox and Safari (the picker is
  opened a frame after the key press, inside the browser's user-activation window).
