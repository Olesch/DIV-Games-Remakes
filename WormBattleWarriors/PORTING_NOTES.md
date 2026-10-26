# WormBattleWarriors - porting notes

Source: `DIV\PRG\Olegs\UNDWORLD.PRG` (program name WormBattleWarriors), 320x240, default 18 fps (set_fps never called).
Assets: `UndWorld.FPG` / `UndWorld.FNT` converted to `assets/` (36 tiles/sprites, 1 big font + system font).

## Controls
Arrow keys (or keypad) move the cursor, hold to repeat. Enter selects one of your units (cursor must be on it).
With a unit selected an arrow key makes one action in that direction (move, dig, pick up, deliver, ...).
Backspace / Esc releases the unit. **Space** ends the turn (added). After a win, Enter starts a new game.
No Ctrl key is used, so no browser shortcut clash.

## Structure
- `scripts/game.gd` (autoload `Game`): the board (flat arrays replacing `Xp[x].Yp[y]`: Floor, Stat, Typ, Life, Lifemax, Move, Movemax),
  level generation and all action rules (the big SWITCH in process CURSOR) in `act(from, to)`; signals drive the views.
- `scripts/board.gd`: `_draw()` of the 32x24 tiles, units, blood mask and AP dots; `queue_redraw()` on `board_changed`
  (replaces `REPAINT()` + `Map_Put`). The original background graphic 1 is completely covered by tiles, so it is not used.
- `scripts/cursor.gd`: Sprite2D cursor + input through `_unhandled_input`; key repeat via a Timer
  (original: first repeat after 5 frames, then every frame at 18 fps).
- `scripts/hud.gd`: "LP: x/y  AP: x/y" of the unit under the cursor with the converted font 1, plus turn text / win banner.
- `scripts/debug/autotest.gd`: `godot --headless --path . --quit-after 300 -- --autotest` (also `--screenshot=<path>` windowed).

## Rules ported (all costs as in the original)
- Level: rows 0-2 air, 3-10 grass (10% branch, 10% leaf), 11-23 earth (2/76 food store each for 105, 1/76 birth place, 2/76 trainer).
  Start: 2 workers per player on row 7 (x 4,6 / 27,25), holes at (5,7)/(26,7), dug start tunnels below.
- Layers: grass layer (rows 3-10) is separate from air above and from the underground; no stepping between them except via a hole.
- Grass / dug earth: move, 1 AP. Hole: drops to row 11 of that column (if free), 1 AP. Earth: only workers, 2 AP, becomes dug.
- Leaf / branch: only an unladen worker, 1 AP, becomes carrying leaf / wood.
- Food store (untouched): unladen worker takes food (store becomes empty, worker carries food). A leaf carrier refreshes an empty store.
- Birth place: a food carrier delivers, a new worker (50 life, 2 AP) appears there, carrier becomes plain worker.
- Trainer: worker -> weak fighter (+50 life), weak -> strong fighter (+50 life, +2 max AP); each use empties the trainer;
  a food carrier refreshes an empty trainer. Actions at stores/trainers do not move the unit.
- Unit overlays: blood mask below half life, AP dot red (0) / yellow (some) / green (full).

## Additions (the original is unfinished) - need a human play-test / balancing
1. **Turn passing**: original has `PlayerTurn` fixed at 0, player 2 can never act (his units start with 500 AP as a test hack).
   Space ends the turn, the next player's units get AP = max. Player 2 units start with 5 AP like player 1.
2. **Combat**: original has an empty "Interaktion muss kommen" branch. Moving into an enemy now attacks for 1 AP;
   damage by unit kind: worker 5, weak fighter 20, strong fighter 40 (guesses, `Game.DAMAGE`). No retaliation.
3. **Win**: a player with no units left loses (banner + Enter for a new game).
4. Turn indicator "PLAYER n   SPACE = END TURN" (system font, bottom left).

## Deviations / bugs
- Fixed: `Arbeiter` (worker flag) was only set when selecting a worker and never cleared, so a fighter selected afterwards could dig.
  Now computed from the unit type (fighters cannot dig).
- Original conditions `Typ==3 OR Typ==13 AND Stat>0` (store/trainer refresh) were read as the clearly intended
  `(Typ==3 OR Typ==13) AND Stat>0`.
- Kept original gaps: nothing uses wood; units that went down a hole cannot climb back (level change up is an empty comment in the PRG);
  air tiles are unusable; the "birth place used" tile (216) exists but is never shown since birth places are never emptied.
- HUD: the original text string contains spaces whose width DIV defined differently from the converter's guess, so the static texts
  ("LP:", "/", "AP:", "/") are placed individually at the positions implied by the original number anchors (100/120, 262/282).
- Free cursor: the original read arrow keys as a polled set (diagonals with two keys); port repeats the last pressed direction.
- No debug features existed in the PRG.

## Verified
- Headless import, run (300 frames) and autotest (30 checks: cursor input, hole, dig, leaf/branch, food, birth, trainer chain,
  level rules, turns, combat, win, restart) all clean.
- Windowed screenshot checked (`screenshot_gameplay.png`). Web export runs (see report).
- Not verified: feel of key repeat speed in a browser, combat balance.
