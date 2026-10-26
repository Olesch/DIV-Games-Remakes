# Heatfighter - Godot 4.7 port notes

Source: `DIV/PRG/Olegs/HEATFIGH.PRG` (Oleg Yuschuk, 2-player 2D fighting game), `set_fps(100)` in the original (the port runs at 60 ticks/s, see Timing), 640x480.
Assets: `div_convert.py game` -> `assets/` (fpg/heatfigh, hftemp, hfchain, hfeigen, fnt/system),
plus `tools/bake_assets.py` (palette-swapped player-2 PNGs `assets/fpg/*_p2/` and `scripts/gfx_data.gd`
with sizes + control point 0 of every graphic). Run: open the folder in Godot 4.7, main scene `scenes/title.tscn`.

## Controls
- Title: Up/Down select, Left/Right change (human/computer, Template/Chain/Eigen per side), Enter starts.
  Original main code: P1 human, P2 computer, both "Chain" (this is the default).
- Player 1: X left, V right, D jump, C duck, 1 = light punch, 2 = strong punch.
- Player 2: cursor keys, 9 = light punch, 0 = strong punch (added alternatives: `,` light, `.` strong).
  (The originals 3/4 and -/+ buttons ("variant punch", "special") were read but never used; not ported.)
- Block: hold the direction away from the enemy (walking back = standing block, ducking = low block,
  in the air = jump block). Blocks only help against the matching attack height (see rules below).
- Specials (motion within ~10 ticks, as if facing right):
  - Template/Chain: Down, Back + light punch (costs 1000 mana): charge, dash, flurry of blows.
  - Eigen: Down, Forward + light punch (2500 mana) = fireball; Back, Down, Forward + strong punch
    (5000 mana) = homing energy ball. Holding Up in a jump past the apex makes Eigen hover (burns mana).
- Esc = back to the menu; Enter after a K.O. = rematch. No Ctrl combinations are used (browser safe).

## Structure (DIV process -> Godot)
| DIV | Godot |
|---|---|
| globals `Dontmove`, `HitDontWait`, `Player*_File` | autoload `scripts/game.gd` (`hit_pause`, setup, InputMap actions) |
| main code (creates 2 Fighters, `Write_Int` numbers, `DontMovePlus`) | `scenes/arena.tscn` + `arena.gd` (counts `hit_pause` down after the fighters), `hud.gd` |
| PROCESS Fighter, blocks "Template" and "Eigen" | `scenes/fighter.tscn` + `fighter.gd`; per-character numbers in `fighter_profile.gd` (data-driven attack table: reach, window, damage, stun, launch, spark) |
| KI blocks | `fighter_ai.gd` (same per-tick odds, one function per character block) |
| LookForMove | `Fighter._special_motion()` (button history `last_buttons` = LB[1..5]) |
| AnimHau / EnergyLoad | `hit_effect.tscn` (translucent spark, size +4 / -7 per tick) |
| SpezialAnim | `afterimage.tscn` |
| Schuss_Eigen_1/2 | `shot.tscn` (kind 1 fireball, kind 2 homing ball) |
| HauPlatz, SMTC, Minifight, `MODE=1` test marker | not ported (debug/test mode) |
| `convert_palette(Player2_file, 1..100, +16)` when both fighters use the same character | pre-baked recoloured PNGs (`*_p2`), used for player 2 in that case |

## Timing
**Speed: 60 ticks/s by the owner's decision (2026-10-26)** instead of the original's `set_fps(100)`: the same
per-tick logic with fewer ticks per second, so everything runs uniformly at 60% of the original speed
(what `set_fps(60)` would have done in DIV). Nothing is converted to seconds; `Defs.FPS` = 60.
Per-tick approach (guide section 5): `physics/common/physics_ticks_per_second = 60` and physics
interpolation on; one `Fighter._step()` per tick, no delta. All values are DIV units (resolution 100:
hundredths of a pixel per tick). The order of one step is the original's (input, button history,
shove, walls, states 1-4, block/damage resolution, stun/SLZ, states 5-21, mana), including the
quirk that a state change inside the step lets the next state's block run in the same tick.
Fighter 1 steps before fighter 2; the global hit pause is decremented after both (DontMovePlus had
priority -100), so the original asymmetry is kept: `Dontmove=HitDontWait` (0) after being hit cancels
the attacker's freeze if the victim steps after the attacker.

## Rules (as in the original)
- Life 6000, mana starts at 0 and regenerates `base + (6000-life)/divisor` per tick (Template 8/500, Eigen 4/1000);
  negative mana regenerates at half speed (specials only need mana > 0, so mana can go negative).
- Attack height vs block: low block (duck, back) stops duck attacks (10% damage, no stun) and cannot stop standing
  attacks (they just miss a ducking fighter); standing/jump block reduces standing/air attacks to 10%
  but lets low attacks through; ducking dodges standing attacks, lying fighters dodge everything standing/air.
- SLZ (stun): each hit subtracts; below 0 the fighter is stunned (HIT), below -500 launched (FLY) then lying (LIE);
  recovery speed grows with stun length (Template: sqrt formula + wait counter; Eigen: fixed -10 and a 90-tick cap).
- Walls bounce jumpers and flying fighters (flying ones lose life from the impact).

## Deviations / additions
- **Menu and K.O.:** the original had no menu and no win/lose logic (life just went negative). Added the
  setup screen and a round end at life <= 0 with rematch/menu (fighters keep sliding while the loser falls).
- Template-character fix: the original never set `StehPosition` for Template/Chain, which made Eigen
  fireballs unblockable against them. `stance` is set for both characters.
- Floor and HUD: the original had a black screen with three numbers per fighter (stun at y=100, life y=125,
  mana y=440, kept at those positions). Added life/mana bars, names and a floor line; no background in the original.
- F1-F7 debug keys (fps change, palette test) and `MODE=1` test markers skipped.
- `Fighter(1,1,..)` "Template" uses HfTemp.fpg, which has no graphics 6, 14-18 (special/duck-attack frames):
  like DIV, a missing graphic draws nothing, so that character is invisible during those frames. Chain
  (HfChain.fpg) is complete, Eigen (HfEigen.fpg) too. HfClaw.fpg / Claw.map / Arena.fnt are commented out in the PRG
  (Claw.map is missing) and were skipped; text uses the system font.
- Hit sparks come from Heatfigh.fpg (file 0); Heatfigh.fpg graphics 1, 2, 5 (1000x1000 test-mode canvases) were deleted.
- Only 3 asset-less original details guessed: spark z (-10 -> in front), afterimage stages (5 ticks each), sprite flip
  around control point 0 (the drawn graphics face right).

## Verification
- `--import` and `--quit-after 120` clean (no script errors/warnings).
- `scripts/debug/autotest.gd`: `godot --headless --fixed-fps 2 --path . -- --autotest [--scripted] --chars=a,b --ticks=N`
  runs full matches (CPU vs CPU for Template/Chain/Eigen pairs, and a scripted player 1 that walks in and
  fires every attack and both specials). All states (stand..fly, lie, all 6 attacks, specials, fireballs, hit pause)
  were visited, KOs trigger, no runtime errors.
- Windowed screenshots of Eigen fireball and Chain mirror match looked right.
- Web export succeeds (pck ~0.4 MB); not loaded in a browser by me.
- **Needs a human play-test:** feel/balance at 60 ticks/s (owner's choice; was 100 Hz like the original), CPU difficulty, exact hit-spark timing (+-1 tick), key comfort
  (P2 uses 9/0 like the original), whether Template (HfTemp) missing frames matter.
