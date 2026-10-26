class_name Defs
extends RefCounted
## Shared constants and helpers for Tutorial 1 (DIV: MINI1.PRG).
## The game is frame-count based (integer angles, per-frame counters), so the physics tick is
## set to the original frame rate (project setting physics_ticks_per_second=24) and every
## `_physics_process` call is exactly one DIV frame. Speeds below are therefore per tick.

## DIV: set_fps(24, 0)
const FPS := 24
## DIV: set_mode(m640x480)
const SCREEN_SIZE := Vector2(640.0, 480.0)

enum Weapon { SHOT, EXPLOSHOT }

# --- Shots (DIV: PROCESS shot) ---
const SHOT_SPAWN_DISTANCE := 36     # advance(36) when fired
const SHOT_SPEED := 7               # advance(7) per frame
const SHIELD_PUSHBACK := 6          # advance(6) after bouncing off a shield
const WALL_HIT_COST := 2            # Treffer++ twice per frame of wall contact
const WALL_PROBE := 18              # map_get_pixel(x +- 18, y) / (x, y +- 18)
const WALL_PUSH := 5                # x += 5 / y += 5 after a bounce
const FADE_STEP := 4                # shrink(..., 4): size -= 4 per frame
const SHOT_SIZE := Vector2(20.0, 20.0)

# --- Explosion shot (DIV: PROCESS Exploshot, the "mana" attack) ---
const EXPLOSHOT_RADIUS := 20        # DIV: exploshotrad, explosion size in percent
const EXPLOSHOT_SPAWN_DISTANCE := 45
const EXPLOSHOT_SPEED := 7
const EXPLOSHOT_SPREAD := 40        # rand(-40, 40) around the shot
const EXPLOSHOT_TURN := 10000       # angle += rand(-10000, 10000)
const MANA_MAX := 500               # DIV: Manamax - assigned to Mana but never used by the original
const MANA_COOLDOWN_EXTRA := 20     # shotwait < 1 - shotstop*3 - 20

# --- Explosions (DIV: PROCESS explode) ---
const EXPLOSION_FRAMES := 6         # graphs 11..16, one frame each
const EXPLOSION_SOLID_FRAMES := 4   # graphs 11..14 are filled discs; 15/16 are sparse debris
const EXPLOSION_RADIUS := 47.0

# --- Arena ---
const STAR_COUNT := 500             # FROM contador0=0 TO 499; put_pixel(rand(21,618), rand(21,458), 127)
const STAR_COLOR := Color8(243, 235, 219)  # palette index 127

## Rows of the settings screen: [Game property, original German label]. Order = DIV `zeigerpos` 1..14.
## The original labels of rows 10 and 11 were swapped relative to what the code does (Eigenkilla is
## read by the ship against shots, Eigenkillb by shots against shots); fixed on the owner's request.
const SETTING_ROWS: Array = [
	[&"max_hits", "Leben"],
	[&"max_turn_speed", "Max. Geschwingigkeit"],
	[&"turn_accel", "Beschleunigung"],
	[&"auto_brake", "Bremse"],
	[&"ship_explosion_size", "Spielerexplosionsdurchmesser"],
	[&"shot_explosion_size", "Kugelexplosionsdurchmesser"],
	[&"shot_life", "Lebensdauer der Schuesse"],
	[&"shot_delay", "Dauer zwischen den Schuessen"],
	[&"fast_fire", "Schnellfeuer? 0=nein"],
	[&"own_shots_hit_ship", "Eigenzerstoerung Schiffe? 0=nein"],
	[&"shots_hit_own_shots", "Eigenzerstoerung Schuesse? 0=nein"],
	[&"margin_h", "Entfernung vom Rand H"],
	[&"margin_v", "Entfernung vom Rand V"],
	[&"shield_mode", "Schildmodus 0=kein Schild"],
]


## DIV advance(): x += get_distx(angle, d), y += get_disty(angle, d); both are truncated to whole
## pixels, which makes diagonal shots slower than horizontal ones - kept (angle in 1/1000 degree, ccw).
static func advance_vector(angle: int, distance: int) -> Vector2:
	var rad := deg_to_rad(angle / 1000.0)
	return Vector2(_trunc(cos(rad) * distance), _trunc(-sin(rad) * distance))


static func _trunc(value: float) -> float:
	# the epsilon keeps exact results such as sin(30 deg) * 36 = 18 from truncating to 17
	return float(int(value + signf(value) * 1e-6))


## DIV angle (1/1000 degree, counter-clockwise) -> Godot rotation (radians, clockwise on screen).
static func to_rotation(angle: int) -> float:
	return -deg_to_rad(angle / 1000.0)


## DIV out_region(id, 0): the (rotated) graphic's bounding box is completely outside the screen.
static func is_outside_screen(pos: Vector2, size: Vector2, angle: int) -> bool:
	var rot := to_rotation(angle)
	var c := absf(cos(rot))
	var s := absf(sin(rot))
	var half := Vector2(c * size.x + s * size.y, s * size.x + c * size.y) * 0.5
	return (pos.x + half.x < 0.0 or pos.x - half.x > SCREEN_SIZE.x
		or pos.y + half.y < 0.0 or pos.y - half.y > SCREEN_SIZE.y)
