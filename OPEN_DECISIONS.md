# Decisions for Olesch's DIV ports

All 35 games are live on https://olesch-div-games.pages.dev/. This file records every question about the ports, your decision, and what has been done.

**Status words:** **Live** = on the website. **Done, not live** = changed in the Godot project but not exported and deployed yet. **Kept** = nothing changed, by your decision.

---

## Still open

| # | Question | Now |
|---|----------|-----|
| 9 | **Minicosm:** the original really can overfill a cannon by one invisible round (see point 9). Fix or keep? | Kept, same as the original |
| N | **Panzers:** a tank can drive off the screen, where shells can't reach it, so a player can hide and never lose. Keep tanks on screen? | Unchanged; tanks can leave the screen |
| – | **Deploy:** the changes below marked "Done, not live" | Waiting for your go |
| – | **Git repo:** your PRG files contain a friend's full name (the website hides it). Decide before ever pushing the repo publicly. | Repo is local only |

---

## Part 1 – Quirks and guesses per game

### Most important first

1. **Thursday Panzers: tank speed.** DIV's released source (`src/runtime/f.c`, `get_id`) skips the calling process, so a tank never slowed itself down and players reach 8 px per frame (about 190 px/s).
   - **Decision:** do it as DIV did. **Status:** Live (2026-10-24).
2. **GigaMaze: the gap trap.** The top exit gap (x 236–390) wraps to the bottom, but the bottom gap is only x 232–273, so a ship that comes out elsewhere is stuck in the wall for good.
   - **Decision (2026-10-26):** no fix. **Status:** Kept.
3. **WormBattleWarriors: rules I invented** for your unfinished original: Space ends the turn, you attack by moving into an enemy (damage values are guesses), you win when the other side has no worms left.
   - **Decision (2026-10-26):** the rules are OK. **Status:** Kept.
4. **Heatfighter.**
   - a) **Speed:** the original asks for 100 ticks per second. **Decision (2026-10-26):** 60. **Status:** Done, not live: the game now runs at 60 ticks per second, so everything moves at 60% of the original speed while timing stays frame-exact. A full computer-vs-computer match to K.O. ran without errors.
   - b) **Added setup screen and K.O.** (characters, human or computer, K.O. at life 0, rematch). **Decision:** OK. **Status:** Live.
   - c) **Template's missing frames:** the "Template" character turns invisible during its special and duck attack. **Decision:** keep the original. **Status:** Kept.

### Bugs from the original that I kept

5. **Lommings:** a) the Backspace nuke also kills already saved lemmings; b) `+`/`-` release rate reversed; c) removing a stopper costs another stopper.
   - **Decision (2026-10-26):** keep all. **Status:** Kept.
6. **Ship Duel (MINI1):** a) the fast-fire setting does nothing; b) the explosive shot never costs mana; c) End is both P1's explosive shot and P3's turn-left; d) labels of settings rows 10 and 11 swapped; e) settings can go to zero or negative.
   - **Decision (2026-10-26):** a, b, e keep; c and d fix. Plus a new bug you found: shots got stuck in other players' shields, which never happened in the original.
   - **Status:** Done, not live:
     - **Shields:** in the original a shot touching a shield turns around once and moves back 6 px (MINI1.PRG lines 286–288). The port checked the shield with the previous frame's positions, so it kept seeing the shield and flipped the shot back and forth forever. It now checks at the shot's new position; a test shot bounces off once and flies away.
     - **c)** Player 1's explosion shot moved to the **Down arrow** (and keypad 2); player 3 keeps End. The help text on the settings screen says so.
     - **d)** Row 10 is now "Eigenzerstoerung Schiffe" (whether a ship's own shots hurt it), row 11 "Eigenzerstoerung Schuesse" (whether a ship's shots destroy each other).
7. **GigaMaze:** a) weapons 2–5 fire nothing; b) no game end.
   - **Decision (2026-10-26):** keep. **Status:** Kept.
8. **Castle:** a) the Ork hero shoots invisible arrows; b) opening a door with a key still blocks that step; c) picking up dropped arrows can erase a neighbouring object (your comment says "Arrows appear twice"); d) save slot 4 is in an older format and shows as empty.
   - **Decision (2026-10-26):** keep all; c) also as a fact on the site.
   - **Status:** Kept. The arrow bug is the 4th fact under Castle (the landing page now allows more than 3 facts): done, not live.
9. **Minicosm: ammo above the maximum.**
   - **Your note (2026-10-26):** you couldn't reproduce it in the original.
   - **Re-checked (2026-10-26):** the original does it, but it can't be seen, and only by one round. The reload checks `Munition<Max` once, waits about 2.7 s, then adds a round without checking again (MINICOSM.PRG lines 320–323). If you buy the atom bomb during that wait, it fills the cannons and the waiting reload still adds one. The lights never draw above the maximum, so the extra round only shows as a shot that doesn't put a light out. To try it: fire one left shot, buy the atom within ~2.7 s, wait for the reload, and you get three shots from a 2-round cannon.
   - **Status:** Kept; the port does the same. **Still open:** fix or keep?
