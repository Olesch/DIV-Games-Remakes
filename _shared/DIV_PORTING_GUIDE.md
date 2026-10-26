# DIV Game Studio -> Godot 4.7 porting guide

Audience: an agent that rewrites ONE of Oleg's old DIV Game Studio games as an idiomatic Godot 4 game
(GDScript, typed). The DIV code is the *specification*: read it to understand exactly what the game does,
then build a normal Godot game that plays the same (same speeds, constants, rules, layout). Do **not**
emulate DIV (no frame scheduler, no "process" base class, no pixel-perfect collision engine).

Contents
1. Where things are
2. Reading DIV code: the language
3. The process model (and what it becomes in Godot)
4. Coordinates, graphics and predefined variables
5. Timing: set_fps and converting speeds
6. Built-in functions used by the games (with Godot equivalents)
7. Keyboard scan codes -> InputMap
8. Recommended Godot structure
9. Collisions, hardness maps and drawing into graphics
10. Text and fonts
11. Scroll windows, regions, split screen
12. Screen / project settings
13. DIV file formats
14. The asset converter (div_convert.py) and how to use its output
15. Porting checklist
16. Known uncertainties

---------------------------------------------------------------------------------------------------

## 1. Where things are

| What | Path |
|---|---|
| DIV install (read only, never modify) | `D:\Prog\Godot\DivRemake\DIV\` |
| Oleg's programs | `DIV\PRG\Olegs\*.PRG` (text, **cp850** encoding, CRLF; comments mostly German) |
| His graphics / fonts | `DIV\FPG\Olegs\*.FPG`, `DIV\FNT\Olegs\*.FNT`; maps `DIV\MAP\`, palettes `DIV\PAL\` |
| Saved data / level data | `DIV\Saves\*.DAT|*.SAV`, `DIV\DAT\*.DAT` |
| This guide | `D:\Prog\Godot\DivRemake\_shared\DIV_PORTING_GUIDE.md` |
| Game list, assets per game, what to port | `_shared\GAMES_INDEX.md` |
| Original DIV help (all functions/statements, with sample programs) | `_shared\DIV_HELP_REFERENCE.md` (grep `## [128] key()` etc.) |
| Asset converter | `_shared\tools\div_convert.py` (Python 3, no dependencies) |
| Help extractor (already run) | `_shared\tools\div_help_extract.py` |
| Your project | `D:\Prog\Godot\DivRemake\<GameName>\` |

Read a PRG with: `iconv -f cp850 -t utf-8 FILE.PRG` (Git Bash) or Python `open(f, encoding='cp850')`.
Python 3.12 is `python` on PATH; Godot 4.7.2 is `godot` on PATH.

---------------------------------------------------------------------------------------------------

## 2. Reading DIV code: the language

DIV (version 1 here - every function the games use is a DIV 1 function; no DLLs) is a Pascal/C hybrid.
Identifiers and keywords are **case-insensitive** (`Key(_ENTER)` = `key(_enter)`, `Graph` = `graph`).
Comments: `//` to end of line and `/* ... */`. Statements end with `;` (a stray `:` is also accepted;
e.g. `Framers():` in GIGAMAZE). Every block ends with `END` (`IF..END`, `LOOP..END`, `REPEAT..UNTIL(c)`).

### 2.1 Program structure

```
PROGRAM Name;
CONST   A=1; B=2;                       // compile-time constants
GLOBAL  score=0; table[10]; STRUCT s[3] a; b; END   // one copy, visible everywhere
LOCAL   energy; xincr;                  // EVERY process gets its own copy (readable as id.energy)
PRIVATE counter;                        // variables of the main code only
BEGIN                                   // main code = the first process
   ...
END
PROCESS Ship(x, y, graph)               // a process type; parameters are assigned to
PRIVATE speed;                          //   locals/privates (x,y,graph here are predefined locals)
BEGIN ... END
```
- A PROCESS that never executes FRAME and ends with `RETURN(value)` is used as a **function**
  (e.g. `Begehbar(x,y)` in STRANDED/SIEDLER returns 0/1). Port it as a plain function/static func.
- A parameter may be a GLOBAL name: `PROCESS Foo(score)` simply assigns the global when called.
- Parameters may be redeclared in PRIVATE (BALLS `Ball(x,y,Stay)` + `PRIVATE Stay;`) - same variable.

### 2.2 Data
- **Everything is a 32-bit signed integer.** No floats, no booleans, no string variables. Overflow wraps
  silently. Literals `"text"` can only be passed to functions (write, load_fpg...) or stored in a table:
  `Playertext[5]="OFF","ON","PC Easy",...;` then `write(0,x,y,4,Playertext[i])` works.
- **Tables:** `t[10]` declares **11** elements, indices 0..10 (the number is the LAST index).
  `t[]=1,2,3;` sizes from the initializer. `t` without index = `t[0]`. No bounds checking: writing past the
  end silently overwrites the next variables - when porting, size arrays `n+1` and clamp/guard indices.
- **STRUCT** `STRUCT Held[3] Kraft[1]; Waffe[4]; END` = array of 4 records; access `Held[i].Kraft[0]`.
  Nested: CASTLE `STRUCT Map[35] STRUCT Layer[1] STRUCT Xpos[39] Ypos[29];` (36x2x40x30 ints). Port as
  typed inner classes, Dictionaries, or flat `PackedInt32Array` with computed index.
  Initialisers fill fields in declaration order (`STRUCT Einheiten[255] lifepoints; Attackpoints; END= 0,0, 10,1, ...`).
- **OFFSET x** (`&x`) = address of a variable. Used only to (a) let functions write results
  (`get_point(f,g,n,OFFSET x,OFFSET y)` writes two ints), (b) `write_int(...,OFFSET score)` = live display of
  a variable, (c) `load/save(file, OFFSET first_var, size)` = dump consecutive variables to disk,
  (d) `convert_palette(f,g,OFFSET table)`, (e) `xgraph=OFFSET table`.
- `sizeof(x)` = number of ints (1 for a variable, element count for a table/struct).
- Uninitialised variables are 0. Process ids are odd positive ints, 0 = "no process".

### 2.3 Operators and evaluation - the traps
- Arithmetic is integer: `/` truncates toward zero (`7/2=3`, `-7/2=-3`); `MOD`/`%` is C remainder
  (`-7 MOD 3 = -1`). GDScript int `/` and `%` behave the same - keep values `int`, and when converting a
  formula to floats remember the original truncation (e.g. `x/10` in a coordinate is a whole pixel).
- `sqrt()` returns the truncated integer root; `pow(a,b)` integer power; `abs()`.
- **Truth is odd/even**: a condition is TRUE if the value is **odd**, FALSE if even. Comparisons, `key()`,
  `mouse.left` give 1/0; process ids are odd. So `IF (counter)` with counter=2 is FALSE in DIV.
  `NOT`, `AND`, `OR`, `XOR` are bitwise (`NOT 1 = -2` = even = false). In practice: conditions built from
  comparisons/1-0 values translate directly to GDScript `and/or/not`; but if you see `IF (somevar)` or
  `WHILE (a=b)` on a variable that can hold even non-zero values, translate as `(v & 1) == 1` (or check what
  the author meant - often it was "non-zero" and only worked by luck with 0/1 values).
