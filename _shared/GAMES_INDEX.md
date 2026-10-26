# Oleg's DIV games - index

Source folder: `D:\Prog\Godot\DivRemake\DIV\PRG\Olegs\` (65 files). Graphics: `DIV\FPG\Olegs\`,
fonts: `DIV\FNT\Olegs\`, maps: `DIV\MAP\`, palettes: `DIV\PAL\`, data/saves: `DIV\Saves\`, `DIV\DAT\`.
No game loads any sound (no `load_pcm`/`sound` anywhere) - all ports are silent unless you add sound.

All referenced assets were resolved and converted successfully with
`python _shared/tools/div_convert.py game <PRG> <assets>` except where marked **MISSING**.
Path resolution follows DIV: given path relative to the DIV dir, then the type's default folder
(`FPG\`, `FNT\`, `MAP\`, `PAL\`, `PCM\`, `DAT\`), then the bare file name there, then the DOS 8.3
truncated name (e.g. `Schluessel.map` -> `MAP\SCHLUESS.MAP`; `olegs\mandbrot.map` -> `MAP\MANDBROT.MAP`;
`sav\decatlon.dat` -> `DAT\DECATLON.DAT`).

Complexity: **S** < 300 lines, **M** 300-1000, **L** 1000-2000, **XL** > 2000 (DIV lines incl. comments).
"FPS" = `set_fps()` value (frames per second the per-frame speeds are tuned for; DIV default 18 if not called).
Files marked *(edited 2026)* were modified by the user recently (Oct 2026) - probably the ones he cares most about.

## 1. Real games to port

| Game (PROGRAM name) | File | Size / lines | Mode, FPS | Loads (all exist unless noted) | What it is | Cx |
|---|---|---|---|---|---|---|
| Minicosm *(edited 2026)* | MINICOSM.PRG | 23 KB / 1060 | 1024x768, 24 (F1-F4 change fps) | Olegs\Minicosm.fpg, Olegs\Minicosm.fnt | "After Microcosm": meteors fall on little walking "Duks"; two mouse-aimed corner cannons (left/right button) shoot rockets; Duks pay tax; top buy-menu (more ammo, Duks, potions = super Duk, birds, atom bomb, homing/magnet rockets, 2nd player ship). Difficulty select 1-5 on title screen. Uses CLONE (meteor splitting), FRAME(n) timers, write_int. | M/L |
| Castle *(edited 2026)* | CASTLE.PRG | 51 KB / 1758 | 800x600, 24 | olegs/Castle.FPG, Olegs\Castle.fnt; data: saves/Level1.dat, saves/Level2.dat (level maps, int32 dump of `Map[35].Layer[1].Xpos[39].Ypos[29]`), save slots Saves\castle1..4.dat | Top-down dungeon action-RPG: hero with sword/bow/magic, keys, potions, scrolls, ogres/orcs/ghosts, trapdoors, secret passages, 6x6 room map, campaigns, save/load slots, difficulty. Room layouts come from the Level*.dat files (made with CASTEDIT/TRANSLAT). | L |
| Siege *(edited 2026)* | SIEGE.PRG | 63 KB / 2903 | 320x240, 18 (default) | olegs\siege.fpg | 2-player (same keyboard; KI process for AI exists but is commented out) siege battle: each player has a 6x5 field of element tiles (wood/metal/fire/magic) used to build units (warriors, archers, rams, bombers, catapults, ballistas, knights, mages, elephants, towers, workers...) that attack the other castle. Splash pages 80-85 first. | XL |
| Atome (Atoms) *(edited 2026)* | ATOMS.PRG | 16 KB / 723 | 640x480, 18 | Olegs\Atoms.FPG, Olegs\Atoms.FNT; hiscores Saves\ATSCEA.DAT / ATSCHA.DAT (save only) | Puzzle: place atoms with 1-4 connections on an 8x8 grid so they form complete molecules; bombs remove atoms; easy/hard mode, points, hiscores. Keyboard (cursor, Enter, Backspace, Esc, H = rules). | M |
| S-Type | S-TYPE.PRG | 66 KB / 2820 | 800x600, 40 (F-keys) | Olegs\S-Type.fpg, Olegs\S-Type.fnt, S-Type2/3/4.fnt (digit fonts) | R-Type style horizontal shoot'em-up for 1-4 players: weapon types, companion pods, shield, shop between waves (money, lives), snake colonies, jump shooters, bombs, end boss with cannons/lasers/shield. | XL |
| Heatfighter | HEATFIGH.PRG | 134 KB / 4808 | 640x480, 100 (fpsa/fpsb, F-keys) | Olegs\Heatfigh.fpg, HfChain.fpg, HfEigen.fpg, HfTemp.fpg, Olegs\Arena.fnt (commented: HfClaw.fpg, Claw.map) | 2-player 2D fighting game: walk/jump/duck, light/strong attacks standing/air/ducking, blocks high/mid/low, special moves via button sequences, hit pauses, energy loading, projectiles; per-player character FPGs recoloured with convert_palette. `MODE=1` (test mode) is set in this file. | XL |
| Miniship | MINISHIP.PRG | 35 KB / 1361 | 800x600, 30 (F-keys) | Olegs\Miniship.fpg (S-Type.fnt commented) | Up to 4 ships (human or PC Easy..King) fight around a planet with gravity; energy for flying/shots/rockets/teleport/shield, particles, asteroids, menu to configure players. resolution=100 sub-pixel physics. | L |
| Lommings | LOMMINGS.PRG | 31 KB / 947 | 320x240, 24 | olegs\Lommings.FPG, Olegs\Lommings.FNT | Lemmings clone: levels are graphics (900-950, 1000) with entrance/exit control points; skills climb, umbrella, jump, explode, ladder, stopper, dig > \ V; terrain edited with map_put_pixel / map_xput into graphic 1; mouse-driven skill buttons. | M/L |
| Stranded | STRANDED.PRG | 24 KB / 987 | 800x600, 24 | Olegs\STRANDED.fpg (25 MB!) | Island survival: hero walks a tile map (scroll window with parallax background), hunger/thirst/health, searching/taking items (berries, stones, branches, herbs...), combining, sleeping, day/night clock, mini-map/radar. | M |
| Siedler | SIEDLER.PRG | 31 KB / 1143 | 640x480, 24 | Olegs\Siedler.fpg, Olegs\Space.fnt | Settlers-like: settlers on a tile map cut trees, carry wood/clay, building sites; mouse buttons; scroll. Header comments list known bugs (houses cannot be finished, clay cannot be collected) - unfinished. | L |
| Ollwars | OLLWARS.PRG | 18 KB / 767 | 640x480 (sets 1024x768 first), 24 | Olegs\Ollwars.fpg, Olegs\OlwUnits.fpg, Olegs\Space.fnt | 2-player split-screen real-time strategy (two scroll windows + regions): grass/clay fields, units, headquarters, radar mini-map, mouse selection/move/attack; unit colours via convert_palette. Probably unfinished. | M |
| Huhnshot | HUHNSHOT.PRG | 12 KB / 602 | 800x600, 24 | Olegs\Huhn.fpg, Olegs\Huhn.fnt | Moorhuhn-style chicken shooting: horizontally scrolling panorama (manual scroll x0), birds at various depths, 6-shot magazine with reload, 90 s timer, combo/bonus targets (flowers, mountains, castle ruin, clock), score/accuracy screen. Mouse. | M |
| WormBattleWarriors | UNDWORLD.PRG | 27 KB / 776 | 320x240 | Olegs\UndWorld.FPG, Olegs\UndWorld.FNT | Turn-based 2-player underground strategy on a 32x24 grid (workers dig earth/collect leaves, wood, food; fighters; spawn places). Redraws via REPAINT. | M |
| GigaMaze | GIGAMAZE.PRG | 9 KB / 440 | 640x480, 40 | Olegs\Gigamaze.fpg, Olegs\Gigamaze.fnt | Up to 4 players (keys passed as process params) in a maze level (graphic 500+): lasers, stunner, rockets, nukes, health, shield, teleporters, diamonds; spawn positions are control points of the level graphic; walls via map_get_pixel. | M |
| Canonball Riding | CBRIDE.PRG | 9 KB / 359 | 640x480, 24 | Olegs\Mini2.fpg, Olegs\Mini2.fnt; hiscores saves\CbScore1.sav / CbScore2.sav | 1-2 players ride/steer between cannonballs fired from below, wind changes, clouds, lives, score and hiscores. (Latest version; MINI2.PRG is the older one.) | M |
| Tutorial_1 (ship duel "Mini1") | MINI1.PRG | 12 KB / 421 | 640x480, 24 | Olegs\Mini1.fpg, Olegs\Mini1.fnt | 2-player arena ship shoot-out with an in-game settings screen (lives, speed, acceleration, brake, explosion sizes, shot life, fast fire, shields...), explosive shots, mana. | M |
| Baller | BALLER.PRG | 8 KB / 387 | 640x480, 40 (F-keys) | Olegs\Baller.fpg; hi-times saves\Ballers.dat | Roll a ball through big level graphics (scroll + camera) whose pixel colours are terrain (22 death, 41 win, 54 wall, 73 hole, 89 hill; tuning values read from the level's pixels); best times per level. resolution=100. | M |
| Thursday Panzers | THURPANZ.PRG | 7 KB / 324 | 800x600, 24 | Olegs\Thurpanz.FNT, olegs\Thurpanz.FPG | Split-screen (2 scroll windows in 2 regions) tank war: 2 player tanks + rows of AI tanks per team, team counters. | S/M |
| PingPong | PINGPONG.PRG | 6 KB / 298 | 640x480, 24 | Olegs\PingPong.fpg | Pong for 2 (Q/A and Up/Down) with 70 balls released over time; win when 500 points ahead. | S |
| Sniper (Tutorial_1) | SNIPGAME.PRG | 7 KB / 311 | 1024x768, 24 | Olegs\SnipGame.fpg | Mouse crosshair; a column of snipers shoots at balloons flying past; smoke effects. | S |
| BunnyJumpers | BUNYJUMP.PRG | 4 KB / 215 | 1024x768, 24 | Olegs\BunyJump.fpg | 2 bunnies (arrows / WASD) jump on a background whose colours are platforms (22) and ceilings (41); bunnies bounce off each other. | S |
| Hatsch1 | HATSCH1.PRG | 4 KB / 233 | 800x600, 40 | Olegs\Hatsch1.fpg, Olegs\Hatsch1.fnt (digits only) | 3-player top-down ship arena shooter (charge-up shots with recoil), life counters in corners (CLONE code is commented out). | S |
| Runner | RUNNER.PRG | 3 KB / 162 | 640x480, 24 | Olegs\Runner.fpg, Olegs\Runner.fnt | 2-player sprint race by alternately hammering keys; "auf die Plaetze, fertig, los", timer. (Co-author Lukas Schw..) | S |
| Ballkill | BALLKILL.PRG | 3 KB / 160 | 800x600, 18 | Olegs\Ballkill.Fpg, Olegs\Ballkill.Fnt (digits only); hiscore save Sav\Ballkill.dat (-> DAT\BALLKILL.DAT) | Balls rise from the bottom, click them (mouse pointer graphic) before they escape; a hair-dryer (Foen) follows the mouse and blows them down; levels speed up. | S |
| Decathlon | DECATLON.PRG | 4 KB / 239 | 800x600, 18 | Olegs\Decatlon.FPG; hiscore sav\decatlon.dat (-> DAT\DECATLON.DAT) | Throwing event: hammer Space to build up arm movement (jointed arm via get_real_point), then the throw is plotted with put_pixel; distance + hiscore. | S |
| Tron | OLTRON.PRG | 6 KB / 190 | 1024x768, 60 | Olegs\OLTron.fpg | 2-player light cycles; trails drawn into a graphic, collision by pixel colour. | S |
| Fort | FORTKEEP.PRG | 2 KB / 166 | 800x600, 24 | olegs\Fortkeep.fpg | Fort in the centre; normal and zig-zag enemies approach; click to shoot from the fort towards the mouse. Enemies die after 2 hits; the fort only counts damage (no game-over). | S |
| Panzers | PANZERS.PRG | 2 KB / 142 | 1024x768, 24 | Olegs\Panzers.fpg | 2 tanks with rotating turrets (turret on control point 1 via get_real_point) and shots on a grass background generated with map_put_pixel. Very small, no scoring. | S |
| Tutorial_1 (asteroids) | SPACE.PRG | 5 KB / 128 | 640x480, 24 | Olegs\Space.fpg, Olegs\Space.fnt | The DIV "Tutorial 1" asteroids game re-skinned with Oleg's graphics (rotate/thrust/fire, asteroid splitting, score). | S |
| Tutorial_4 (snake) | SNAKE.PRG | 5 KB / 169 | 640x480, 20 | tutorial\tutor4.fpg (DIV sample, `FPG\TUTORIAL\TUTOR4.FPG`) | DIV "Tutorial 4" worm/snake, slightly modified (one apple at a time, speed variable). | S |
| Rubik | RUBIK3X3.PRG | 6 KB / 251 | 640x480, 18 | - (draws with put_pixel) | 3x3 rotation puzzle: cursor around the border (12 positions), Enter rotates a row/column of the 9 coloured squares; animated pixel background. | S |

## 2. Optional: toys, demos, tools, unfinished stubs

| Name | File | Size / lines | Loads | What it is | Recommendation |
|---|---|---|---|---|---|
| AntJumper | ANT.PRG | 2 KB / 122 | Olegs\Ant.Fpg | Langton's ant on graphic 1 (map_get/put_pixel, 3000 steps per frame); zoom with Alt/Ctrl, move with WASD. | toy |
| Balls | BALLS.PRG | 2 KB / 149 | Olegs\Ball.fpg (Mini2.fnt commented) | Diffusion-limited aggregation: balls fly to the centre and stick (map_put into graphic 2). | toy |
| Kochkurve | KOCHKURV.PRG | 4 KB / 298 | olegs\mandbrot.map, olegs\over.map (-> MAP\) | Sierpinski triangle / Koch curve drawing (keys 1/2). | toy |
| Mandelbrot | MANDBROT.PRG | 3 KB / 198 | Mandbrot.pal, olegs\mandbrot.map, olegs\over.map | Mandelbrot renderer with zoom/shift keys. | toy |
| KriegsSimulator | KRIEGSSI.PRG | 4 KB / 200 | Olegs\Kriessi.fpg | Cellular "war simulation" on 320x240 maps (graphics 1-3 as unit/life maps). | toy |
| Tutorial_1 (rotators) | SPACE2.PRG | 4 KB / 175 | Schluessel.map (-> MAP\SCHLUESS.MAP) | Rotating-graphic pattern art (Dreher processes). | toy |
| Siedler (terrain test) | SPACE3.PRG | 2 KB / 180 | Olegs\Siedler.fpg | Early Siedler prototype: scroll + mouse-driven cursor + terrain/water animation. | skip (superseded by SIEDLER) |
| Rechnen | AX2BXC.PRG | 1 KB / 86 | - | Plots a logistic-map curve with put_pixel. | toy |
| Funktion | FUNKTION.PRG | 1 KB / 88 | - | Random-walk pixel histogram. | toy |
| Fritten | FRITTEN.PRG | 1 KB / 95 | - | Start of an ice-cream/fries shop economy game - only shows the stats table. | stub, skip |
| Arena | ARENA.PRG | 8 KB / 265 | Olegs\Arena.fnt | "A RPG without story" - only a hero-statistics screen. | stub, skip |
| Viki1 | VIKI1.PRG | 1 KB / 82 | olegs\viki1.fpg | Starfield + a ship moving left/right. | stub, skip |
| Minigolf_1 | MINIGOLF.PRG | 5 KB / 164 | Olegs\Minigolf.fpg, Olegs\Space.fnt | Incomplete minigolf (ball accelerates with cursors, wall bounce by pixel colour), fps 300. | stub |
| Tutorial_1 (firework) | FIREWORK.PRG | 5 KB / 134 | Olegs\Space.fpg, Olegs\Space.fnt | Broken asteroids variant: infinite loop adding to score before the game starts. | skip |
| Solve / Solve1 / solve | PROSOLVE.PRG, SOLVE1.PRG, SOLVEB.PRG | 2-5 KB | - | Brute-force solvers for maths-competition puzzles (Landeswettbewerb 2004/05), print numbers. | skip |
| Test | TEST.PRG | 1 KB / 38 | - | Digit splitting test. | skip |
| Castedit | CASTEDIT.PRG | 14 KB / 659 | olegs/Castle.FPG, saves/Level1.dat, Level2.dat | Level editor for CASTLE (floor/object layers, save with Ctrl+S). | port only if CASTLE needs editing; the .dat files already contain the levels |
| Translater | TRANSLAT.PRG | 1 KB / 40 | Olegs\Castle.fpg | Tool: converted CASTLE level graphics (900-926) into saves/Level1.dat. | tool, skip |
| Heatfighter (old) | GEILFIGH.PRG | 43 KB / 1504 | Olegs\Heatfigh.fpg, HfChain.fpg, HfTemp.fpg, Claw.map (**MISSING**) | Earlier, smaller version of HEATFIGH (file date 2009 but content is older: fewer moves/variables). | duplicate - port HEATFIGH |
| Canonball Riding (old) | MINI2.PRG | 9 KB / 346 | Olegs\Mini2.fpg/.fnt | Older CBRIDE (has a 3-player key `3`, hiscore saving commented out). | duplicate - port CBRIDE (optionally add its 3-player mode) |
| Shaddraw | SHADDRAW.PRG | 1 KB / 56 | Pic1.map (**MISSING** everywhere) | Shows one map. | skip |
| Magamana | MAGAMANA.PRG | 0.1 KB | Olegs\Magamana.FPG (0 graphics) | Only loads an empty FPG. | skip |
| Objekte | OBJEKTE.PRG | 0.5 KB | - | Snippet: Graszeichner process (paint random grass colours into a graphic). Same code is in PANZERS. | snippet |
| TXT | TXT.PRG | 1 KB / 105 | - | Snippet (struct declaration) from UNDWORLD. | snippet |

## 3. Backups, copies, empty files (ignore)

| File | Note |
|---|---|
| Copy of ARENA.PRG | identical to ARENA.PRG (same md5) |
| Copy of CASTLE.PRG | older CASTLE (1494 lines, 2006) |
| Backup of OLLWARS.PRG | older OLLWARS (2004) |
| EFFECTS.PRG, MINIGAME.PRG, TEMP.PRG | 0 bytes |

Unused/extra graphics in `FPG\Olegs`: HINICOSM.FPG (older Minicosm graphics), MIGOBACK.FPG, Mini1Bak.FPG,
Copy of CASTLE.FPG, Copy of HFEIGEN.FPG, EFFEKTE.FPG (used by no PRG; with MAP\EFEKTMAP.MAP probably for the empty
EFFECTS.PRG), HFCLAW.FPG (only commented-out reference), _DIV_.FPG (0 bytes). Extra fonts: ATOMSB.FNT, NEW_FONT.FNT.
Extra maps in `MAP\`: BACK1.MAP, KANON.MAP, OLEG.MAP (= SCHLUESS.MAP). Missing everywhere: `Claw.map`, `Pic1.map`,
`OLEGWASS.Pal` (only referenced in comments / GEILFIGH / SHADDRAW).

Save/data files in `DIV\Saves\` (raw little-endian int32 dumps written by `save()`): LEVEL1.DAT, LEVEL2.DAT
(345600 B = CASTLE room maps, essential), CASTLE1-4.DAT (CASTLE save slots), CASTLE.DAT, BALLERS.DAT (31 hi-times),
Ballers.sav, BallKill.dat, CBSCORE1/2.SAV; `DIV\DAT\`: BALLKILL.DAT, DECATLON.DAT (one int each).