10. **Miniship:** the computer players' aiming mix-up makes them almost always thrust. **Decision:** keep. **Status:** Kept.
11. **Siege:** the necromancer's limit of 3 skeletons is never checked. **Decision:** keep (unlimited). **Status:** Kept.
12. **Stranded:** no game over; the sun costs health even after sleeping; axe, rod and hammer do nothing. **Decision:** keep. **Status:** Kept.
13. **Huhnshot:** reloading costs `50 + flowers` points. **Decision:** keep. **Status:** Kept.
14. **Sniper:** after each salvo the aim snaps to the top-left limit. **Decision:** keep. **Status:** Kept.
15. **PingPong:** score never shown; balls keep playing after a win; trailing player gets 3 points per goal, leader 2. **Decision:** keep. **Status:** Kept.
16. **Runner:** one clock "second" is 25 ticks. **Decision:** keep. **Status:** Kept.
17. **Tron:** a stray background pixel at (673,190) kills a cycle. **Decision:** keep. **Status:** Kept.

### Changes I made during porting

**Decision (2026-10-26) for 18–35:** keep all as they are. **Status:** Live (except where a later change is noted).

18. **Thursday Panzers:** player 2 now really controls team 2 (broken in the original); winner message. Esc now goes to the new setup screen (Part 2 A).
19. **Hatsch1:** ship 3 starts at the bottom left instead of on top of ship 2; its life counter stays at the bottom right.
20. **Snake:** play field moved into the frame graphic; topscore saved.
21. **Panzers:** tanks visible instead of painted over with grass. Camouflage is now an option (Part 2 N).
22. **BunnyJumpers:** the stomp block is not ported.
23. **Ballkill:** hiscore loads at start; restart 2 s after Game Over.
24. **Fort:** "Schaden: N" damage counter; no game over.
25. **Baller:** level list with all 8 levels.
26. **Atoms:** hiscore per mode saved as "Rekord".
27. **Runner:** the FOUL text stays on screen.
28. **Decathlon:** one-line control hint.
29. **Ship Duel:** named "Ship Duel (Tutorial 1)"; winner banner.
30. **Siege:** no win condition, no banner.
31. **S-Type:** fades back to the menu 6 s after "Level 2 Won!!".
32. **Huhnshot:** results screen when time runs out.
33. **Canonball Riding:** the first death ends a two-player game, as in the original.
33b. **Castle:** no mana bar (the original's call is commented out).
34. **Web keys:** S-Type and GigaMaze player 1 fire with Space, Miniship player A with Right Shift (browsers block Ctrl+W/T/N).
35. **Feel:** Tron 660 px/s, Sniper mouse 1:1, Hatsch1 charge timing, Decathlon swing stay as they are; Heatfighter changed to 60 ticks/s (point 4a).

---

## Part 2 – Options screens for values fixed in the code

**Decision (2026-10-26):** do A, B, D (computer opponent only), G, N, P, Q (level select only); don't do the rest. Every change is described in the game's "Changed by Claude" line on the site.

In every new options screen the defaults play exactly like the version before. Values last for the session and are not saved.

| # | Game | Decision | Status |
|---|------|----------|--------|
| A | **Thursday Panzers** | Do | **Done, not live.** Setup screen before each match: tanks per team (22 / 28), player and computer tank life, damage and speed for each team (300/10/40 and 200/5/30), and a reinforcements mode from your commented-out code (a new tank for each team every second, stops once a team has won). Keyboard for both players and mouse. Esc in a match goes back to it. |
| B | **PingPong** | Do | **Done, not live.** Options screen before each match: balls (2–200, default 70), ball speed (1–4, 6; default 4; also changes bats and release timing like `Activity` does), points to win (50–2000, default 500), classic one-ball mode from your commented-out loop, and human or computer for each bat from your unused `ki==2` AI. Esc, or Enter/Space after a win, goes back to it. |
| C | Tron | Don't | – |
| D | **Siege** | Computer opponent only | **Done, not live.** New setup page: PL 1 and PL 2 can each be HUMAN or COMPUTER (default both human; both computer = a demo match). The computer is your commented-out `KI(player)` ported as written, with no fixes needed: every 24 frames (1.33 s) it sends a warrior 20 times out of 21, free of cost, and does nothing else, so it is easy to beat. A computer side has no cursor. Esc goes back to the setup page. |
| E | Canonball Riding | Don't | – |
| F | Huhnshot | Don't | – |
| G | **Sniper** | Do | **Done, not live.** Options screen: snipers 1–21 (default 17; 18–21 use your commented-out positions), rifle / minigun / grenade-launcher snipers (minigun and grenade launcher built from your commented-out code; default rifles only), balloons 0.25–12 per second (default 1). The right button reloads miniguns and grenade launchers. Esc goes back to it. |
| H | Ballkill | Don't | – |
| I | Snake | Don't | – |
| J | ~~Space~~ | Removed from the site (2026-10-24) | – |
| K | Hatsch1 | Don't | – |
| L | Runner | Don't | – |
| M | **Fort** | Your separate call (2026-10-26): 10 times fewer enemies | **Done, not live.** One enemy pair every ~4.2 s instead of every ~0.4 s (100/24 s instead of the original's 10/24 s). Nothing else changed. |
| N | **Panzers** | Do | **Done, not live.** Options screen that turns the sandbox into a duel: life OFF (sandbox, as before) or 1–100 hits (default 30), destroyed tanks become wrecks, "PLAYER n WINS" with Enter for a new round, camouflage on/off (default off). **Still open:** tanks can hide off screen (see top). |
| O | GigaMaze | Don't | – |
| P | **BunnyJumpers** | Do | **Done, not live.** Options screen for 0–50 extra bunnies (default 0). As in your commented-out loop they start at random spots, have no controls and just get in the way (your loop would have made 11, because `FROM 0 TO 10` counts both ends). Esc in the game goes back to it. |
| Q | **Lommings** | Level select only | **Done, not live.** Level select with all 13 levels (900–911, 920, 950; level 900 is selected, so Enter plays as before), with a preview of each level. Play goes on from the chosen level in the original order. Esc goes back to it. No passwords. |
| R | Stranded | Don't | – |
| S | WormBattleWarriors | Don't | – |
| T | Heatfighter | Already had a setup screen | Speed changed to 60 instead (point 4a) |
| U | Baller | Already had a level list | – |

Games that already had a settings screen in your original: Microcosm, Atoms, Castle, S-Type, Miniship, Ship Duel.

---

## Part 3 – Programs I did not port

**Decision (2026-10-24):** port P1, P3 (with options), P4, P5, P6, P8 (with options), P11 (no saving); leave the rest. **Status:** all seven are live.

| # | Program | Decision |
|---|---------|----------|
| P1 | **Siedler** (SIEDLER.PRG): Settlers-style sandbox | Ported, live |
| P2 | Ollwars (OLLWARS.PRG): unfinished split-screen strategy | Left |
| P3 | **AntJumper** (ANT.PRG) | Ported with options, live; default changed (point 36) |
| P4 | **Balls** (BALLS.PRG) | Ported, live |
| P5 | **Kochkurve** (KOCHKURV.PRG) | Ported, live |
| P6 | **Mandelbrot** (MANDBROT.PRG) | Ported, live |
| P7 | KriegsSimulator (KRIEGSSI.PRG) | Left |
| P8 | **Rotators** (SPACE2.PRG) | Ported with options, live |
| P9 | Rechnen (AX2BXC.PRG) | Left |
| P10 | Funktion (FUNKTION.PRG) | Left |
| P11 | **Castedit** (CASTEDIT.PRG) | Ported, live (your levels can be played in Castle as level sets 3 and 4) |
| P12 | Heatfighter (old) (GEILFIGH.PRG) | Left |
| P13 | Canonball Riding (old) (MINI2.PRG) | Left |
| P14 | Siedler terrain test (SPACE3.PRG) | Left |
| – | FIREWORK, PROSOLVE/SOLVE1/SOLVEB, TEST, SHADDRAW, MAGAMANA | Left |

Removed after porting: **Space** (the DIV asteroids tutorial, not your own game), from the site and from disk.

---

## Part 4 – Questions from the new ports

36. **AntJumper:** a slip in the original's colour table made the ant draw one straight line instead of Langton's ant.
    - **Decision (2026-10-26):** fix it, make it Langton's.
    - **Status:** Done, not live. The default is now Langton's ant (RL). Fixing the colour slip alone wasn't enough: the turn table also had to turn right on black. The straight line is still selectable as "Original's bug - straight line".
37. **Kochkurve:** key 2 draws the Sierpinski triangle again, because the Koch routine was never finished. **Decision:** no Koch curve. **Status:** Kept.
38. **Castedit:** a tap moves one cell and repeat starts after 0.25 s (the original repeated from the first frame). **Decision:** keep. **Status:** Kept.
39. **Mandelbrot:** draws in about 1.5 s; keypad +/- added as zoom keys. **Decision:** OK. **Status:** Kept.
40. **Rotators:** runs at 100 frames per second, adjustable in the options. **Decision:** OK. **Status:** Kept.
41. **Balls:** 100 fps as the original asks. **Decision:** keep 100. **Status:** Kept.

---

## Website

- **2026-10-25 (live):** the landing page links this porting guide under the DIV Game Studio screenshot ("If you stumbled upon this page..."), and all texts say "DIV Game Studio".
- **Done, not live:** the "Changed by Claude" lines of Heatfighter, Ship Duel, Fort, AntJumper, Thursday Panzers, PingPong, Sniper, Panzers, BunnyJumpers, Lommings and Siege, the 4th Castle fact, and updated descriptions for Sniper (right button reloads) and Panzers (now a duel).
- **Rule (2026-10-26):** every change to a game is described in its "Changed by Claude" line.
