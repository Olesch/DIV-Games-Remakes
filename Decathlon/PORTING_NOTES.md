# Decathlon - porting notes

Godot 4.7 rewrite of `DIV\PRG\Olegs\DECATLON.PRG` (hammer-throw event). 800x600, default 18 fps in the
original (no `set_fps`), so `physics_ticks_per_second = 18` and all logic runs once per physics tick
(= one DIV frame): the arm/ghost animation steps at 18 Hz like the original, nothing is interpolated.

## Controls
- Space: first press starts the swing (upper arm), second makes the forearm swing too, third releases.
  After the landing Space starts a new attempt.
- Left / Right (arrows or numpad 4/6) alternately, starting with Left, once the swing has started:
  each correct press adds 5 to the speed meter (max 50, decays by 1 + meter/17 per tick).
  Space is never needed after the third press; if the arm swings all the way round (angle < 0) the
  release is forced.

## Mapping
| DIV | Godot |
|---|---|
| GLOBALs Spacestufe, Movement, Weite, Hiscore | autoload `Game` (`stage`, `movement`, `distance`, `hiscore`, signals) |
| Arma / Armb (jointed arm, `get_real_point(1)`) | `ArmSegment` scene (UPPER / LOWER), joint = control point 1 rotated around control point 0, truncated to int like DIV; the lower segment hangs on the upper joint and, on release, emits the joint's per-tick displacement as throw velocity (DIV: Accx/Accy) |
| Specani (ghost afterimage, flags=4, z=50, 28 frames) | `Ghost` scene (50 % alpha, behind the arm, 28/18 s) |
| Movementometer | `Meter` node (edge-triggered input via InputMap actions) |
| main LOOP / put_pixel throw | `Main` (phases WINDUP, RELEASED, FLYING, RESULT) and `TrailCanvas` (Image-backed sprite, palette colours from `palette.json`) |
| write_int(0,...) | `PixelLabel` with the converted system font at the original anchors (Movement 200,100; distance 400,200; hiscore 600,100) |
| load/save sav\decatlon.dat | `user://decatlon.dat` (one int32); default 1004 = the value in the original DAT |

Throw: starts at (80,580), 5x5 grey blob per tick (`15 - 3|dx| - 3|dy|`) plus a mid-step pixel of colour 5,
gravity +1 px/tick^2, ends when y > 600; distance = x - 80.

## Deviations / guesses
- Space and Left/Right are edge events (InputMap `is_action_pressed`) instead of DIV's key polling with
  "antifast" flags; behaviour is the same except that a Space held across a restart is not counted.
- After the throw Space needs a fresh press to restart (DIV: any frame with Space down, even if still held).
- Added a one-line control hint at the bottom (the original shows only the three numbers).
- Process order within a tick assumed: main, meter, upper arm, lower arm.
- The arm angle `< 0` check uses the raw angle (no normalisation), as read from the source.
- `get_real_point` truncation: `Vector2i()` truncates toward zero; DIV may round differently by 1 px.
- Web build uses the same keys (no Ctrl/W/T/N involved).

## Verified / not verified
- Verified headless: `--import`, run clean, `-- --autotest` plays 3 attempts (pumped, unpumped, forced release
  by swinging round) with no errors; windowed screenshot looked right (`screenshot_gameplay.png`); web export.
- Needs a human play-test: feel of the swing timing/pumping, how far a good throw goes compared with the
  1004 record, exact distance vs. original (1 px rounding).
