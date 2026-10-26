class_name PlayerTwo
extends Node2D
## DIV: PROCESS PlayerTWO() + PLTWOUP() - the bought ship, flown with the arrow keys and
## fired with Ctrl. The turret picture is a child sprite rotating with the hull.

const TURN_SPEED := 10.0 * Defs.FPS         # degrees/s (DIV: angle +/- 10000 per frame)
const ACCELERATION := 1.0 * Defs.FPS        # (px/frame)/s: velocity +/- 1 per frame
const MAX_FORWARD := 9.0                    # px/frame
const MAX_REVERSE := -6.0
const WRAP_MARGIN := 20.0

var _velocity := 0.0       # px per DIV frame
var _cooldown := 0.0       # seconds until the next shot (DIV: shotWait)

@onready var _hull: Sprite2D = $Hull
@onready var _turret: Sprite2D = $Turret


func _ready() -> void:
	position = Defs.SCREEN_SIZE / 2.0
	Gfx.apply(_hull, 13)
	Gfx.apply(_turret, 14)
	_turret.z_index = 2  # DIV: PLTWOUP z = -2


func _physics_process(delta: float) -> void:
	# DIV angles run counter-clockwise, Godot rotation clockwise.
	if Input.is_action_pressed(&"p2_left"):
		rotation -= deg_to_rad(TURN_SPEED) * delta
	if Input.is_action_pressed(&"p2_right"):
		rotation += deg_to_rad(TURN_SPEED) * delta
	if Input.is_action_pressed(&"p2_up"):
		_velocity = minf(_velocity + ACCELERATION * delta, MAX_FORWARD)
	if Input.is_action_pressed(&"p2_down"):
		_velocity = maxf(_velocity - ACCELERATION * delta, MAX_REVERSE)
	position += Vector2.from_angle(rotation) * _velocity * Defs.FPS * delta

	_cooldown -= delta
	if Input.is_action_pressed(&"p2_fire") and _cooldown <= 0.0:
		var shot := preload("res://scenes/shot.tscn").instantiate() as Shot
		shot.setup(position, rotation, Game.super_rocket, true)
		get_parent().add_child(shot)
		_cooldown = (45 - Game.reload_level * 6) / Defs.FPS  # DIV: shotWait = 45 - Nachladezeit*6

	_wrap_around()


## DIV: PROCESS new_coordinates() - leave left/right and reappear on the other side, stay in y.
func _wrap_around() -> void:
	var width := Defs.SCREEN_SIZE.x + 2.0 * WRAP_MARGIN
	if position.x < -WRAP_MARGIN:
		position.x += width
	if position.x > Defs.SCREEN_SIZE.x + WRAP_MARGIN:
		position.x -= width
	position.y = clampf(position.y, 0.0, Defs.SCREEN_SIZE.y)
