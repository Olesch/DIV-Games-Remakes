class_name Shot
extends Area2D
## DIV: PROCESS Shot(x, y, angle, Art, pl) - a rocket.
## kind (DIV "Art"): 0 normal, 1 fast, 2 homing, 3 shielded (survives one hit and becomes homing).

const SPEED := 10.0 * Defs.FPS           # DIV: advance(10) per frame
const FAST_SPEED := 20.0 * Defs.FPS      # DIV: advance(10) twice per frame for Art >= 1
const MUZZLE_DISTANCE := 190.0           # DIV: advance(190) when fired by a cannon (pl == 0)
const MAGNET_DELAY_FRAMES := 16.0        # DIV: EMStop = Elektromagnet * 16
const HOMING_RANGE := 150.0              # DIV: get_dist(...) < 150
const HOMING_TURN := 7.0 * PI / 180.0    # DIV: near_angle(..., 7000) per lookup and frame
const HOMING_LOOKUPS := 50               # DIV: FROM counter=1 TO 50 get_id() calls per frame
const SPRITE_SIZE := Vector2(45, 35)

var kind: int = 0
var from_ship: bool = false

var _magnet_frames_left: float = 0.0

@onready var _sprite: Sprite2D = $Sprite


## Call before add_child().
func setup(pos: Vector2, angle: float, rocket_kind: int, fired_by_ship: bool) -> void:
	position = pos
	rotation = angle
	kind = rocket_kind
	from_ship = fired_by_ship


func _ready() -> void:
	add_to_group(&"shots")
	z_index = 1  # DIV: z = -1
	_magnet_frames_left = (1 if Game.magnet else 0) * MAGNET_DELAY_FRAMES
	_update_graphic()
	if not from_ship:
		position += Vector2.from_angle(rotation) * MUZZLE_DISTANCE


func _physics_process(delta: float) -> void:
	if Gfx.is_outside_screen(position, SPRITE_SIZE, rotation):
		queue_free()
		return
	var speed := FAST_SPEED if kind >= 1 else SPEED
	position += Vector2.from_angle(rotation) * speed * delta
	_magnet_frames_left -= delta * Defs.FPS
	if kind >= 2 and _magnet_frames_left < 0.0:
		_home_in(delta)


## A meteor was hit by this rocket: it is used up, except the shielded rocket which
## degrades to a homing one.
func absorb_hit() -> void:
	if kind == 3:
		kind = 2
		_update_graphic()
	else:
		queue_free()


func _update_graphic() -> void:
	Gfx.apply(_sprite, 20 + kind)  # DIV: graph = 20 + Art


## Turn towards nearby metal meteors. The original calls get_id() 50 times per frame, cycling through
## all meteors (plus one "no process" result per cycle), and each metal meteor within 150 px turns
## the rocket by up to 7 degrees every time - so a lone metal meteor is locked on almost at once.
func _home_in(delta: float) -> void:
	var meteors := get_tree().get_nodes_in_group(&"meteors")
	var count := meteors.size()
	if count == 0:
		return
	var step := HOMING_TURN * delta * Defs.FPS
	for i in HOMING_LOOKUPS:
		var index := i % (count + 1)
		if index == count:
			continue
		var meteor := meteors[index] as Meteor
		if meteor == null or meteor.is_queued_for_deletion() or not meteor.is_metal():
			continue
		if position.distance_to(meteor.position) < HOMING_RANGE:
			var target := (meteor.position - position).angle()
			rotation += clampf(angle_difference(rotation, target), -step, step)
