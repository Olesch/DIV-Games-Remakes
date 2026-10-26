# Castle - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/CASTLE.PRG` (edited 2026; "Copy of CASTLE.PRG" ignored), 800x600, `set_fps(24,0)`.
Assets: `div_convert.py game` -> `assets/fpg/castle`, `assets/fnt/castle`, `assets/fnt/system`,
`assets/dat/level1.dat, level2.dat, castle1..4.dat` (raw int32 copies; the JSON copies and indices.bin were removed).
Main scene `scenes/title.tscn`.

## Controls
- Menu: S new game / L load game; new game: 1 or 2 = level set, Left/Right = difficulty (Baby..Diabolo, key repeat),
  Enter/Space = start; load: 1-4 = save slot. New: the level set screen offers 1-4 ("Welches Levelset? 1-4",
  original "1-2"); 3 and 4 are Castedit's user slots, shown as "Castedit-Level" or "nicht vorhanden" (then the key
  does nothing).
- Walk: arrows (or keypad). Attack: End (also Space). Change weapon (sword/bow/magic): Del (also X).
  Run: Ins (also Shift). Change magic: PgUp (also C). Stats parchment while held: PgDn (also V).
- Save: stand on a save point (the lamp-like item) and press Ctrl+1..4 (new: F1..F4 alone also work, because browsers
  grab Ctrl+digit). The save point is used up (but the saved file still contains it, like the original).
- Alt+Ctrl: walk through shut trapdoors (original hidden cheat, kept). Esc: back to the title (new).

