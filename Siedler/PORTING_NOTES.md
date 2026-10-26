# Siedler - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/SIEDLER.PRG` (Oleg Yuschuk, 25/1/2005), 640x480, 24 fps. `SPACE3.PRG` is an
earlier prototype (terrain + cursor + palette-rolled water) and was only read for context.
Assets: converted with `div_convert.py game` into `assets/` (fpg/siedler, fnt/system). The game uses
only the DIV system font (the `load_fnt("Olegs\Space.fnt")` line is commented out in the original).
Run: open the folder in Godot 4.7, main scene `scenes/main.tscn`. Web slug: `siedler`.

**The original is unfinished.** Its header lists the known bugs: settlers stepping right/down can move
twice per frame, building sites can be laid out but houses never get built, clay cannot be collected.
The port keeps it as a sandbox that does exactly what the original does (see "What the original lacks").

## Controls
- Mouse moves the arrow over the 1280x960 world; the view scrolls with it (relative mouse, captured).
  The first click only grabs the mouse (needed for pointer lock in browsers); Esc releases it.
- Left button (held): sets a pending collection point, or lays out building sites while in building mode
  (dragging lays out several, like the original).
- Keyboard menu (bottom-left text, German like the original):
  `M` menu -> `S` collection points (`H` wood / `L` clay, then left-click on the map),
  `R` worker quotas (`H` woodcutters / `L` clay diggers, then `+`/`-`), `G` buildings (`H` house).
  `A` (Abbruch) closes the menu from any level.
- `+`/`-` are the keys right of `0` on a US keyboard (DIV scan codes 13/12; on Oleg's German keyboard these
  were the `´` and `ß` keys) and also keypad `+`/`-`. One step per press plus key repeat (original: one
  step every 3 frames while held).

## How the DIV program maps to Godot
| DIV | Godot |
|---|---|
| GLOBAL section (quotas, worker counts, collection points, `Holzsetzen`, `BeimBau`, `STOP`, `Haus[50]`) | autoload `scripts/game.gd` (`Game`), also registers the InputMap actions |
| `Maennchen` (sweeps the LogicMap once per frame), `Begehbar`, `Loesche_Feld`, objects part of `Draw_all` | `scripts/colony.gd` (`Colony`): the three 128x96 grids as `PackedByteArray`s, one sweep per physics tick (`physics_ticks_per_second = 24`) |
| graphic 2 "WorldMap" filled by `Draw_all` | `TerrainLayer` (`TileMapLayer`, 10x10 tiles, random variant per cell, building-site tiles) |
| graphic 8 "Overlayer" (trees and settler pictures `map_put` into it) | `TreeLayer` and `SettlerLayer` (`_draw()` from the colony state; trees redraw on `trees_changed`, settlers on `ticked`) |
| `cursor()` + `new_coordinates()` + `scroll[0].camera` | `WorldCursor` (`cursor.gd`, Sprite2D) with a child `Camera2D` limited to the 1280x960 world |
| `Hausbau(200)` | `HouseGhost` (snapped to the 10-px grid, visible while `Game.building`) |
| `HelpMap` / `HelpMapb` (LogicMap graphic in the "Rahmen" frame) | HUD `MiniMap` (`ImageTexture` rebuilt each tick from the job grid) + frame `TextureRect` |
| `KnoepfeEvent` (nested key loops with `write`) | `ActionMenu` (`menu_bar.gd`): state machine, input via `_unhandled_input`, system-font Labels anchored bottom-left |

The grid values are the original palette indices (enums `Colony.Terrain`, `Colony.Obj`, `Colony.Job`):
terrain 40 grass / 55 water / 115 building site / 120 clay; objects 40 tree / 55 settler marker;
jobs 55 idle, 75 walking, 40 woodcutter, 41 felling, 42 carrying wood, 120 clay digger, 121/122 digging /
carrying clay. The start maps (graphics 9 and 10) are decoded from their PNGs (they only contain indices
0/40/55/120, whose colours are unique), so no raw data file is shipped.