- Assignment is an expression: `IF (hit=collision(TYPE Meteor))` assigns then tests;
  `WHILE (id2=get_id(TYPE shot))` loops over all shots.
- Precedence: the help lists AND/OR/XOR *above* comparisons, but every game relies on C-like
  `a>1 AND b<2` meaning `(a>1) AND (b<2)` - read them that way. `x++`, `x+=n` etc. as in C.
- `IF(a) b; END` - the condition needs parentheses; nested `ELSE IF` is written as `ELSE IF ... END END`.

### 2.4 Statements
| DIV | Meaning |
|---|---|
| `IF (c) .. ELSE .. END` | |
| `SWITCH (e) CASE 1: .. END CASE 2..5, 9: .. END DEFAULT: .. END END` | first matching case only (no fall-through); ranges `a..b`, lists |
| `WHILE (c) .. END` | |
| `REPEAT .. UNTIL (c)` | body runs at least once |
| `LOOP .. END` | infinite; leave with BREAK (or RETURN) |
| `FROM v=a TO b; .. END` / `STEP s` | inclusive both ends; counts DOWN automatically if a>b (`FROM x=9 TO 0` = 10 iterations). With STEP the last value is the last one not passing b (`FROM x=0 TO 9 STEP 2` -> 0,2,4,6,8). After the loop v = b+step |
| `FOR (init; cond; incr) .. END` | as in C, comma lists allowed |
| `BREAK` / `CONTINUE` | innermost loop only (not IF/SWITCH) |
| `RETURN` / `RETURN(v)` | ends the process (or returns v when used as a function) |
| `FRAME;` / `FRAME(n);` | see section 3 |
| `CLONE .. END` | duplicates the running process; the block runs only in the copy (section 3) |
| `DEBUG;` | opens the debugger - ignore |

---------------------------------------------------------------------------------------------------

## 3. The process model (and what it becomes in Godot)

### 3.1 How DIV runs
- Every PROCESS instance is an independent object (sprite + its own locals + its own program counter),
  like a coroutine. The main code (`BEGIN..END` after PROGRAM) is itself the first process.
- The game advances in **frames**. In each frame DIV resumes every live process once (highest `priority`
  first, otherwise in an unspecified order) and runs it until it executes `FRAME;`. When all processes
  reached FRAME, the screen is drawn with each process' current `graph,x,y,z,angle,size,flags`, then the
  next frame starts. A process that loops without FRAME freezes the game.
- `FRAME(n)`: the process contributes n% of a frame. `FRAME(400)` = "skip the next 3 frames" (wait 4 frames
  before continuing) - Oleg uses large values as **delays/timers**: `FRAME(7200)` = wait 72 frames
  (3 s at 24 fps); `FRAME(rand(5200,7200))` = random spawn interval; `FRAME(8000-...)` = reload time.
  `FRAME(25)` would run the loop 4 times per frame. `FRAME(100)` = `FRAME`.
- **Calling a process creates it** (`Shot(x,y,angle)`): the new process runs immediately, *before* the
  caller continues, up to its first FRAME; the call returns its id. So a child can position itself from
  `father.x` before the parent goes on. The new process is drawn from the current frame on.
