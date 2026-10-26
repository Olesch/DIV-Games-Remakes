# Minicosm - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/MINICOSM.PRG` (Oleg Yuschuk, homage to Microcosm), 24 fps, 1024x768.
Assets: converted with `div_convert.py game` into `assets/` (fpg/minicosm, fnt/minicosm, fnt/system).
Run: open the folder in Godot 4.7, main scene `scenes/title.tscn`.

## Controls
- Title: Left/Right (or +/-, keypad +/-) change difficulty 1 (hard) .. 5 (easy); Enter / Space / Esc or
  left+right mouse button together starts. One step per key press (original: one step per frame while held).
- Game: mouse aims both cannons (crosshair). Left button = left cannon (only below the top menu strip,
  y > 60), right button = right cannon. Click the buy menu (top strip, y < 61) with the left button.
- Second ship (after buying it): arrow keys (or keypad 4/6/8/2) steer/accelerate, Ctrl fires.
- Esc in game: back to the title screen (new; the original could only be quit with Ctrl+Esc).
- Hidden cheats of the original are kept: hold S+U+P = all Duks super, T+A+X = money 10000,
  A+R+M = hardest meteors. (They only work while at least one Duk lives, like the original.)

## How the DIV processes map to Godot
| DIV | Godot |
|---|---|
| GLOBAL variables, shop rules | autoload `scripts/game.gd` (`Game`): money, ammo, upgrades, costs, `try_buy()`, signals; enums/constants in `scripts/defs.gd` |
| Main code title loop | `scenes/title.tscn` + `title.gd` |
| Main code game setup | `scenes/game.tscn` + `world.gd` (spawns the 3 start Duks, reacts to purchase signals) |
| Canonleft/right (+fr, +be) | `cannon.tscn` (one scene, `side` export): back / barrel / front sprites, reload `Timer` |
| Fadenkreuz | `crosshair.tscn` (own CanvasLayer, always on top) |
| Shot | `shot.tscn` (Area2D, group `shots`) |
| Meteor (+ CLONE) | `meteor.tscn` (Area2D, group `meteors`); splitting instantiates a twin |
| Explosion | `explosion.tscn` (AnimatedSprite2D, 5 frames @24 fps, scaled by size%) |
| Duk / Bird / Potion | `duk.tscn`, `bird.tscn`, `potion.tscn` (groups `duks`, `birds`, `potions`) |
| Meteorenlos / Schwerer | `meteor_spawner.tscn`, `difficulty_ramp.tscn` (Timer based) |
| Kaufmenu + KaufMenuKnoepfe | `hud.tscn` with 12 `buy_button.tscn` (Control, click zone 60x61) |
| Money text, MunitionsZeiger | `PixelLabel` (DIV `write` anchor/alignment, bitmap fonts), `ammo_indicator.tscn` |
| PlayerTWO / PLTWOUP | `player_two.tscn` (hull + turret sprite) |
| Atom | `atom.tscn` |

Physics layers: 1 meteor, 2 shot, 3 duk, 4 bird, 5 potion. Meteors detect shots+birds, Duks detect
meteors+potions (polled with `get_overlapping_areas()` every physics frame, first hit only, like `collision()`).
Draw order: DIV `z` -> `z_index = -z` for entities (Duks above meteors, birds below, cannon barrel/front above
shots, cannon base behind everything); buy menu, money and ammo lights are on a HUD CanvasLayer, crosshair on a top layer.

Timing (F = 24): per-frame speeds x24 (shots 10 px/frame -> 240 px/s, 480 for rocket types >= 1, meteor drift/spin,
Duk 1-2 px/frame, birds 3-5, potion fall 3, ship turn 10 deg/frame, ship velocity +-1 px/frame per frame (max 9 / -6)).
`FRAME(n)` timers: reload `(8000 - max*750 - reload*500 - 250*(d-3))/100` frames, meteor interval
`rand(5200+200(d-3), 7200-ramp/5+300(d-3)) - ramp` hundredths of frames, ramp step 2..5 frames, ship cooldown
`45 - reload*6` frames, death animation 4x4 frames, explosions 5 frames.

## Faithful details worth knowing
- Costs: cannon `80-20(d-3)` (+20 per cannon bought, shared by both sides), Duk `150-25(d-3)`, potion 400, bird
  `birds*(20 or 5)+50`, atom `300-50(d-3)` (+100 each), reload 1500 / 3000, rocket 800 / 1200 / 2500 (-2/-3/-3 ammo
  capacity per cannon), bird breeding 1000, potion limit 3000, magnet 750, second ship shown/required 5000 but only
  3000 charged (original quirk, kept).