Settler rules per sweep (unchanged, F = 24 sweeps/s): idle -> walking 1/51; walking -> woodcutter 1/201
and -> clay digger 1/201 while below quota; walking settlers step in a random direction 4/20; workers step
along the farther axis toward their collection point 5/40, the nearer axis 3/40, stand 25/40, random step
7/40 x 4/20; a woodcutter stepping onto a tree starts felling, which ends with 1/101 per sweep (tree gone,
settler now carries wood). A worker quits (becomes idle) when its collection point is unset, or when the
job is over quota (1/151, only while `STOP` is not set).

## Original bugs and quirks kept
- Double move: the sweep changes the grid in place, so a settler stepping right or down is met again in
  the same sweep (the header's first bug).
- `Rand(0,250==0)` in the "quit job" test is `Rand(0,0)` = 0 = false, so the intended 1/251 chance to quit
  never happens.
- `STOP` is set when a worker quits for lack of a collection point and never cleared again, after which
  lowering a quota no longer sends anyone home.
- If both 1/201 rolls hit in the same sweep, the settler becomes a clay digger but is also counted as a
  woodcutter.
- Trees standing on water or clay: `Draw_all` meant to forget them but clears the *terrain* cell instead.
  They are never drawn, still block walking, and woodcutters can fell them - after which settlers can walk
  on that (now terrain-less) river cell. About 200 such invisible trees sit along the river.
- Aborting the collection-point step with `A` leaves the point armed (the reset after `BREAK` is dead code),
  so the next left click anywhere still sets it.
- A settler keeps its old picture after a job change until it moves (the original only repaints on moves).
- Collection points have no marker on the map; quotas can go negative.
- Building sites are recorded in `Game.houses` (the original's `Haus[]` struct) but never used.

## What the original lacks (not added)
- Wood carriers (job 42) just stand on the felled tree's cell forever; nothing is delivered or stored.
- Clay diggers walk toward their point but never dig: the step onto clay is commented out
  ("OLLO! Petite Probleme!!!"), so jobs 121/122 are unreachable (the code for them is ported).
- Houses: only the 3x3 building site is laid out (tiles + terrain 115); `HausVervollstaendigungsMap`,
  `Need_Wood`, the finished-house terrain 116 are never used. No economy, goal, win or lose condition.
- Water animation (`WaterAnim`, palette cycling) is commented out in the original; the water tiles do not
  even use the cycled colours. Not ported.

## Deviations / small fixes
- Map edge: the original only stopped settlers at cell 0 and at "1279/959" (pixel sizes instead of cell
  sizes), so they could step to x = 128 or y = 96, outside the 128x96 maps, and vanish. Fixed: settlers
  stay inside cells 1..126 / 1..94.
- `Haus[50]` overflowed after 51 sites in the original (writes past the struct); here it is an Array.
- Out-of-map reads count as 0 (DIV's `map_get_pixel` behaviour assumed), so building sites can still be
  laid out half off the map edge like in the original.
- Skipped debug features: F1-F4 fps/skip changes, F5 fps readout.
- The scroll region started at (1,1) in the original (a 1-pixel black line); not reproduced.
- Mouse: captured relative motion instead of re-centring the hardware mouse; first click grabs the mouse.
- Within one sweep, the DIV version swept x 0..129 and y 0..97 (beyond the map); those extra cells read 0
  and do nothing, so only the 128x96 cells are visited.

## Verified vs. needs a human play-test
Verified on this machine:
- `godot --headless --import` and `--quit-after` runs are clean (no script errors or warnings).
- `scripts/debug/autotest.gd` (`godot --path . -- --autotest [--screenshot=<file.png>]`): drives the menu
  with simulated keys (quotas 4/3, aborted point stays armed, wood and clay points by click, two building
  sites by drag), runs 90 s of game time at 8x speed, checks that the settler count stays 10 and settlers
  take jobs; woodcutters reach the forest and fell trees, clay diggers walk to the river. A sweep takes
  ~0.3 ms. It writes nothing to `user://` and never quits on web.
- Windowed screenshot checked: terrain tiles, jittered trees, settler/carrier sprites, house ghost,
  building sites, minimap frame with job pixels, system-font menu text.
- Web export builds.

Needs a human: mouse feel (captured relative motion, speed under browser scaling), pointer lock on the
web page, key repeat for `+`/`-`.