- A process **dies** when it reaches its final END, executes RETURN, or receives `signal(id,s_kill)`
  (takes effect immediately for other processes; when sent to itself it finishes the current frame's code).
  `let_me_alone()` kills all except the caller. When the main code ends the game continues as long as other
  processes live; when no process is left DIV exits. `exit("msg",0)` ends everything.
  Typical idioms: `WHILE (NOT out_region(id,0)) ... FRAME; END` = "live until off screen";
  `LOOP ... IF(hit) BREAK; END FRAME; END graph=3; FRAME(400); graph=4; FRAME(400);` = death animation then die.
- Relationships: `father` (creator), `son` (last created), `bigbro`/`smallbro` (siblings). Locals of another
  process are read/written with `id.var` (e.g. `father.x`, `Object_hit.Art`, `Fadenkreuz_id.x`).
  PRIVATE variables are not accessible from outside; LOCALs are (and exist in every process type).
- Signals: `s_kill`, `s_sleep` (invisible, paused, not detected), `s_freeze` (visible, paused, still
  collidable), `s_wakeup`; `_tree` variants (+100) also affect all descendants.
  `signal(TYPE Enemy, s_kill)` affects all processes of a type.
- `CLONE ... END`: creates a copy of the running process with all variables equal; the block executes only
  in the copy, then BOTH continue after END (MINICOSM meteors split this way).
- `get_id(TYPE t)` returns, call after call, every live process of type t, then 0; `collision(TYPE t)` the
  same for processes whose graphic overlaps the caller's (pixel overlap). Both restart after a FRAME.
- `priority`: higher runs earlier in the frame (use when B reads A's position: A gets higher priority).

### 3.2 Translating to Godot (idiomatic)
| DIV | Godot |
|---|---|
| PROCESS type | a scene (`ship.tscn`) with a root node (Node2D/Area2D/CharacterBody2D) + script `ship.gd` (`class_name Ship`) |
| calling a process `Shot(x,y,a)` | `var s := SHOT_SCENE.instantiate() as Shot; s.setup(x, y, a); add_child or get_parent().add_child(s)`; set properties BEFORE `add_child` so `_ready` sees them |
| LOCAL vars | exported/typed member variables of the entity scripts (put shared ones in a base class only if several entities really share behaviour) |
| GLOBAL vars | an autoload `Game` (`game.gd`) holding score, money, difficulty...; emit signals on change (`money_changed`) |
| main code BEGIN..END | `main.tscn` / `game.gd` (title screen, spawning, game loop) - split title/menu/game into scenes if natural |
| loop body before FRAME | `_physics_process(delta)` (or `_process`) |
| `FRAME(n)` used as a delay / spawn timer | a `Timer` node, `await get_tree().create_timer(sec).timeout`, or a float countdown in `_physics_process`. n% -> `n/100` frames -> `n/100/fps` seconds |
| sequences with FRAME in the middle (animations, intros, "wait until key") | `AnimatedSprite2D`/`AnimationPlayer`, a `Tween`, a small state machine (`enum State {INTRO, PLAY, DYING}`), or a coroutine with `await` for linear one-shot scripts (pitfall: an awaiting function keeps running after the node is freed only if its timer belongs to the tree - guard with `if not is_inside_tree(): return`) |
| process dies | `queue_free()` |
| `signal(id,s_kill)` | `node.queue_free()` (or call its `die()` to play an explosion first) |
| `let_me_alone()` | free all game entities (e.g. `get_tree().call_group("entities", "queue_free")`) |
| `s_sleep` / `s_freeze` | `process_mode = PROCESS_MODE_DISABLED` (+ `visible=false` for sleep) |
| `get_id(TYPE Meteor)` loops | `get_tree().get_nodes_in_group("meteors")` |
| `collision(TYPE Meteor)` | Area2D `area_entered`/`body_entered` signals or `get_overlapping_areas()` filtered by group / physics layer |
| ids, `father.x` | node references (`var target: Node2D`), `get_parent()`, or an explicitly stored owner; check `is_instance_valid(ref)` before use (DIV silently read stale data) |
| `id.var = value` on another process | call a method or set a property on that node; prefer signals for events ("hit", "died") |
| `priority` | usually irrelevant; if B must follow A exactly, update B after A (`process_priority`, or let A move B) |
| CLONE | instantiate a new scene and copy the relevant state (`m.setup_from(self)`) |
| process with RETURN(value) and no FRAME | a normal function |
| exit() | `get_tree().quit()` (or return to the title scene) |

---------------------------------------------------------------------------------------------------

## 4. Coordinates, graphics and predefined variables

### 4.1 Screen and coordinates
- Pixels, origin (0,0) top-left, x right, **y down** - same as Godot 2D. Screen size from `set_mode`
  (default 320x200 if never called; the games use 320x240, 640x480, 800x600, 1024x768).
- A process' `(x,y)` is where its graphic's **control point 0** is placed. If the graphic has no control
  point 0 defined, it is the graphic's centre `(width/2, height/2)` (integer division). The converter puts
  this in `meta.json` as `"cp0"`. In Godot: `Sprite2D.centered = false; offset = -Vector2(cp0)` - then the
  node position is the DIV (x,y) and rotation/scale/flip happen around the control point, like in DIV.
- `resolution`: if non-zero, x/y are in 1/resolution pixels (`resolution=100`: x=12345 is pixel 123).
  Used for sub-pixel motion (BALLER, BALLKILL, MINISHIP, HEATFIGH, FORTKEEP, HUHNSHOT birds...). In Godot
  just use floats: `position.x = x_div / 100.0` and convert speeds the same way.
- `ctype`: `c_screen` (0, default) screen coordinates; `c_scroll` (1) = coordinates inside the scroll
  window's big background graphic (world coordinates; section 11). `c_m7` unused by the games.

### 4.2 Predefined LOCAL variables (every process has them)
| Var | Default | Meaning / Godot |
|---|---|---|
| `x, y` | 0 | position of control point 0 (see above) -> `position` |
| `z` | 0 | depth; **LOWER z is drawn ON TOP**. Defaults: scroll windows 512, processes 0, texts -256 (`text_z`), mouse pointer -512. Equal z = undefined order. Godot: `z_index = -z` (keep within -4096..4096) or order nodes/CanvasLayers accordingly |
| `graph` | 0 | graphic code inside the file (1..999; 0 = invisible; >=1000 from load_map) -> `texture` (+ offset from that graphic's cp0!). Animation by changing graph every n frames -> AnimatedSprite2D/SpriteFrames with fps = DIV fps / frames-per-image |
| `file` | 0 | which FPG (load order: first load_fpg returns 0, next 1, ...) |
| `angle` | 0 | rotation in **thousandths of a degree, counter-clockwise** (0 = right, 90000 = up, -90000/270000 = down). Graphics are drawn facing right. Godot: `rotation = -deg_to_rad(angle / 1000.0)` |
| `size` | 100 | scale in percent (0 = invisible) -> `scale = Vector2.ONE * size / 100.0` |
| `flags` | 0 | bit 1 = horizontal mirror, bit 2 = vertical mirror, bit 4 = 50% transparent ("ghost layering"). Godot: mirror around the control point with `scale.x = -s` / `scale.y = -s` (or `flip_h` if cp0 is centred), transparency `modulate.a = 0.5` |
| `region` | 0 | clipping rectangle number (define_region), 0 = full screen |
| `priority` | 0 | execution order (higher first) |
| `ctype` | c_screen | coordinate system |
| `resolution` | 0 | coordinate precision (above) |
| `father, son, bigbro, smallbro` | | process family ids |
| `cnumber` | 0 | which scroll windows show the process (`c_0`=1, `c_1`=2, ... sum; 0 = all) |
| `xgraph` | 0 | `OFFSET table` with `[views, g0, g1, ...]`: graphic picked by angle instead of rotating (not used by the games) |
| `height` | 0 | mode 7 only (unused) |

### 4.3 Predefined GLOBAL variables
| Var | Meaning / Godot |
|---|---|
| `mouse.x, mouse.y` | pointer in screen pixels -> `get_global_mouse_position()` (with viewport stretch this is already in game pixels). Assigning moves the pointer -> `Input.warp_mouse()` / `get_viewport().warp_mouse()` (SIEDLER/SPACE3 re-centre it every frame to get relative motion -> use `InputEventMouseMotion.relative` + `Input.mouse_mode = MOUSE_MODE_CAPTURED`) |
| `mouse.left/middle/right` | 1 while held -> `Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)` or input actions. Oleg's "ANTIFASTCLICK" variables reimplement "just pressed" -> `Input.is_action_just_pressed()` |
| `mouse.graph/file/z/angle/size/flags/region` | pointer graphic (hot-spot = cp0). None by default (no OS cursor in DOS). Godot: `Input.set_custom_mouse_cursor(tex, hotspot=cp0)` or a Sprite2D following the mouse + `Input.mouse_mode = MOUSE_MODE_HIDDEN` |
| `scroll[0..9].x0,y0,x1,y1,z,camera,ratio,speed,region1,region2` | scroll windows (section 11) |
| `timer[0..9]` | counters in **hundredths of a second** (real time), settable -> `Time.get_ticks_msec()` or your own float seconds |
| `text_z` | -256, depth of ALL texts |
| `fading` | true while a fade() runs |
| `scan_code`, `ascii`, `shift_status` | last key pressed this frame / modifiers -> `_unhandled_key_input` |
| `max_process_time` | anti-freeze timeout (ignore; set by the solver programs) |

Constants: `pi`=180000, `true`=1, `false`=0, `min_int`, `max_int`, `s_kill`=0, `s_wakeup`=1, `s_sleep`=2,
`s_freeze`=3 (+100 tree), `all_text`=0, `all_sound`=-1, `g_wide`=0, `g_height`=1, `g_x_center`=2,
`g_y_center`=3, `c_screen`=0, `c_scroll`=1, `c_m7`=2, `c_0..c_9`=1,2,4..512, video modes `m640x480`=640480 etc.

### 4.4 Graphics, palette, colour index 0
- All graphics are 8-bit, palette-indexed, 256 colours. **Index 0 is transparent** for sprites, `put()`,
  `map_put()`, fonts and the scroll foreground. The background screen itself shows colour 0 of the palette
  (usually black) where nothing was drawn -> set `RenderingServer.set_default_clear_color(palette[0])`
  (look at `palette.json`, `palette_rgb8[0]`) - most games expect a black background.
- The whole screen uses ONE palette (the first FPG/MAP/FNT loaded or `load_pal`). The converter's `game`
  command renders every file with that game palette, which reproduces what the player saw.
- Palette effects (fade, roll_palette, convert_palette) operate on colour indices -> see section 6.
- Control points: up to 1000 per graphic (`points` in meta.json); point 0 = origin (above); others are
  markers used by `get_point` (level spawn points, exits, cannon muzzles) and `get_real_point` (marker after
  rotation/scaling).

---------------------------------------------------------------------------------------------------

## 5. Timing: set_fps and converting speeds

`set_fps(n, skip)` fixes the game at **n frames per second** (default 18 if never called; 4..200 allowed).
All movement in the code is "per frame": `x+=4` per FRAME at `set_fps(24,0)` = 96 px/s. `skip` = how many
frames may be dropped on slow machines to keep speed (irrelevant now). Several games let you change the
rate at runtime with F1/F2 (fps) and F3/F4 (skip) - a debug feature (`fpsa/fpsb` + `Framers()` process);
use the *initial* `set_fps` value and drop the debug keys (or keep them as a debug option).
Some games use very high values (`set_fps(100,0)`, `(200,0)`, `(300,0)`); on 2004-era DOSBox they probably
ran slower than requested - start from the requested value, then tune by feel if obviously too fast, and
note it in your report.

Conversion (F = the game's set_fps value, delta in seconds):
| DIV per-frame quantity | Godot per-second | code |
|---|---|---|
| speed `v` px/frame | `v * F` px/s | `position.x += v * F * delta` |
| acceleration `a` px/frame^2 (speed += a each frame) | `a * F * F` px/s^2 | `vel += a*F*F*delta` |
| angular speed `w` thousandths-deg/frame | `w * F / 1000` deg/s | `rotation -= deg_to_rad(w*F/1000.0)*delta` |
| delay of `n` frames (or `FRAME(100*n)`) | `n / F` s | Timer.wait_time |
| counter incremented every frame, compared to `k` | `k / F` s | |
| per-frame factor `v = v*k/100` (friction) | `pow(k/100.0, F*delta)` | |
| random chance per frame `rand(0,100)<p` | rate `p/100*F` per second | `randf() < p/100.0*F*delta` |
| animation: graph changes every m frames | `F / m` fps | SpriteFrames speed |

If a game's logic is dense with frame counters and integer steps (fighting game, puzzle stepping, cellular
toys), it is legitimate to keep the logic per-tick: set `Engine.physics_ticks_per_second = F` (Project
Settings > Physics > Common) and run the logic in `_physics_process` without delta (one call = one DIV
frame), optionally with physics interpolation for smooth rendering. State which approach you used.
`resolution=100` games: divide positions and speeds by 100 when converting (`advance(1600)` with
resolution 100 = 16 px/frame).

---------------------------------------------------------------------------------------------------

## 6. Built-in functions used by the games (with Godot equivalents)

Counts = occurrences in all of Oleg's PRGs (incl. copies). Full original text for each: grep
`_shared/DIV_HELP_REFERENCE.md`. "Pt" = pixel. Angles are thousandths of degrees, counter-clockwise.

### 6.1 Setup and resources
| Function (count) | Semantics | Godot |
|---|---|---|
| `set_mode(m640x480)` (55) | screen resolution; also fades out/in and **destroys scroll windows and their processes** | project.godot viewport size (section 12) |
| `set_fps(n, skip)` (78) | frames per second (section 5) | speed conversion / physics tick rate |
| `load_fpg("Olegs\X.fpg")` (62) | load graphics library, returns file code 0,1,2... | converted PNGs (`assets/fpg/x/<code>.png`) as `Texture2D` (`preload`) |
| `load_fnt("Olegs\X.fnt")` (26) | load font, returns font code 1,2,... (0 = built-in system font) | converted BMFont `assets/fnt/x/font_bmfont.fnt` as a Font (section 10) |
| `load_map("x.map")` (7) | load one graphic, returns code 1000,1001... (used as file 0) | `assets/map/x/<code>.png` |
| `load_pal("x.pal")` (1) | switch the palette (with fade) | convert assets with that palette (`--palette`) |
| `load(file, OFFSET v)` / `save(file, OFFSET v, n)` (18/21) | read/write n consecutive ints raw (little-endian int32) | `FileAccess` in `user://` (`store_32`/`get_32` or JSON); ship original data as converted `assets/dat/*.json` |
| `put_screen(file, graph)` (11) | draw a graphic centred as the static background | a Sprite2D/TextureRect at the back (z lowest), centred |
| `exit(msg, code)` (16) | quit | `get_tree().quit()` |

### 6.2 Process interaction
| Function | Semantics | Godot |
|---|---|---|
| `collision(TYPE t)` (79) | id of a process of type t whose graphic overlaps mine (**pixel-accurate**, index-0 pixels don't count); repeated calls return the next one; 0 when none. `collision(TYPE mouse)` = my graphic is under the mouse hot-spot | Area2D + CollisionShape2D/Polygon sized to the visible sprite; `area_entered` signal, or `get_overlapping_areas()` in `_physics_process`; mouse: `CollisionObject2D.input_pickable` + `input_event`, or `shape.contains point` / `Rect2.has_point(get_local_mouse_position())` |
| `get_id(TYPE t)` (74) | iterate all live processes of type t | `get_tree().get_nodes_in_group("t")` |
| `get_dist(id)` (108) | integer distance between the two processes' x,y (same resolution) | `global_position.distance_to(other.global_position)` |
| `get_angle(id)` (56) | angle from me to id, -180000..180000 | `rad_to_deg((other.global_position - global_position).angle())` -> negate for DIV ccw: DIV = `-rad_to_deg(v.angle())*1000`; usually just use the vector/`look_at` |
| `signal(id, s_kill...)` (13) | kill/sleep/freeze/wake | `queue_free()`, `process_mode`, `visible` |
| `let_me_alone()` (6) | kill all others | free entity group |
| `out_region(id, region)` (13) | true when the graphic's bounding box is fully outside the region (0 = screen) | `VisibleOnScreenNotifier2D.screen_exited` -> `queue_free()`, or a Rect2 test |
| `get_real_point(n, OFFSET x, OFFSET y)` (6) | current screen/scroll position of control point n of my graphic after angle/size/flags | a child `Marker2D` placed at (point - cp0); read `marker.global_position` |
| `define_region(n, x, y, w, h)` (9) | clipping rectangle n (1..31) for processes/scrolls | `SubViewport`/`Control.clip_contents`, or simply the split-screen viewports |

### 6.3 Movement and math
| Function | Semantics | Godot |
|---|---|---|
| `advance(d)` (82) | `x += get_distx(angle,d); y += get_disty(angle,d)` (moves along angle, ints truncated each call) | `position += Vector2.from_angle(rotation) * speed * delta` |
| `get_distx(a, d)` (21) / `get_disty(a, d)` (17) | `int(cos(a)*d)`, `int(-sin(a)*d)` (y down) | `Vector2.from_angle(-deg_to_rad(a/1000.0)) * d` |
| `fget_angle(x0,y0,x1,y1)` (9) | angle from point 0 to point 1 | `-rad_to_deg((p1-p0).angle())*1000` / `p0.angle_to_point(p1)` |
| `fget_dist(x0,y0,x1,y1)` (127) | integer distance | `p0.distance_to(p1)` |
| `near_angle(a, target, step)` (12) | turn a toward target by at most step (shortest way) | `rotate_toward(from, to, delta_rad)` |
| `rand(min, max)` (789) | random int, both inclusive | `randi_range(min, max)` |
| `rand_seed(n)` | seed | `seed(n)` |
| `abs`, `sqrt`, `pow` (48/29/43) | integer abs, truncated sqrt, integer power | `abs`, `int(sqrt())` if the truncation matters, `pow` |

Note on `advance()` at small speeds: because each component is truncated, `advance(1)` at 30 degrees moves
(0,0) - that's why Oleg uses `resolution=100`. Use float motion in Godot; the intended speed is the
nominal one.

### 6.4 Text (section 10)
| Function | Semantics | Godot |
|---|---|---|
| `write(font, x, y, align, "text")` (286) | static text, returns text id; stays until deleted | `Label` (font override) positioned by align code |
| `write_int(font, x, y, align, OFFSET var)` (265) | shows the variable's value and **updates automatically** | Label updated from a setter/signal (`Game.money_changed.connect(...)`) or in `_process` |
| `delete_text(id / all_text)` (110) | remove one / all texts. Note `all_text`=0, so `delete_text(v)` with an unset v deletes all | `label.queue_free()` / free the HUD group |
| `move_text(id, x, y)` (5) | move a text | set `position` |

### 6.5 Graphics manipulation
| Function | Semantics | Godot |
|---|---|---|
| `map_get_pixel(file, graph, x, y)` (158) | colour **index** of a pixel of a graphic - used as "hardness maps" (terrain types by colour: walls, platforms, water, level tuning values) | load the converted `indices.bin` slice (exact indices) into a `PackedByteArray` (section 9), or a TileMap/collision polygons if the map is static |
| `map_put_pixel(file, graph, x, y, color)` (161) | set a pixel in a graphic in memory (trails in OLTRON, digging in LOMMINGS, procedural grass, ant) | `Image.set_pixel` on an Image + `ImageTexture.update()` once per frame; keep a parallel index array if the game also reads it back |
| `map_put(file, dest, src, x, y)` (161) | draw graphic src into graphic dest (src's cp0 at x,y; index 0 transparent) | `Image.blend_rect` / `blit_rect_mask`, or just add a Sprite2D child |
| `map_xput(file, dest, src, x, y, angle, size, flags)` (19, LOMMINGS) | same with rotation/scale/mirror (help says x,y = top-left of src) | `Image` ops or draw via a SubViewport |
| `map_block_copy(file, dest, dx, dy, src, sx, sy, w, h)` (2) | copy a rectangle between graphics | `Image.blit_rect` |
| `put(file, graph, x, y)` / `xput(...)` (4/3) | draw permanently onto the background screen | Sprite2D at the back, or draw into a background Image |
| `put_pixel(x, y, color)` (40) / `get_pixel(x, y)` (2) | pixel on the background screen (palette index) | an Image-backed background (`Image.create(w,h,false,FORMAT_RGBA8)`) + palette lookup from `palette.json` |
| `clear_screen()` (2) | erase background drawings | clear the Image |
| `get_point(file, graph, n, OFFSET x, OFFSET y)` (13) | stored position of control point n inside the graphic (undefined -> -1,-1) | read `points[n]` from meta.json (keep a small JSON loader or bake values as constants) |
| `graphic_info(file, graph, g_wide/g_height/g_x_center/g_y_center)` | width, height, cp0 | texture size / meta.json |
| `convert_palette(file, graph, OFFSET table)` (10) | remap colour indices of a graphic (team colours in OLLWARS, HEATFIGH player 2) | pre-convert recoloured PNG variants in Python, or a palette-swap shader on `indices.bin` data |
| `roll_palette(first, count, inc)` (1) | cycle palette entries (water animation) | shader or animated frames |
| `fade(r%, g%, b%, speed)` (3), `fade_on()` (2), `fade_off()` (8) | palette fade to percentages (0 black, 100 normal, 200 white); fade_off blocks until black | `CanvasModulate`/`ColorRect` overlay animated with a Tween (`modulate` to black and back) |
| `start_scroll(...)`, `stop_scroll(n)`, `refresh_scroll(n)` (11/?/15) | scroll windows (section 11) | Camera2D / SubViewport |

### 6.6 Input
| Function | Semantics | Godot |
|---|---|---|
| `key(_code)` (678) | true while the key is held (scan code, section 7). Many games pass key codes as process parameters (`ship(1,_right,_left,_up,_down)`) for multi-player | InputMap actions per player (`p1_left`...); pass a player index or action prefix to the entity |
| `mouse.*` (122) | see 4.3 | |

### 6.7 Sound (unused by all of Oleg's games)
`load_pcm(file, loop)`, `sound(id, volume 0..256, freq 256=normal)` -> channel, `stop_sound`, `change_sound`
-> `AudioStreamPlayer` (`volume_db = linear_to_db(v/256.0)`, `pitch_scale = freq/256.0`).

---------------------------------------------------------------------------------------------------

## 7. Keyboard scan codes -> InputMap

DIV key constants are PC scan codes (physical key positions, US layout; Oleg used a German keyboard, so
`_z` is the key labelled Y on his keyboard, `_y` is Z). Define InputMap actions with **physical keycodes**
(`InputEventKey.physical_keycode`) so the positions match. Arrow keys and the numeric keypad share codes.

| DIV | code | Godot physical key | | DIV | code | Godot physical key |
|---|---|---|---|---|---|---|
| `_esc` | 1 | KEY_ESCAPE | | `_a`..`_l` | 30-38 | A S D F G H J K L |
| `_1`..`_0` | 2-11 | KEY_1..KEY_0 | | `_semicolon` | 39 | `;` (German O-umlaut) |
| `_minus` | 12 | KEY_MINUS (German sharp s) | | `_apostrophe` | 40 | `'` |
| `_plus` | 13 | KEY_EQUAL (German acute) | | `_wave` | 41 | `` ` `` |
| `_backspace` | 14 | KEY_BACKSPACE | | `_l_shift` / `_r_shift` | 42 / 54 | KEY_SHIFT |
| `_tab` | 15 | KEY_TAB | | `_backslash` | 43 | `\` |
| `_q`..`_p` | 16-25 | Q W E R T Y U I O P | | `_z`..`_m` | 44-50 | Z X C V B N M |
| `_l_brachet`/`_r_brachet` | 26/27 | `[` `]` | | `_comma` `_point` `_slash` | 51 52 53 | , . / |
| `_enter` | 28 | KEY_ENTER, KEY_KP_ENTER | | `_control` | 29 | KEY_CTRL (both) |
| `_alt` | 56 | KEY_ALT (both, incl. AltGr) | | `_space` | 57 | KEY_SPACE |
| `_caps_lock` | 58 | | | `_f1`..`_f10` | 59-68 | F1..F10 |
| `_f11` / `_f12` | 87 / 88 | F11 / F12 | | `_num_lock` / `_scroll_lock` | 69 / 70 | |
| `_home` / `_c_home` | 71 | Home, KP7 | | `_up` / `_c_up` | 72 | Up, KP8 |
| `_pgup` | 73 | PgUp, KP9 | | `_c_minus` | 74 | KP- |
| `_left` | 75 | Left, KP4 | | `_c_center` | 76 | KP5 |
| `_right` | 77 | Right, KP6 | | `_c_plus` | 78 | KP+ |
| `_end` | 79 | End, KP1 | | `_down` | 80 | Down, KP2 |
| `_pgdn` | 81 | PgDn, KP3 | | `_ins` / `_del` | 82 / 83 | Ins/KP0, Del/KP. |
| `_prn_scr` / `_c_asterisk` | 55 | Print, KP* | | `_c_backslash` | 53 | KP/ |

(The help file lists `_comma/_point/_slash` all as 51 - a typo; real values 51/52/53.)
DIV programs can always be quit with Ctrl+Esc. Keep Esc behaviour as the game defines it.
Add actions in project.godot (`[input]` section) or at startup with `InputMap.add_action()` +
`InputMap.action_add_event()`. Name them semantically (`p1_fire`) and comment the original key.

---------------------------------------------------------------------------------------------------

## 8. Recommended Godot structure

```
<GameName>/
  project.godot
  assets/                 (converter output: fpg/<name>/*.png, fnt/<name>/..., map/, dat/, manifest.json)
  scenes/
    main.tscn             title + game flow (or title.tscn, game.tscn, hud.tscn)
    player.tscn  enemy.tscn  bullet.tscn  explosion.tscn ...
  scripts/
    game.gd               autoload "Game": global state (GLOBAL section), signals, save/load
    main.gd  player.gd  enemy.gd ...
  PORTING_NOTES.md        (optional) decisions, deviations, tuning
```
Guidelines:
- One scene + script per entity (DIV process type). Root node type by need: `Area2D` for things that only
  overlap (shots, meteors, pickups), `CharacterBody2D` for things that collide/slide against walls,
  `Node2D` for pure visuals. Sprite as `Sprite2D` (`centered=false`, `offset=-cp0`) or `AnimatedSprite2D`.
- Global state in an autoload; emit signals when it changes (HUD listens) instead of polling.
- Groups for "all meteors", "all enemies" (replaces `get_id(TYPE ...)` and `signal(TYPE ...)`).
- Physics layers/masks named after roles (player, enemy, player_shot, enemy_shot, wall, pickup) instead
  of `collision(TYPE ...)` calls; collision shapes approximating the visible sprite (circle/rectangle/
  polygon; `Bitmap.opaque_to_polygons()` on the PNG alpha gives an exact polygon if precision matters).
- Movement in `_physics_process(delta)` with speeds converted per section 5; visuals/animation in
  `_process` or AnimationPlayer. Use `Timer` nodes / tweens for delays (`FRAME(n)`).
- Input via InputMap actions (section 7); multi-player entities get an action prefix or player index.
- Typed GDScript everywhere (`var speed: float = 96.0`, `func hit(damage: int) -> void`), `class_name` for
  entity scripts, `@export` for tunables. Keep DIV constants as named constants with the original value
  and unit in a comment: `const ROCKET_SPEED := 10 * 24.0  # DIV: advance(10) per frame @24fps`.
- Names: translate German identifiers to English, keep the original in a comment the first time
  (`var tax_timer: float  # DIV: Walkdircount (Duk)`). Keep German in-game texts as they are (they are part
  of the game) unless asked otherwise.
- Keep the gameplay faithful: same constants, probabilities, costs, sizes, screen positions, controls.
  Fix obvious crash bugs; note deliberate deviations in your report.

---------------------------------------------------------------------------------------------------

## 9. Collisions, hardness maps and drawing into graphics

- DIV `collision()` is pixel-exact between sprites. In Godot use shapes. Size the shape to the opaque
  pixels of the PNG (look at the image), not to the whole graphic (DIV graphics often have big transparent
  margins). Rotating/scaled processes: shape rotates/scales with the node automatically.
- **Hardness maps** (`map_get_pixel` on a level graphic: colour index = terrain type) appear in BALLER,
  BUNYJUMP, GIGAMAZE, LOMMINGS, OLTRON, MINIGOLF, STRANDED, SIEDLER, KRIEGSSI, ANT, CASTLE (levels)... The
  index values (e.g. 22 = wall, 41 = goal) are only reliable from `indices.bin` (RGBA colours may repeat).
  Loader sketch:
  ```gdscript
  class_name IndexMap extends RefCounted
  var w: int; var h: int; var data: PackedByteArray
  static func load_graphic(dir: String, code: int) -> IndexMap:
      var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(dir + "/meta.json"))
      var all := FileAccess.get_file_as_bytes(dir + "/indices.bin")
      for g in meta["graphics"]:
          if int(g["code"]) == code:
              var m := IndexMap.new()
              m.w = int(g["width"]); m.h = int(g["height"])
              var off := int(g["offset"])
              m.data = all.slice(off, off + m.w * m.h)
              return m
      return null
  func get_index(x: int, y: int) -> int:
      return 0 if x < 0 or y < 0 or x >= w or y >= h else data[y * w + x]
  ```
  (Exports: add `*.bin, *.json` to the export preset's "non-resource files" filter.) For static levels you
  may instead generate collision polygons/TileMaps from the index data offline.
- Drawing into graphics at runtime (`map_put_pixel`, `map_put`): keep an `Image` (load the PNG with
  `Image.load_from_file` or `texture.get_image()`), modify, then `ImageTexture.update(image)` once per frame.
- Background `put_pixel` drawings (DECATLON, AX2BXC, FUNKTION, RUBIK, MANDBROT, KOCHKURV): an Image-backed
  TextureRect, or `_draw()` with `draw_rect`/`draw_line` and `queue_redraw()`. Colours come from the palette
  (`palette.json` -> `palette_rgb8[index]`); colours 0-15 of the default DIV palette are a grey ramp.

---------------------------------------------------------------------------------------------------

## 10. Text and fonts

- `write(font, x, y, align, text)`: font 0 = DIV's built-in 6x8 system font (white), converted to
  `assets/fnt/system/` by the `game` command; other numbers = order of `load_fnt` calls (first = 1).
- The converter writes each font as `atlas.png` + `font_bmfont.fnt` (BMFont text format, imported by Godot
  as `FontFile`). Use it with `label.add_theme_font_override("font", load(".../font_bmfont.fnt"))` and
  **`add_theme_font_size_override("font_size", line_height)`** (meta.json `line_height`; system font = 8)
  so it is drawn 1:1. Fonts are multicolour bitmaps - leave `modulate` white. Glyph `yoffset` is preserved.
  Many fonts define only digits (BALLKILL, HATSCH1, S-TYPE2/3/4: `charset_flags` 1) or no lower case.
  The space character is usually not defined in DIV fonts; the converter gives it the width of `j`
  (or half the average width) - a guess.
- Alignment codes (x,y is the anchor):
  `0` top-left, `1` top-centre, `2` top-right, `3` middle-left, `4` centre, `5` middle-right,
  `6` bottom-left, `7` bottom-centre, `8` bottom-right. With a Label: set `size`/`horizontal_alignment`/
  `vertical_alignment` and position, or compute `font.get_string_size(text, ..., size)` and offset.
- `write_int` displays a live value: bind the Label to a signal or update it in `_process`.
- All texts are above sprites (`text_z=-256` vs z 0) and below the mouse pointer: put the HUD in a
  `CanvasLayer` unless a game changes `text_z` / gives sprites z < -256.

---------------------------------------------------------------------------------------------------

## 11. Scroll windows, regions, split screen

`start_scroll(n, file, graph, back_graph, region, lock)` shows a part of a big graphic (`graph`) in screen
region `region` (0 = full screen), optionally with a parallax background graphic `back_graph` (visible
through index-0 pixels of the foreground). `lock` bits: 1/2 = foreground repeats horizontally/vertically,
4/8 = background repeats (graphics smaller than the window always repeat). Processes with
`ctype=c_scroll` use the big graphic's coordinates and are drawn inside the window (their z is relative
to the window). The view moves either manually (`scroll[n].x0/y0` = top-left of the view in the graphic,
`x1/y1` for the background) or automatically following `scroll[n].camera = id` (centres that process,
`ratio` = background speed in % divisor (200 = half speed), `speed` = max px/frame). Without wrapping the
view stops at the graphic edges. Scroll windows draw at `scroll[n].z = 512` (behind processes at z 0).

Godot:
- Single scroll + camera: the level graphic as a Sprite2D (top-left at 0,0), entities as siblings,
  `Camera2D` following the player with `limit_left/top/right/bottom` = graphic bounds; HUD in a CanvasLayer.
- Manual scrolling (HUHNSHOT `scroll[0].x0+=8`, STRANDED sets x0,y0 from the hero): move the Camera2D
  (`camera.position = Vector2(x0, y0) + view_size/2`, `anchor_mode` = top-left is easier: `ANCHOR_MODE_FIXED_TOP_LEFT`).
- Parallax background (`ratio`): `Parallax2D` with `scroll_scale = 100.0/ratio`, `repeat_size` for wrapping.
- Split screen (THURPANZ, OLLWARS: two scroll windows in two regions): two `SubViewportContainer`s +
  `SubViewport`s sharing one `World2D` (`sub2.world_2d = sub1.world_2d`), one Camera2D per viewport.
- `define_region` for clipping only: `Control.clip_contents` or a SubViewport.
- Coordinates: code that converts between screen and scroll (`mouse.x + scroll[0].x0`) ->
  `get_global_mouse_position()` already returns world coordinates under a Camera2D.

---------------------------------------------------------------------------------------------------

## 12. Screen / project settings

```ini
[display]
window/size/viewport_width=640        ; = set_mode
window/size/viewport_height=480
window/size/window_width_override=1280   ; optional: integer multiple for small modes (320x240 -> 960x720)
window/size/window_height_override=960
window/stretch/mode="viewport"        ; pixel-exact scaling like DOS
window/stretch/aspect="keep"
window/stretch/scale_mode="integer"   ; optional, crisp pixels

[rendering]
textures/canvas_textures/default_texture_filter=0   ; Nearest
environment/defaults/default_clear_color=Color(0,0,0,1)   ; palette colour 0
```
All modes used are square-pixel (320x240, 640x480, 800x600, 1024x768); no aspect correction needed.
Import the PNGs with default 2D settings (no mipmaps, lossless). Use `Physics > Common > Physics Ticks Per
Second` only if you chose the per-tick approach (section 5).

---------------------------------------------------------------------------------------------------

## 13. DIV file formats

All little-endian. Palettes are 256 x (r,g,b) with **6-bit** components (0..63, VGA DAC); convert to 8-bit
with `c8 = (c6 << 2) | (c6 >> 4)` (63 -> 255). A 576-byte block after each palette holds the editor's colour
gradients (16 x 36 bytes) - ignore. Pixel data are 8-bit palette indices, row-major, index 0 = transparent.

**PAL** (1352 bytes): `"pal\x1a\x0d\x0a\x00"` + version byte (8 bytes), palette (768), gradients (576).

**FPG** (graphics library):
```
0      8    magic "fpg\x1a\x0d\x0a\x00\x00"
8      768  palette (6-bit)
776    576  gradients
1352   ...  entries until EOF, each:
         int32 code            graphic code 1..999 (entries are NOT sorted)
         int32 length          bytes of the whole entry = 64 + 4*npoints + width*height
         char[32] description  (zero terminated, cp850; e.g. "Duk 1")
         char[12] filename     original map name (e.g. "Map 1")
         int32 width, int32 height
         int32 npoints         number of control points stored (0..1000)
         int16 points[npoints][2]   (x, y); (-1,-1) = undefined (so cp0 may be undefined while cp1 exists)
         uint8 pixels[width*height]
```
**MAP** (single graphic):
```
0     8    magic "map\x1a\x0d\x0a\x00\x00"
8     int16 width, int16 height
12    int32 code
16    char[32] description
48    768 palette, 816 576 gradients
1392  int16 npoints, then int16 points[npoints][2]
...   uint8 pixels[width*height]
```
**FNT** (bitmap font):
```
0     8    magic "fnt\x1a\x0d\x0a\x00\x00"
8     768 palette, 776 576 gradients
1352  int32 charset flags (1 digits, 2 upper case, 4 lower case, 8 symbols, 16 extended) - informational
1356  256 x { int32 width, int32 height, int32 yoffset, int32 file_offset }   (cp850 character codes;
      width 0 = character not defined; yoffset = rows from the text top to the glyph top)
5452  glyph pixels (each width*height bytes at its file_offset)
```
Characters are drawn left to right with no extra spacing (advance = glyph width).

**System font** `DIV\SYSTEM\SYS06X08.BIN`: 256 glyphs x 6x8 bytes, 1 byte per pixel (0/1), cp850 order;
drawn in white. (`SYS08X08`, `SYS08X11`, `SYS09X16` are the editor's fonts.)

**PCM** (sound): raw unsigned 8-bit mono samples, no header, 11025 Hz (if a file starts with "RIFF" it is
already a WAV). No game of Oleg's uses sound.

**Data files** (`load()`/`save()`): raw int32 values of consecutive variables, no header, in declaration
order (tables expanded, structs field by field, nested structs innermost-last). E.g. CASTLE
`saves\Level1.dat` = `Map[36].Layer[2].Xpos[40].Ypos[30]` -> value index `((m*2+l)*40+x)*30+y`
(m = room 0..35 where room graphic = 900+2*m, l 0 = floor colour, 1 = object colour).

**Other files in the install** (not used by the games): `.FLI/.FLC` animations, `.PCX` screenshots, `.IFS`
font-generator sources, `HELP\HELP.DIV` (help hypertext, extracted to DIV_HELP_REFERENCE.md).

---------------------------------------------------------------------------------------------------

## 14. The asset converter (div_convert.py)

```
python D:/Prog/Godot/DivRemake/_shared/tools/div_convert.py <command> ...

  game <file.PRG> <assets_dir>     convert EVERYTHING a program loads (recommended)
  fpg  <file.fpg> <outdir> [--palette F] [--no-png]
  map  <file.map> <outdir> [--palette F] [--no-png]
  fnt  <file.fnt> <outdir> [--palette F]
  sysfont <DIV/SYSTEM/SYS06X08.BIN> <outdir>
  pal  <file> <outdir>              palette.json + palette.png from PAL/FPG/MAP/FNT
  pcm  <file.pcm> <out.wav> [--rate 11025]
  dat  <file.dat> <out.json>        int32 list
  info <file>                       list graphics (code, size, points, names) / glyphs
```
Example (MINICOSM):
```
python D:/Prog/Godot/DivRemake/_shared/tools/div_convert.py game D:/Prog/Godot/DivRemake/DIV/PRG/Olegs/MINICOSM.PRG D:/Prog/Godot/DivRemake/Minicosm/assets
```
`game` resolves each `load_fpg/load_fnt/load_map/load_pal/load_pcm/load/save("...")` literal outside
comments the way DIV does (section of GAMES_INDEX), converts all of them with the game palette, adds the
system font, and writes `assets/manifest.json`:
```json
{"prg": "MINICOSM.PRG", "palette_from": "FPG/Olegs/MINICOSM.FPG",
 "resources": [{"call": "load_fpg", "literal": "Olegs\\Minicosm.fpg", "kind": "fpg",
                "resolved": "FPG/Olegs/MINICOSM.FPG", "converted": "fpg/minicosm"}, ...],
 "missing": [], "commented_out": [], "system_font": "fnt/system"}
```
Output per graphics file (`assets/fpg/<name>/`, same for `map/<name>/`):
- `<code>.png` - RGBA, index 0 transparent, one per graphic code (e.g. `100.png`).
- `meta.json`:
  ```json
  {"type": "fpg", "source": "MINICOSM.FPG", "palette_rgb8": [[0,0,0], ...256],
   "graphics": [{"code": 13, "name": "Pl2", "filename": "Map 1", "width": 120, "height": 70,
                 "cp0": [29, 35], "cp0_defined": true, "points": [[29, 35]],
                 "offset": 123456, "png": "13.png"}, ...]}
  ```
  `cp0` is always set (centre if undefined); `points[n]` is `[x,y]` or `null`.
- `indices.bin` - raw palette indices of all graphics (graphic at `offset`, `width*height` bytes).
- `palette.json` (`palette_rgb8`, `palette_vga6`), `palette.png` (256x1).
Fonts (`assets/fnt/<name>/`): `atlas.png`, `font_bmfont.fnt`, `meta.json` (`line_height`, `space_advance`,
`glyphs` {cp850 code: x,y,w,h,yoffset,advance}, `charset_flags`), `indices.bin`, palette files.
Data: `assets/dat/<name>.json` (`int32_le` list) + a raw copy `<name>.dat`.
Sound: `assets/pcm/<name>.wav`.

Using a converted graphic:
```gdscript
const MINICOSM := "res://assets/fpg/minicosm/"
@onready var sprite: Sprite2D = $Sprite2D
func _ready() -> void:
    sprite.texture = preload(MINICOSM + "13.png")
    sprite.centered = false
    sprite.offset = -Vector2(29, 35)      # cp0 from meta.json -> node position = DIV (x,y)
```
For entities with several graphics (animations) build a `SpriteFrames` resource; if the frames have
different cp0, use per-frame offsets (several Sprite2D, or set `offset` when the frame changes).
Big graphics: STRANDED.FPG is 25 MB (29 large graphics); fine for Godot.
Verified: MINICOSM.FPG (55 graphics) and MINICOSM.FNT converted and rendered correctly in Godot 4.7.2
(sprite rotated around cp0, BMFont Label at font_size = line_height). All 48 FPGs, 21 FNTs and 7 MAPs in
the install parse without warnings; `game` succeeds for every PRG.

---------------------------------------------------------------------------------------------------

## 15. Porting checklist (per game agent)

1. Read `GAMES_INDEX.md` for your game (file, assets, notes), then read the WHOLE PRG (cp850). List all
   processes, globals, constants, controls (keys and mouse), screens/states, scoring, win/lose conditions.
   Look up any built-in you are unsure about in section 6 and `DIV_HELP_REFERENCE.md`.
2. Create `D:\Prog\Godot\DivRemake\<GameName>\` with `project.godot` (config_version=5, viewport =
   set_mode size, stretch mode viewport/keep, nearest filter, black clear colour, main scene, autoload
   `Game` if needed, `[input]` actions).
3. Convert assets: `python .../_shared/tools/div_convert.py game <PRG> D:/Prog/Godot/DivRemake/<GameName>/assets`.
   Check `manifest.json` (missing files!). Look at a few PNGs to identify sprites (`info` lists names).
   Copy game data (`assets/dat/*.json`) needed at runtime (levels, initial hiscores).
4. Run `godot --headless --path D:/Prog/Godot/DivRemake/<GameName> --import` once to import assets.
5. Build scenes per entity, the main/game scene, HUD, autoload. Convert speeds/timers (section 5) with the
   game's set_fps value; keep constants with comments to the original; translate identifiers to English
   with original names in comments.
6. Parse/run check (must be clean, no SCRIPT ERROR / Parse Error):
   `godot --headless --path D:/Prog/Godot/DivRemake/<GameName> --quit-after 300`
   (runs ~300 frames of the main scene headless and quits; `--quit` alone only loads).
   Also `godot --headless --path <dir> --check-only --script res://scripts/x.gd` for single scripts if needed.
   Optionally write a tiny test scene/script that simulates input (`Input.action_press`) and asserts state.
7. Optional visual check: run windowed (`godot --path <dir> --quit-after 120`) after adding a temporary
   screenshot (`get_viewport().get_texture().get_image().save_png("user://shot.png")`) and inspect it.
8. Report: what was ported, controls, deviations (fps tuning, fixed bugs, unported features), open issues.

---------------------------------------------------------------------------------------------------

## 16. Known uncertainties

- Exact speed of games with `set_fps` >= 60 on the original setup (see section 5).
- Operator precedence of AND/OR vs comparisons (help table vs actual use; treat as C-like).
- `map_xput` anchor (help: top-left of the source graphic; DIV 2 uses the control point). LOMMINGS is the only user.
- `map_block_copy`: whether index-0 pixels are copied (assume yes: plain block copy).
- Space width in DIV fonts (undefined glyph): converter uses width of 'j'.
- Fade speed units (assumed: palette components move `speed` VGA steps per frame; >= 64 = instant;
  fade_on/fade_off take roughly 8 frames).
- `get_id` never returns the caller itself (verified 2026-10-24 in the released DIV source, `src/runtime/f.c` and `src/div1run/f.c`: `if (i!=id && ...)`).
- PCM sample rate 11025 Hz (irrelevant: no game uses sound).