- Tax: each Duk pays 3 (+d-3 if d>3, +5+d-3 more if super) whenever its walk counter runs out. The original compares
  the counter against a fresh `rand(50,100)` every frame; I roll the number of frames the same way (loop) and wait
  that long with a Timer, including the "standing counts twice" behaviour.
- Ammo above capacity (re-checked 2026-10-26 after the owner could not reproduce it in DOS): the claim is right in
  code and reachable, but invisible on screen. `Canon*fr` checks `Munition<Max` once, then sits in the reload
  `FRAME(...)` and adds the round without re-checking (lines 320-323 / 381-384); the atom bomb sets ammo = max
  (610-611) and rocket upgrades lower max without touching ammo (632-647). So an atom bought while a cannon is
  reloading gives max+1, and a rocket upgrade leaves ammo above the new max (capacity can even become 0 or negative
  if you upgrade rockets before buying cannons). The overfill is at most one round per refill, because the next loop
  sees `Munition<Max` false. `MunitionsZeiger` never draws a light above Max (938-946), so the extra rounds only
  show up as shots that do not put a light out. Repro in DOS: earn 50 so you have 300, fire one left shot (lights 1/2),
  buy the atom within about 2.7 s, wait for the reload, then fire: the first shot leaves both lights full. The port
  does the same (`Game.add_ammo`, `cannon.gd` reload timer, `ammo_indicator.gd`); nothing is clamped.
- Homing rockets (type >= 2) emulate the 50 `get_id` lookups per frame (cycling through all meteors plus one empty
  result) with 7 degrees per lookup, so they lock on metal meteors within 150 px almost instantly. Magnet = homing
  only starts after 16 frames (the title text says exactly that).
- Shield rocket (type 3) survives its first hit and turns into a homing rocket.
- Atom bomb: instead of every meteor spawning a rocket on itself each frame for ~4 frames, the Atom node emits 4
  pulses (1/24 s apart) and every meteor takes one hit per pulse - same result (everything on screen dies).
- No win/lose condition exists in the original: the game runs forever, even with no Duks left.

## Deviations / guesses
- Skipped debug features: F1-F4 fps/skip changing and F5 fps readout (`fpsa/fpsb`).
- Title screen difficulty: one step per key press instead of per frame. OS cursor is visible on the title screen
  and hidden in game.
- Buy buttons are Controls: the original tracked `mouse.left AND mouse.y<61` with an anti-fast-click flag, so
  dragging a held button into the menu also bought; here a buy needs the press to happen on the button.
- The magnet button is only clickable when visible (original: it was hidden until rocket level 2 but its click zone
  was still active).
- Collision shapes are approximate (circle r34 asteroid, capsule for double asteroids, circle r22 Duk, 40x20 rocket,
  r11 bird, r14 potion) instead of pixel-exact overlap; `out_region` uses the rotated sprite's bounding box.
- Super Duk flee logic: original looks at meteors in `get_id` order and the last one within 150 px wins; kept
  (last in group order).
- Esc returns to the title (new). Mouse position is the viewport position (stretch mode `viewport`, aspect `keep`).
- Potion rest position y=711 (loop-variable value after `FROM y=600 TO 710 STEP 3`) - guess.
- Meteor spawn height is y=0 (the PRG passes no y). Birds spawn at x=0/1029 and only start walking once the edge
  clamps trigger (as in the original).

## Unclear in the original
- `get_dist(0)` / `near_angle` behaviour when `get_id` returns 0 inside the 50-iteration loops: treated as "no
  meteor" for that lookup.
- Exact number of frames the atom bomb flag stays active (4 `FRAME`s, but depends on process order): 4 pulses used.

## Verified vs. needs a human play-test
Verified (headless and windowed on this machine):
- `godot --headless --import` clean; title and game scenes run with `--quit-after` without script errors/warnings.
- `scripts/debug/autotest.gd` (`godot --path . res://scenes/game.tscn -- --autotest [--nofire] [--screenshot=file.png]`)
  buys every shop item, fires both cannons with all four rocket types, flies/fires the second ship, spawns all
  meteor kinds at the hardest ramp, buys the atom bomb and quits after 12 s: no runtime errors.
  `scripts/debug/title_flow.gd`: title -> difficulty change -> start -> Esc -> title works (cost changes with difficulty).
- Screenshots (`scripts/debug/capture.gd`) of title and gameplay checked visually: sprites, offsets, bitmap
  fonts, ammo lights, buy menu with ghosted buttons, Duks/birds/potions, cannons and rockets look right.

Not verified / needs play-testing by a human: real mouse feel (cannon aim, click latching, hidden cursor),
balance of speeds (all converted from 24 fps values, untested against the DOS original), homing strength,
meteor collision feel with approximate shapes, the second ship handling, buy-button click zones with the
real mouse, atom bomb visuals, and window scaling on other resolutions.
