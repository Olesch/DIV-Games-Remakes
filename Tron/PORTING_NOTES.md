# Tron - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/OLTRON.PRG` (Oleg Yuschuk, based on DIV tutorial 1), 60 fps, 1024x768.
Assets: `div_convert.py game` -> `assets/fpg/oltron` (bg graphic 1, bike sprites 2/3), `assets/fnt/system`.
Run: main scene `scenes/main.tscn`.

## Controls
- Red (player 1): Left / Right arrows (or keypad 4 / 6) turn left / right. Blue (player 2): A / D.
- New: Enter / Space restarts the round, Esc quits. (Original: no restart, quit with Ctrl+Esc.)
- One turn per key press; you steer relative to your own heading. Turning twice quickly reverses you into your own trail.

## Mapping
| DIV | Godot |
|---|---|
| main code, `map()` process | `scenes/main.tscn` + `scripts/arena.gd` (`Arena`): graphic 1 as an `ImageTexture` sprite, an index array as hardness map (`pixel_at` = map_get_pixel, `put_pixel` = map_put_pixel), texture updated once per frame |
| `Tron(...)` process x2 | `scenes/light_cycle.tscn` + `scripts/light_cycle.gd` (`LightCycle`), exports for keys/colour/heading/start |
| Dir 1..4 with wrap | `enum Heading`, same arithmetic (left = +1, right = -1) |

Timing: runs at 60 physics ticks/s (= set_fps(60)). Each tick moves 11 pixels (inner loop `speedwait` 10 -> 11 iterations), the very first tick 101 pixels (initial `speedwait=100`): 660 px/s. Collision, trail painting and screen wrap happen per pixel step exactly like the original, so thin gaps cannot be tunnelled.

## Faithful details / original quirks kept
- Any non-zero pixel kills a cycle, including its own trail and the single stray pixel (palette index 129) at (673,190) in the original background graphic.
- Wrap: `x<0 -> 1023`, `x>1024 -> 1` (same for y with 768/767/1): the coordinates 1024 / 768 are one step off-map, where nothing is read or drawn.
- The collision check reads the new pixel before the wrap, as in the original.
- A dead cycle disappears, its trail stays. The survivor keeps driving (original had no win condition at all).
- Trail colours = palette 22 (red) and 54 (blue); bike heads are the 3x3 sprites 2 and 3.

## Deviations
- Turns come from key-press events (`_unhandled_input`) instead of polling both keys each frame; effect is the same except a very short tap between two frames is no longer lost, and pressing the opposite key while holding one now still turns (the original blocked turning until both keys were released).
- Added: "<colour> wins!" / "Draw!" message and restart (Enter/Space), Esc quit.
- No debug features existed besides commented-out code (speed-up on proximity, wall-less bounds check) - not ported.

## Verification
- `--import`, `--quit-after 300` clean. `-- --autotest` (scripts/debug/autotest.gd) drives both cycles with scripted turns for ~240 ticks, checks trails are painted and crashes detected: PASS.
- Screenshot `screenshot_gameplay.png` captured windowed. Web export built (see final report).
- Needs a human play-test: feel of turning at 660 px/s on real keyboards, whether original DOSBox speed was lower.
