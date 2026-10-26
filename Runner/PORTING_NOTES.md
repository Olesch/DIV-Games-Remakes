# Runner - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/RUNNER.PRG` (Lukas Schw. and Oleg Yuschuk), 24 fps, 640x480.
Assets: `div_convert.py game` -> `assets/fpg/runner` (graphics 1-5), `assets/fnt/runner`, `assets/fnt/system`.
Main scene `scenes/game.tscn`. Debug: `godot --path . -- --autotest [--screenshot=<png>]`.

## Controls
- Player "RECHTS" (upper runner, y=190): Left / Right arrow (or keypad 4 / 6) - hammer them alternately.
- Player "LINKS" (y=250): A / D.
- Enter / Space after the race starts: restart (new; the original had no restart, only Ctrl+Esc).
- Pressing a runner's keys before "LOS" is a FOUL: that runner is frozen for the whole race.
- First to x >= 600 wins ("GEWONNEN"), the clock stops.

## Mapping
| DIV | Godot |
|---|---|
| main code (texts, FRAME(4800/3600/3600)) | `scripts/game.gd`: small state machine READY(48 ticks) / SET(36) / GO(36) / RACING, labels `PixelLabel` |
| Maennchen | `scenes/runner.tscn` + `runner.gd` (`action_prefix` p1/p2; key state arrives via `_unhandled_input`) |
| Timecounter | `_tick_clock()` in game.gd |
| put_screen(0,5) | Sprite2D with graphic 5 |

Physics tick rate is set to 24 (the DIV rate), so one `_physics_process` call = one DIV frame and the integer
arithmetic (`vel += 3` per alternate press, `vel -= vel/4`, `x += vel/2`) is identical.

## Original quirks kept
- Clock: "Time24" counts up to 24 and wraps at >24, so one clock "second" is 25 ticks (~1.04 s real time). It runs
  from the start signal (during the "LOS" text) but is only displayed afterwards, with the odd layout of the original
  (seconds right-aligned left of x=310, ticks above a static "24").
- A key held down gives only one push (the left/right toggle needs the opposite key next).
- Both pressed at once = no push. Loser keeps running after the winner has finished (can also show GEWONNEN).
- The font has only digits and capitals; the dots in "AUF DIE PLAETZE..." are not drawn (same as original).

## Deviations
- FOUL text stays visible (in the original the final `delete_text(all_text)` after "LOS" erased it, an accident).
- Restart key added. Unused `Keyu` parameter (W / Up) and the commented-out jump code were not ported.
- Web build: no Ctrl keys are used, no web-specific keys needed.

## Verified
- Headless import, run and autotest (false start for P1, alternating keys for P2 to the finish) pass; windowed screenshot checked;
  Web export succeeds (wasm brotli-compressed).
- Needs human play-test: feel of key hammering (24 Hz tick, input is latched on press/release events).
