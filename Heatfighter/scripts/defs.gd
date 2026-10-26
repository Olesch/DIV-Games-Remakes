class_name Defs
extends RefCounted
## Constants shared by the fighters. All positions/speeds are kept in DIV units (hundredths of a
## pixel, "resolution=100") and advance once per physics tick (original set_fps(100); 60 by owner decision).

const FPS := 60                   # physics ticks per second (original set_fps(100,0); owner chose 60)
const FLOOR_Y := 37000            # y of a standing fighter (DIV: y>=37000 means landed)
const WALL_RIGHT := 64000         # x limits of the arena
const START_LIFE := 6000          # DIV: Lifepoints=6000
const MAX_MANA := 10000
const START_X := [26000, 38000]   # Fighter 1 / Fighter 2 start x
const SHOVE_DISTANCE := 1500      # fighters closer than this push each other (if |dy| < 4500)

## DIV "Position" (the fighter's move/state).
enum State {
	STAND = 1, WALK = 2, JUMP = 3, DUCK = 4, HIT = 5, FLY = 6, LIE = 7,
	LIGHT = 8, HEAVY = 9, AIR_LIGHT = 10, AIR_HEAVY = 11, DUCK_LIGHT = 12, DUCK_HEAVY = 13,
	SPECIAL_1 = 20, SPECIAL_2 = 21,
}

## DIV "BlockPosition" (which block the fighter is holding) and "StehPosition" (stance).
enum Stance { NONE = 0, LOW = 1, MID = 2, HIGH = 3 }

## DIV "AngriffsArt": which blocks can stop an attack.
enum AttackType { NONE = 0, LOW = 1, MID = 2, HIGH = 3 }

enum Character { TEMPLATE = 1, CHAIN = 2, EIGEN = 3 }

const CHARACTER_NAMES := {
	Character.TEMPLATE: "Template",
	Character.CHAIN: "Chain",
	Character.EIGEN: "Eigen",
}
