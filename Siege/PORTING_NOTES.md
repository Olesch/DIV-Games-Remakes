# Siege - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/SIEGE.PRG` (Oleg Yuschuk, idea: Fallen Angel Industries; edited Oct 2026), 320x240,
`set_fps` never called -> DIV default **18 fps**. Assets: `div_convert.py game` -> `assets/fpg/siege`.
Run: main scene `scenes/setup.tscn` (setup page, then the splash pages, then the battlefield).

## Controls (both players share one keyboard)
- Setup page (new, owner's decision 2026-10-26): `PL 1` / `PL 2` each HUMAN or COMPUTER. Up/Down select a row,
  Left/Right (or Enter/Space on a player row) toggle, Enter/Space on START (acts on release) -> splash pages.
  Default: both HUMAN = exactly the original game. The choice is kept in `Game.computer` until changed.
- Splash pages 80-85 (the recipe lists): Enter or Space = next page (acts on key release, like the original).
- Player 1 (left castle, field on the left, "PL 1"): arrows (or keypad 8/2/4/6) move the cursor, **O** pick/swap a tile,
  **P** build units, **L** re-roll the field.
- Player 2 (right castle, "PL 2"): **W A S D**, **1** pick/swap, **2** build, **Q** re-roll.
- Esc (new): back to the setup page / restart. The original could only be quit with Ctrl+Esc.

## Rules as implemented
- Each player has a 6x5 field of element tiles (1 wood, 2 metal, 3 fire, 4 magic). Swap two tiles (pick, then pick again;
  picking the same tile deselects). Recipes are matched on the **two bottom rows**; the blue outlines show every complete
  recipe. Build creates all matching units, then the field moves down two rows and two new random rows appear on top.
  Re-roll replaces the whole field (cursor spins 30 frames, new tiles appear afterwards, cursor blocked meanwhile).
- All 19 recipes, tech levels (always 6), the "only one at a time" rules (tower, vines, cloud, necromancer, worker) and the
  recipe priority/slot-overlap logic are in `scripts/grimoire.gd` (data table in PRG order).
- Units (`unit.gd`): warrior, ram, bomber, vines, knight, cloud, elephant, tower, airship, golem, dragon, necromancer, skeleton.
  Fighting: enemy ground units within 8 px trade 1 life point each per frame (each side does it in its own turn: 2/frame per pair).
  Reaching the enemy castle costs it `sqrt(LP*4)` life and removes the unit. Castle life starts at 100 (gauges, graphs 20-26).
- Shots (`shot.gd`), explosions (`explosion.gd`, damage radius/amount from the CONST block), build animations (`siege_anim.gd`:
  archer, catapult, ballista, mage laser, worker repair+run, plague chain reaction), the meteor shower (recipe 4,4/3,3).
- Painter (`painter.gd`): sky/hills, 3 birds, 6 drifting clouds with changing wind, both castles - decoration only.

## Mapping DIV -> Godot
| DIV | Godot |
|---|---|
| GLOBAL tech/life/field | autoload `Game` (`game.gd`), actions registered in `InputMap` at startup |
| Cursor, Choosen_cursor | `field_cursor.tscn` (input via `_unhandled_input`, spin via `SceneTreeTimer`), `choosen_cursor.tscn` |
| Draw_field / Unit_Locator | `FieldView` node (draws tiles) / `UnitLocator` node (draws recipe outlines at y=66, replaces map_put into graph 29) |
| Search_Units | `Grimoire` (mode 1 = mark, mode 2 = create) |
| Unit / Shot / Animation / Explode | scenes + scripts (groups `units`, `animations`); each node runs in its own `_physics_process`; multi-frame sequences use `SceneTreeTimer`s |
| (new) human/computer choice | `scenes/setup.tscn` + `setup.gd` (white page like the help pages, DIV system font, blue cursor frame) |
| KI(player) (call commented out in the PRG) | `ComputerPlayer` node (`computer_player.gd`), one per side set to COMPUTER |
| Life_gauge, Painter | `life_gauge.tscn`, `Painter` node |

Timing: the project runs physics at 18 ticks/s (= DIV fps) because the whole game is counted in frames (movefreq counters,
FRAME(n) delays). Positions are integer pixels as in DIV; there is no interpolation, so it moves in 18 fps steps like the original.

## Original quirks kept
- The AI process `KI(player)` exists in the PRG but its call `KI(1)` is commented out. **Owner's decision 2026-10-26:** it is
  ported faithfully and offered on the setup page for either side (it takes the player as parameter and `Unit` handles both
  sides, so COMPUTER is allowed for PL 1, PL 2 or both = demo). What it does, exactly as written: on creation and then every
  24 frames (`FOR wait=24..1 FRAME`, 1.33 s at 18 fps; counted in physics ticks) it draws `counter=rand(0,20)` and, if
  `counter<20` (20 of 21 passes), creates `Unit(1,player)` = one warrior. Nothing else: it ignores its element field, tech and
  recipes, pays nothing (warriors are free), never builds other units; the `ELSE counter-=20` branch is dead (counter is
  redrawn every pass) - probably a stub for a planned "savings" mechanism. ~0.71 warriors/s, so it is a weak opponent;
  nothing was tuned. No fix was needed: uncommenting the call is all it took to work.
- Port decision for a COMPUTER side: its field is still drawn (with recipe marks) but it gets **no cursor** (in the PRG,
  `KI(1)` would have run in addition to `Cursor(1,...)`, i.e. human + KI on the same side; a "computer" choice should not
  leave the human keys active). `World.cursors[p]` is null for such a side.
- **No win/lose condition**: the gauge just shows the "empty" graphic at life <= 0 and the game goes on forever.
  (Restart with Esc.) Nothing was added.
- Necromancer: the skeleton limit check compares the dying unit's `art` with 13 (never true), so a skeleton is raised for **every**
  dying "human" (warrior, ram, bomber, knight, elephant, tower) of that player while the necromancer is casting (graphs 305-308).
  `World.ENFORCE_SKELETON_LIMIT` (false) switches to a real limit of 3.
- The tower is flagged "human" too, so it also raises a skeleton when it dies. Recipe marks are only refreshed when the field
  changes, so a mark can be stale (e.g. after the unique unit died).
- Marking mode can mark two worker/vines positions although only one can be built.
- `sqrt` of a negative LP at the castle is treated as 0.

## Deviations / guesses
- Input comes from InputMap events instead of polling `key()`: one cursor step per key press (the original also moved once per
  press); key repeat is ignored. Build pressed with no match does not repeat. Splash/Esc as above.
- Timers of multi-frame sequences use real-time `SceneTreeTimer`s (frames/18 s) instead of frame counters; order of
  processes within a tick is node-tree order (creation order), like DIV's.
- Skipped: nothing debug-related existed except `DEBUG`-free code. Cloud wind etc. use `randi_range`.

## Verified vs. needs a human play-test
Verified headless/windowed: import clean, setup page (screenshot checked; Enter on START reaches page 80 without skipping it),
splash -> game flow (`scripts/debug/title_flow.gd`), `scripts/debug/autotest.gd`
(`godot --path . res://scenes/world.tscn -- --autotest [--screenshot=f.png]`: every recipe at every position is marked and built
for both players, field shift/swap/re-roll, necromancer, fight trade, castle damage, all units/animations in a long battle,
input actions), web export.
KI (2026-10-26, temporary headless test, deleted): 3 simulated minutes human-idle vs COMPUTER -> 128 warriors in 135 KI passes
(expected ~129), only warriors, spawns on the 24-frame grid, castle 0 destroyed, no cursor for PL 2; 1 minute COMPUTER vs
COMPUTER -> 44 / 43 warriors. Existing autotest and title_flow still pass. Web export not redone (not deployed). Screenshot checked visually.
Needs play-testing: feel of two-player keyboard play (ghosting on shared keyboards), exact pacing vs. DOSBox, balance.
