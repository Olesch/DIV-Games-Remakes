class_name Defs
extends RefCounted
## Constants of SIEGE (names and values from the CONST block of SIEGE.PRG).
## The game never calls set_fps(), so DIV runs it at the default 18 frames per second.
## All timing in this port is counted in DIV frames: the physics tick rate is set to 18
## (project.godot) and every "process" advances once per physics tick.

const FPS := 18
const SCREEN := Vector2i(320, 240)

const TIM_BUILD := 0           # Zeit zum Aktivieren der gebauten Einheiten (frames)
const TIM_RESET := 30          # Zeit zum Reseten des Feldes (frames)

const LP_KRIEGER := 6          # warrior life
const SPD_KRIEGER := 4         # smaller -> faster

const DAM_PFEIL := 7           # archer arrow damage
const EXP_PFEIL := 12          # archer arrow blast radius

const LP_RAMME := 25
const SPD_RAMME := 8

const DAM_BOMBER := 10
const EXP_BOMBER := 18
const SPD_BOMBER := 3

const DAM_KATAPULT := 5        # damage PER explosion part
const PAR_KATAPULT := 4        # number of explosions
const EXP_KATAPULT := 12       # blast and scatter radius

const DAM_BALLISTE := 12       # damage of the bolt (2 explosions!)
const EXP_BALLISTE := 12

const LP_RANKEN := 30          # vines

const LP_RITTER := 15          # knight
const SPD_RITTER := 5          # different speeding! at least 2

const LP_WOLKE := 25           # cloud

const DAM_MAGIER := 12         # mage laser damage

const LP_ARBEITER := 16        # castle life repaired by the worker
const TIM_ARBEITER := 25       # time the worker needs (about seconds; x15 frames)

const LP_ELEFANT := 35
const SPD_ELEFANT := 4

const LP_TURM := 14            # tower
const DAM_TURM := 4
const EXP_TURM := 12
const TIM_TURM := 30           # frames between shots

const PAR_METEOR := 3
const DAM_METEOR := 6
const EXP_METEOR := 12

const DAM_PEST := 10
const EXP_PEST := 20

const LP_LUFTSCHIFF := 20      # airship
const EXP_LUFTSCHIFF := 12
const DAM_LUFTSCHIFF := 7
const TIM_LUFTSCHIFF := 27     # frames between bombs
const SPD_LUFTSCHIFF := 2

const LP_GOLEM := 80
const SPD_GOLEM := 4

const LP_DRACHE := 30          # dragon
const EXP_DRACHE := 15
const DAM_DRACHE := 3
const PAR_DRACHE := 6
const TIM_DRACHE := 50
const SPD_DRACHE := 4

const LP_TOTENBESCHWOERER := 1 # necromancer
const SPD_TOTENBESCHWOERER := 2
const PAR_TOTENBESCHWOERER := 3  # intended max skeleton count (the original check never works, see Unit)

const LP_SKELETT := 3
const SPD_SKELETT := 5

## Unit art numbers (DIV: Unit(art, player))
enum UnitArt {
	KRIEGER = 1, RAMME = 2, BOMBER = 3, RANKEN = 4, RITTER = 5, WOLKE = 6, ELEFANT = 7,
	TURM = 8, LUFTSCHIFF = 9, GOLEM = 10, DRACHE = 11, TOTENBESCHWOERER = 12, SKELETT = 13,
}
## Animation art numbers (DIV: Animation(art, player))
enum AnimArt { BOGENSCHUETZE = 1, KATAPULT = 2, BALLISTE = 3, MAGIER = 4, ARBEITER = 5, PEST = 6 }
## Shot art numbers (DIV: Shot(art, player))
enum ShotArt { PFEIL = 1, STEIN = 2, BOLZEN = 3, TURMPFEIL = 4, METEOR = 5, LUFTSCHIFF = 6, DRACHE = 7 }