## Structure
| DIV | Godot |
|---|---|
| GLOBAL (Stage, Stat, Difficulty, Map, xhero/yhero) | autoload `game.gd` (`Game`) + `hero_stats.gd`; map = `PackedInt32Array`, index `((room*2+layer)*40+x)*30+y` |
| main code menu | `title.tscn`/`title.gd` (small state machine driven by `_unhandled_input`, Timer for the particles), `spec_effect.tscn` = SpecEffect |
| Levelzeichner + Background | `world.gd` (game.tscn): tiles blitted into an `Image` (graph 100 stays between rooms, so cells with terrain 0 keep the old room's picture like the original); spawns enemies/pickups |
| Hero | `hero.tscn`/`hero.gd` |
| Enemy | `enemy.tscn`/`enemy.gd` (group `enemies`) |
| Shot | `shot.tscn`/`shot.gd` (sword hit, arrows, stones, flame, ice) |
| Potion (all pickups, save point) | `pickup.tscn`/`pickup.gd` (group `pickups`, pixel-exact overlap with the hero via `Gfx.overlap`) |
| Blood | `blood.tscn` |
| Energyline, Conditionline, CurWeap, Statistic, Picture | `hud.gd` (CanvasLayer) |

Timing: `physics_ticks_per_second = 24`, so one physics tick is one DIV frame. The original is integer-pixel logic
(3 px/frame, tile = x/20, distances `<10`, `<7`), so I kept it per tick instead of converting to per-second floats; the
rendering is therefore 24 steps/s like the original (no interpolation). Input: held movement keys are tracked from
input events; attack / weapon / magic are one-shot requests served by the hero on its next tick; the panel and
the menus use `_unhandled_input`. No `await`/frame-coroutines.

## Level data
`LEVEL1.DAT`/`LEVEL2.DAT` (86400 int32 = 36 rooms x 2 layers x 40 x 30) are shipped as `assets/dat/level*.dat` and
loaded with `PackedByteArray.to_int32_array()`. The save files `CASTLE1..3.DAT` (86428 ints: Stage, Campaign, Hero_id,
22 stat fields, Difficulty, xhero, yhero, Map) are shipped as default slots and read with the same layout; new saves go to
`user://castleN.dat` in the same format (user file wins). `CASTLE4.DAT` has an older/shorter layout (86424 ints) and is
ignored ("Kein Spielstand"). Verified by the autotest (slot values are plausible, a written save loads back identically).

**Level sets 3 and 4 (addition, not in the original):** the Castedit port keeps sets 1/2 as read-only originals
and saves user slots as `CastleLevel3.dat` / `CastleLevel4.dat` (same 345600-byte format) in its own `user://`.
Godot gives every project its own folder (`<data>/godot/app_userdata/<project name>`; web:
`/userfs/godot/app_userdata/...`), but on the web all of `/userfs` is one IndexedDB database per origin that each
Godot game loads completely at start-up, so `Game.load_levelset(3/4)` reads
`OS.get_user_data_dir().get_base_dir() + "/Castedit/CastleLevelN.dat"` (wrong size -> warning, not selectable).
Sets 1/2 always load the shipped files; `CastleLevel1/2.dat` from an older Castedit version are ignored. Checked in a
browser on one origin and on desktop. A Castedit save made while Castle is open in another tab is only seen after
reloading Castle. Save slots contain the whole map, so loading a saved game never depends on the level files.

## Faithful details / original quirks kept
- Hero starts with Life 10 of 80 (difficulty 0). Stats at start: Maxlife 80-10d, Maxmana 8-d, Strength 3-d/2, Magic 8-d, Bow 4-d/2, Condition 50-8d.
- Opening a door with a key still blocks that one step (stale tile value). Walls: 22, 26 (slit, arrows pass), 28 (thin slit,
  arrows pass only during their first 80 px), 11/71 (doors), 212 (shut trapdoor); 40 slime halves speed to 1; 211/214 switch trapdoors in a 5x5 area.
- Enemy melee `Yinc=Xinc/2`, archers fire only when an odd number of the four "off-axis" tests holds (DIV XOR), the Ork hero
  (OrkHeld) shoots invisible arrows (weapon graph 0), regeneration compares against the life before difficulty scaling.
- Dead archers/OrkHeld drop arrows; the pickup clears the map cell computed from its own position (original comment: "Arrows appear twice"),
  so it can erase a neighbouring object marker.
- Enemy hits with `get_dist<10` block the hero even when moving away.
- Entering a room frees all enemies/pickups/shots and redraws; enemies you left alive respawn at full life, killed ones do not.
- Moving off the map (stage < 0 or > 35) would index outside the array in DIV; here the hero is kept in the room.

## Deviations / guesses
- Hero death: after the growing/spinning death animation the game returns to the title (original: `exit("Bye")`).
- Loading a save also shows the condition (stamina) bar (original forgot to start it after a load).
- Missing/invalid save slot shows a message instead of hanging.
- Extra keys (Space, X, Shift, C, V, F1-F4, Esc) are additions; so are level sets 3/4 from Castedit (see Level data). Debug items skipped: none besides the commented-out
  cheat block (all stats boosted) and the unused Magicline mana bar (call is commented out in the PRG).
- Collision of pickups is pixel exact (alpha mask); enemies/shots use point distances exactly like the original.
- Export preset: `include_filter="assets/dat/*.dat"` added so the raw level files are packed.

## Verified / needs a human
Verified headless (`godot --headless --path . -- --autotest`, exit 0): level + save loading, new game, a 1500-tick fight in the
busiest room (116 monsters; all weapons, magic cycle, run, stats panel), room changes right/bottom, trapdoor trigger,
save + reload, hero death -> title, a Castedit `CastleLevel3.dat` offered on the level set screen (3 loads it,
missing 4 cannot be chosen, set 1 stays original), playing from a bundled save slot; no script errors. The test moves existing
`user://castle2.dat` and Castedit's `CastleLevel3/4.dat` aside, deletes what it wrote and puts them back (checked at the end).
Screenshots checked visually.
Needs a human play-test: balance/feel at 24 ticks/s, ice/heal magic numbers, archer behaviour, the Ctrl+digit save in a desktop build,
and the dark-red look of room 0 vs. the original (taken straight from the converted FPG).
