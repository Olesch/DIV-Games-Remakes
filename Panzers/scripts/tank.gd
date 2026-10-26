class_name Tank
extends Node2D
## One player's tank (DIV processes Panzer + Turm). The hull drives and turns, the turret is a
## separate sprite pivoting on hull control point 1 and rotating on its own.
## New (owner's decision 2026-10-26): `life` hits, then the tank explodes and stays as a wreck.

signal destroyed

const SHOT_SCENE := preload("res://scenes/shot.tscn")

const DRIVE_SPEED := 10.0 * Game.FPS              # DIV: advance(10) per frame
const HULL_TURN := deg_to_rad(7.0 * Game.FPS)     # DIV: angle +-= 7000 per frame
const TURRET_TURN := deg_to_rad(10.0 * Game.FPS)  # DIV: extra turret keys, angle +-= 10000 per frame
const FIRE_INTERVAL := 1.0 / Game.FPS             # DIV: Schuss(...) every frame while the key is held

## Hull graphic 1: cp0 undefined -> centre (35,25); control point 1 = turret pivot (26,25).
const HULL_CP0 := Vector2(35, 25)
const TURRET_PIVOT_ON_HULL := Vector2(26, 25) - HULL_CP0

## Hull graphic 1: the opaque part (tracks included) around the centre, for shell hits.
const HULL_HALF_SIZE := Vector2(35, 25)

## Action prefix "p1" / "p2" (see Game.KEYS)
@export var player: String = "p1"

## Turret direction in Godot rotation (clockwise on screen); starts at 0 like DIV.
var turret_angle: float = 0.0
var shots_fired: int = 0
## Hits left (Game.life at the start; unused in the sandbox)
var life: int = 0
var alive: bool = true
var _fire_timer: float = 0.0

@onready var _hull: Sprite2D = $Hull
@onready var _turret: Sprite2D = $Turret
@onready var _shots_parent: Node = get_parent()


func _ready() -> void:
	life = Game.life
	# DIV paints grass over the tank graphics too (Graszeichner(1) and (2)), which makes the tanks
	# the same noisy green as the lawn - practically invisible. The "Camouflage" option, default off.
	if Game.camouflage:
		_hull.material = Camo.material_for(_hull.texture)
		_turret.material = Camo.material_for(_turret.texture)
	_turret.top_level = true  # the turret has its own absolute angle
	_update_turret()


func _act(action: String) -> StringName:
	return StringName("%s_%s" % [player, action])


func _process(delta: float) -> void:
	# DIV angle is counter-clockwise (left key = +angle); Godot rotation is clockwise on screen.
	var turn := Input.get_axis(_act("right"), _act("left"))
	rotation -= turn * HULL_TURN * delta
	turret_angle -= turn * HULL_TURN * delta  # the Turm also reacts to the hull keys
	var turret_turn := Input.get_axis(_act("turret_right"), _act("turret_left"))
	turret_angle -= turret_turn * TURRET_TURN * delta
	if Input.is_action_pressed(_act("forward")):
		position += Vector2.from_angle(rotation) * DRIVE_SPEED * delta
	_update_turret()

	if Input.is_action_pressed(_act("fire")):
		_fire_timer -= delta
		var guard := 0
		while _fire_timer <= 0.0 and guard < 4:
			_fire_timer += FIRE_INTERVAL
			guard += 1
			_fire()
		if guard >= 4:
			_fire_timer = 0.0
	else:
		_fire_timer = 0.0


## DIV: Turm x,y = father.Point1 (get_real_point(1)), angle = own angle.
func _update_turret() -> void:
	_turret.global_position = global_position + TURRET_PIVOT_ON_HULL.rotated(rotation)
	_turret.global_rotation = turret_angle


func _fire() -> void:
	var shot := SHOT_SCENE.instantiate() as Shot
	shot.position = _turret.global_position
	shot.angle = turret_angle
	shot.shooter = self
	_shots_parent.add_child(shot)
	shots_fired += 1


## True if a shell of radius `radius` at global `point` touches the hull.
func hull_contains(point: Vector2, radius: float) -> bool:
	var local := to_local(point).abs()
	return local.x <= HULL_HALF_SIZE.x + radius and local.y <= HULL_HALF_SIZE.y + radius


## A shell hit the hull at global `point` (never called in the sandbox).
func take_hit(point: Vector2) -> void:
	if not alive:
		return
	life -= 1
	Blast.spawn(_shots_parent, point, 6, 90.0, 0.25, 3.0)
	if life <= 0:
		_destroy()


## Life is gone: explosion, then a burnt-out wreck that no longer moves or fires.
func _destroy() -> void:
	alive = false
	set_process(false)
	_fire_timer = 0.0
	Blast.spawn(_shots_parent, global_position, 60, 160.0, 0.9, 5.0)
	_hull.material = Camo.material_for(_hull.texture, Camo.ASH)
	_turret.material = Camo.material_for(_turret.texture, Camo.ASH)
	destroyed.emit()
