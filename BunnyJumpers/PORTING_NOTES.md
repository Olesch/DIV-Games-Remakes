# BunnyJumpers - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/BUNYJUMP.PRG` (Oleg Yuschuk), 1024x768, 24 fps. Assets via `div_convert.py game`
(`assets/fpg/bunyjump`: graphic 1 = background, graphic 2 = bunny, cp0 = (15,31) = feet).
Main scene `scenes/options.tscn` (options screen, new), the game is `scenes/main.tscn`.

## Controls
- Bunny 1: arrow keys (numpad 8/4/6/2 also, as in DIV scan codes). Bunny 2: W A S D.
- Up = jump (only while standing), left/right = accelerate on the ground (max 6 px/frame), release = friction.
- Esc (new): back to the options screen. Options screen: Up/Down select, Left/Right change, Enter play.
- No Ctrl keys are used, so the browser Ctrl+W/T/N problem does not apply.

## Options screen (new; owner's decision 2026-10-26)
The original started playing at once. Now `scenes/options.tscn` (`scripts/options_screen.gd`) comes first,
in the style of Heatfighter's setup screen: DIV 6x8 system font (`assets/fnt/system`, converted with
`div_convert.py sysfont`; `scripts/pixel_label.gd` = DIV write()), `> ROW <` selection, keyboard only.
- **Extra bunnies 0-50, default 0** (= exactly the original game: two player bunnies). Value in autoload
  `Game.extra_bunnies` (`Game.MAX_EXTRA_BUNNIES`), kept while the game runs, not saved to disk.
- Extra bunnies follow the original's commented-out loop `FROM x=0 TO 10; Bunny(rand(100,924),rand(100,668)); END`
  (that loop made 11, not 10): random start in x 100..924, y 100..668, and no keys passed, so no control and
  no AI - they only fall, land, bounce off ceilings and are obstacles that turn player bunnies around (their
  own x speed is always 0, so a bump cannot move them). `main.gd` adds them before `Bunny1` in the tree
  because the loop ran before the two player bunnies were created (they act first each frame).
  `Bunny.action_prefix = ""` = no keys.
- A random start inside a bottom block can make a bunny fall out of the map; in DIV it would fall unseen
  forever (and its per-frame step count would keep growing), so the port frees a bunny once it is 64 px
  below the map. Player bunnies cannot get there.
- Esc in the game goes back to the options screen (the original had no Esc). The stomp block stays unported.

## Mapping
| DIV | Godot |
|---|---|
| Main code (put_screen, two Bunny calls) | `scenes/main.tscn` (background Sprite2D + two `bunny.tscn` instances) |
| Process Bunny | `scripts/bunny.gd` (`class_name Bunny`, group `bunnies`) |
| map_get_pixel(0,1,x,y) hardness map | `IndexMap` resource `assets/terrain.res` (indices.bin graphic 1, zstd-compressed to ~2.7 KB), autoload `Game.terrain_at()` |
| collision(TYPE Bunny) | `Game.bunnies_overlap()`: pixel-exact test of the two bunny masks |
| key(...) | InputMap actions `p1_*`/`p2_*` registered in `game.gd` (physical keys) |
| commented-out `FROM x=0 TO 10; Bunny(...)` | `main.gd` `_spawn_extra_bunnies()` (count from the options screen) |
| (none) | `scenes/options.tscn` + `scripts/options_screen.gd`, `scripts/pixel_label.gd` |

Timing: the original logic is integer, step-by-step per frame (up to 13 one-pixel steps vertically, up to 5
horizontally, pixel tests after every step). Per the guide's per-tick option, `physics_ticks_per_second=24` and
`Bunny._physics_process` is exactly one DIV frame (no delta). Rendering is not interpolated (looks like the
original 24 fps). Colours: 22 = platform top (land when y_speed > -4, so rising bunnies pass through),
41 = ceiling (bounce), 54 / 73 = left / right block walls (reverse x speed).

## Deviations / original quirks
- The `WHILE(Treffer=get_dist(TYPE Bunny))` block (stomp / "TODESCRASH" that sent the lower bunny to 100,100) is
  not ported: `get_dist(TYPE ...)` does not return a distance to a bunny, `Treffer.x` then addressed an arbitrary
  id, so it never did anything useful. This is a guess about the original's behaviour; unverified.
- Bunny-vs-bunny: only the sideways bounce of the `Collision` block exists (abs(dx) > abs(dy)); vertical overlaps do nothing.
  Kept: the other bunny gets `Kontakt` and flips its x speed at the end of its own frame.
- Esc returns to the options screen (new); the original had no Esc/quit key. Bunnies can leave nothing but the screen interior (walls are the frame edge blocks).
- Terrain lookups outside the 1024x768 map return 0 (as in DIV).
- The background graphic's colour 0 is transparent, so the screen shows black inside the playfield (as DIV).
- Web: Esc (new) also leaves browser fullscreen; otherwise nothing key-related changed.

## Verified / needs human play-test
- 2026-10-26 (options): import clean, `--quit-after 300` clean (options screen and `main.tscn`),
  `-- --autotest` passes, `-- --autotest --extra=10` passes (the autotest skips the options screen;
  `--extra=N` sets the count). A temporary test (deleted) with 10 and 50 extra bunnies: all spawn in the
  loop's rectangle before the players, all move/land, none leaves the screen except ones freed after falling
  out of the map; 50 extras cost ~1.3 ms per tick. Windowed screenshots of the options screen and a game with
  10 extra bunnies looked right.
- Verified: import clean, headless run clean, `-- --autotest` (use `--fixed-fps 24`) passes: both bunnies land,
  jump to speed -25, stay on screen, direction changes happen; windowed screenshot looks right.
- Needs play-test: feel of the bunny-bunny bounce and whether the omitted stomp block mattered.
