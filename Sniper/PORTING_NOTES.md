# Sniper - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/SNIPGAME.PRG` (header "Tutorial 1", the process names are Sniper/Fadenkreuz/Ballon), 1024x768, 24 fps.
Assets: `div_convert.py game` -> `assets/fpg/snipgame` (+ DIV system font `assets/fnt/system`). Main scene
`scenes/options.tscn` (new options screen) -> `scenes/main.tscn`. The PRG has no title screen/text/score output.

## Controls
- Options screen: Up/Down select, Left/Right change, Enter start (on "ORIGINAL SETTINGS": reset); mouse: hover
  selects, left click / wheel up next value, right click / wheel down previous, click START. Esc quits (desktop only).
- Mouse moves the crosshair (relative motion, mouse is captured; Esc releases it, a click re-captures;
  Esc while it is free goes back to the options screen = the restart).
- Left mouse: all snipers fire at the crosshair (reload 40 frames). Up / Down arrows (or keypad 8/2): move the whole column (only while a sniper is not reloading).
- Right mouse: reloads the minigun snipers (75 shots).

## Options (new; owner's decision 2026-10-26; defaults = the original exactly)
Autoload `scripts/settings.gd` (`Settings`, session only, not saved) + `scenes/options.tscn` / `scripts/options_screen.gd`
(DIV system font at 2x, Heatfighter-style `> ROW <` menu, English upper case like the other ports' added screens).
| Option | Default (original) | Range |
|---|---|---|
| Snipers | 17 (lead at y 370 + 16 at 0..750 step 50) | 1-21; fewer keep the places nearest the lead, 18-21 use the 4 places of the commented-out `Sniper(95,570/170/470/270,...)` calls |
| Rifles / Miniguns / Grenade launchers | on / off / off | toggles, at least one stays on; several on = the column takes them in turn, top to bottom |
| Balloons | 1 per second (`FRAME(2400)`) | 0.25, 0.5, 1, 1.5, 2, 3, 4, 6, 8, 12 per second |
- Bodies: the lead sniper has one (original); every minigun / grenade sniper gets one too, as the commented-out block
  does (`SniperBody(100,y+14)` after each). Smallest completion: DIV's SniperBody always follows `Sniperfollo` (all
  those bodies would have stacked on the lead's), here each body follows its own sniper.
- The FPG has no separate minigun / grenade-launcher sniper graphic: the PRG uses graph 6 for every mode, so they
  look alike until they fire (grenade = graph 11 + Smoke graph 12, minigun = the normal bullet graph 8). Nothing missing.
- The "aim snaps after each salvo" quirk is kept (owner's choice): every sniper kicks the pointer.

## Mapping
| DIV | Godot |
|---|---|
| Main code | `main.gd`: lead sniper (95,370) + SniperBody + 16 snipers every 50 px, balloon `Timer` (1 s = FRAME(2400)); count/weapons/rate from `Settings` |
| Sniper | `sniper.tscn/.gd`, modes NORMAL/MINIGUN/GRENADE as an enum |
| SniperBody | `sniper_body.tscn` (z=1 -> behind, follows lead y+14) |
| Fadenkreuz | `crosshair.tscn/.gd` (virtual pointer, tremor rand(-8,8), x>=150, recoil) |
| Shot / Smoke | `shot.tscn` (Area2D, layer 2), `smoke.tscn` |
| Ballon | `balloon.tscn` (Area2D, layer 1, polls overlapping shots) |

Physics runs at 24 ticks/s (project setting) with physics interpolation, so one `_physics_process` = one DIV frame
(speeds are the original per-frame values: shot 70 px, balloon 2-9 px, column 3 px; reload 40, recoil kick -5,+2,+2,+1).

## Deviations / guesses
- DIV's `mouse.x/y` assignments (recoil) are done on a virtual pointer fed by relative mouse motion, because `warp_mouse` does not work in browsers. Mouse speed is 1:1 viewport px (DIV driver sensitivity unknown). Initial pointer = screen centre (guess).
- Balloon hit shape is a capsule approximating the oval (not pixel-exact); shot shape is the 140x3 beam.
- Faithful quirks kept: all 17 snipers fire together and each kicks the pointer by (-30,-200), so after a salvo the pointer sits at the top-left clamp (x=150, y=0); the column can be moved off-screen with Up/Down (no clamp); shots spawned off-screen die immediately; `score` is never shown.
- Minigun (mode 1) and grenade launcher + smoke (mode 2) exist in the PRG but its main code never spawns them
  (commented out); ported line by line and selectable on the options screen. Minigun: Drehzahl +6 per held frame
  while < 76, -5 every held frame -> ~3 s spin-up, then a shot every 2nd frame (x-5 for one frame, recoil
  -rand(30,50),-rand(80,100)), 75 shots, right button: Ammo=0, Drehzahl=0, frozen 36 frames (FRAME(3600)); the right
  button is checked after the fire block in the same pass, also while firing (2026-10-26 fix: was `elif`).
  Grenade: graph 11, advance(26), turns 2.75 deg/frame down to -90, smoke every frame, x-8 for one frame, recoil
  -rand(70,90),-rand(200,250), reload 40.
- Dead code not ported: `asteroid`, `new_coordinates` (leftover from the DIV tutorial).
- Debug-only: none in the original.

## Verified
- 2026-10-26 options: import + `--quit-after 300` clean; a temporary headless test (deleted) with 21 snipers, all three
  weapons, 4 balloons/s: 7/7/7 snipers + 14 bodies, timer 0.25 s, default heights == original, all three shot types
  fly, smoke appears, minigun reaches 75 ammo, reloads on right button and fires again, Esc returns to the options
  with the settings kept; existing `--autotest` still passes. Screenshots of the options screen and of a mixed game checked.
- Import + headless run clean; `-- --autotest` (skips the options screen; use `--fixed-fps 24 --quit-after 600`) fires continuously, moves the column, runs minigun and grenade snipers: no errors, balloons get popped. Screenshot checked.
- Needs a human play-test: mouse feel (sensitivity, captured mouse in browsers), recoil snapping feel.
