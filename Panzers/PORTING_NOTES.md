# Panzers - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/PANZERS.PRG` (Oleg Yuschuk), 24 fps, 1024x768. Assets converted with
`div_convert.py game` into `assets/fpg/panzers` (1 hull, 2 turret, 3 shell, 4 background).
Run: open the folder in Godot 4.7, main scene `scenes/options.tscn` (options screen, then `scenes/main.tscn`).

## Controls (physical keys, as in the original)
| | Player 1 | Player 2 |
|---|---|---|
| Turn hull (turret turns with it) | J left / L right | A left / D right |
| Drive forward | K | S |
| Turret only | U left / O right | Q left / E right |
| Fire (hold = automatic fire) | I | W |

Options screen: Up/Down select, Left/Right change, Enter starts, Esc quits (desktop only; in the web build
`get_tree().quit()` freezes the page, so `Game.quit_game()` is a no-op there and "ESC QUIT" is not shown).
Mouse: hovering a row selects it, click the < > arrows or START.
In the game: Esc = back to the options screen (the original needed Ctrl+Esc to quit), Enter after a round
= new round with the same options (as Heatfighter). No Ctrl-based keys are used, so nothing collides with
browser shortcuts.

## Game mode: options, hits, round end (owner's decision 2026-10-26)
The original is a sandbox (shells hurt nothing, no end). The owner asked to make it a game with an options
screen before playing:
| Option | Values | Default | |
|---|---|---|---|
| Life | OFF (SANDBOX), 1, 5, 10, 20, 30, 50, 100 hits | **30 hits** | hold fire = 24 shells/s, so 30 hits = 1.25 s of fire that stays on target: a grazing burst does not kill, a sustained one does |
| Camouflage | OFF / ON | **OFF** | ON = the original's `Graszeichner(1)`/`(2)` look (tanks painted with the grass greens, nearly invisible) |
Values live in the autoload `Game` (`life`, `camouflage`) for the session only; nothing is saved (`user://` stays empty).
- **Sandbox (Life OFF)** = exactly the previous port: shells pass through tanks, no HUD, no round end. The only
  difference is the options screen in front and Esc going back to it instead of quitting.
- **Hits:** a shell whose 5x5 picture touches the hull rectangle (graphic 1 is opaque over all 70x50 pixels) of
  another living tank hits it and disappears. A tank's own shells never hit it. The turret barrel is not a
  target. Plain rectangle test in `Shot._process` (no physics bodies).
- **Destroyed** at 0 life: big blast, the tank stops (no driving/firing) and stays as a wreck: hull and turret
  get the same per-pixel speckle as the grass, but in dark palette greys 1..4 (`Camo.ASH`).
- **Blast** (`scripts/blast.gd`): square pixels in the palette's fire colours 31..19 (yellow -> red) flying
  apart and cooling. Small on every hit, big on destruction. The original has no hit/explosion code (nothing
  commented out either; the only unused bits are the `Whatdo` local and `load_fnt("Olegs\Space.fnt")`), and
  PANZERS.FPG has no explosion graphics, so this is new and kept minimal in the palette.
- **HUD** (`scripts/hud.gd`, DIV system font at 2x): "PLAYER n   LIFE x" in the top corners; at the round end
  "PLAYER n WINS" (or "DRAW" if both die in the same frame) and "ENTER = NEW ROUND     ESC = OPTIONS".
  The round ends when at most one tank is alive; the winner can keep driving and firing.
- Texts are English, upper case (the original has no texts; identifiers are German; the other ports' added
  screens are English).
- Known limitation, kept on purpose (movement unchanged): a tank can still drive off screen, where shells
  cannot reach it (they are freed when they leave the screen).

## Mapping
| DIV | Godot |
|---|---|
| (new) options screen | `scenes/options.tscn` + `options_screen.gd` (`OptionsScreen`), settings in autoload `Game` |
| main code (load, tanks at (100,100) and (924,668), `put_screen`) | `scenes/main.tscn` + `main.gd` (+ new round end, `Hud` CanvasLayer) |
| `Panzer` + `Turm` | `tank.tscn` / `tank.gd` (hull Sprite2D + turret Sprite2D `top_level`, own absolute angle, positioned on hull control point 1 = (26,25) rotated with the hull instead of `get_real_point`) |
| `Schuss` + `Schussbild` | `shot.tscn` / `shot.gd` (Node2D, group `shots`): starts 40 px ahead of the pivot, 15 px/frame = 360 px/s, freed when fully off screen; the picture never rotates |
| `Graszeichner(4)` | `camo_grass.gdshader` / `camo.gd`: every opaque pixel gets a random one of palette colours 32..35 (dark greens). Done in a shader (hash of the texel position) instead of a 786k-pixel loop at startup |
| key scan codes | `game.gd` registers InputMap actions `p1_*`/`p2_*` with physical keycodes |

Timing (F = 24): drive 10 px/frame = 240 px/s, hull turn 7 deg/frame = 168 deg/s, turret keys 10 deg/frame = 240 deg/s,
fire every frame = 24 shots/s (accumulator, max 4 shots per rendered frame). Movement is delta based in `_process`.

## Deviations / guesses
- **Tanks are not camouflaged by default.** The original also runs `Graszeichner(1)` and `Graszeichner(2)`, which repaint the
  tank hull and turret graphics with the same random greens as the lawn, so the tanks would be almost invisible. This is
  probably a leftover of an unfinished game; the former internal switch `Tank.CAMOUFLAGE_TANKS` is now the Camouflage
  option (`Game.camouflage`, default off).
- The grass is generated procedurally with a different random sequence (original: `rand(32,35)` per pixel, same palette colours).
- Sub-pixel motion: DIV truncated `advance()` to integers every frame; here positions are floats.
- Original quirks kept: no scoring; tanks can drive off screen and never come back into bounds; shells have no limit.
  No hits only in the sandbox (Life OFF), see above.
- The turret in DIV lags the hull by one frame (reads `Point1` of the previous frame); not reproduced.

## Skipped
Nothing debug-related existed (`max_process_time`, `define_region`, `load_fnt` are commented out in the PRG).

## Verification
- `godot --headless --import`, headless run with `-- --autotest`: both tanks drive, turn, swing the turret and fire for 6 s;
  prints `AUTOTEST PASS` and quits (desktop only). No errors/warnings. The game and the autotest never write to `user://`
  (no hiscores/saves exist).
- `--screenshot=<path>` (with `--autotest`) saves a frame; `screenshot_gameplay.png` was made that way.
- Game mode (2026-10-26): `--import` and `--quit-after 300` clean; the smoke test above still passes (it skips the
  options screen and plays with the defaults). A temporary headless/windowed test (deleted afterwards) checked:
  keyboard on the options screen (Up, Up, Left -> 20 hits), tank 1 destroying tank 2 with 5 hits -> wreck and
  "PLAYER 1 WINS", Enter -> new round with both tanks alive, sandbox -> no hits/HUD/round end, camouflage on
  -> tanks invisible, Esc -> options screen. Screenshots of the options screen and the winner state were looked at.
- Needs a human play-test: feel of turning/driving speed, whether 30 hits is the right default, mouse use on the
  options screen.
