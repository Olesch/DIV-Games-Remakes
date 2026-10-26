class_name Shot
extends Node2D
## Eigen fireballs (DIV: PROCESS Schuss_Eigen_1 / Schuss_Eigen_2).
##  kind 1: a flickering fireball that stays 60 px in front of the caster for 1 s and hurts on contact.
##  kind 2: a big energy ball that grows, then homes in on the enemy for up to 3 s and shrinks away.

@warning_ignore_start("integer_division")

const SCENE := preload("res://scenes/shot.tscn")
const GRAPH := 101

@onready var sprite: Sprite2D = $Sprite2D

var kind: int = 1
var caster: Fighter
var victim: Fighter
var facing: int = 1          # DIV: Richtung
var x: int = 0               # DIV units
var y: int = 0
var size: int = 100          # percent
var _frame_var: int = 0
var _punch_done: int = 0
var _counter: int = 0
var _speed_x: int = 0
var _speed_y: int = 0
var _growing: bool = false


static func spawn(parent: Node, from: Fighter, shot_kind: int) -> void:
	var shot := SCENE.instantiate() as Shot
	shot.kind = shot_kind
	shot.caster = from
	shot.victim = from.opponent
	shot.facing = from.facing
	shot.x = from.x
	shot.y = from.y
	if shot_kind == 1:
		shot.x += 6000 * shot.facing
	else:
		shot.x += 2700 * shot.facing
		shot.y -= 6500
		shot.size = 0
		shot._growing = true
	parent.add_child(shot)


func _ready() -> void:
	Gfx.apply(sprite, caster.profile.gfx_set, GRAPH)
	_sync()
	reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	if kind == 1:
		_tick_fireball()
	else:
		_tick_energy_ball()
	_sync()


func _sync() -> void:
	position = Vector2(x, y) / 100.0
	scale = Vector2.ONE * size / 100.0


func _spark(px: int, py: int, spark_size: int) -> void:
	HitEffect.spawn(get_parent(), px, py, spark_size, randi_range(8, 9))


func _hit_victim(stun: int, dmg: int, launch_x: int, launch_y: int, push: int, spark_size: int) -> void:
	_punch_done = 1
	# The victim can only block a fireball if its stance says how (crouching / standing).
	var type := -1
	if victim.stance == Defs.Stance.LOW:
		type = Defs.AttackType.LOW
	elif victim.stance == Defs.Stance.MID:
		type = Defs.AttackType.MID
	victim.receive_hit(stun, dmg, launch_x * facing, launch_y, push * facing, type,
		x, y, spark_size, randi_range(8, 9))


func _tick_fireball() -> void:
	rotation += randf_range(-PI, PI)  # DIV: angle += rand(-180000, 180000)
	_counter = (_counter + 1) % 4
	if _counter == 1:
		_spark(x + randi_range(-4500, 4500), y + randi_range(-4500, 4500), randi_range(50, 120))
		_spark(x + randi_range(-100, 100), y + randi_range(-100, 100), randi_range(85, 115))
	_frame_var += 1
	if _frame_var > 100:
		queue_free()
		return
	if absi(x - victim.x) < 3500 and absi(y - victim.y) < 3500 and _punch_done != 1:
		_hit_victim(450, 200, 600, 800, 400, 150)
	if _frame_var % 20 == 0 and _frame_var <= 80:
		_punch_done = 0  # it can hit again every 20 ticks


func _tick_energy_ball() -> void:
	if _growing:
		size += 2
		_spark(x + randi_range(-45 * size, 45 * size), y + randi_range(-45 * size, 45 * size),
			size + randi_range(-10, 20))
		if size > 75:
			_growing = false
		return
	_steer_towards(victim.x, victim.y)
	x += _speed_x
	y += _speed_y
	rotation += randf_range(-PI, PI)
	if randi_range(0, 1) == 1:
		_spark(x + randi_range(-45 * size, 45 * size), y + randi_range(-45 * size, 45 * size),
			size + randi_range(-10, 20))
	_frame_var += 1
	if _frame_var > 300:
		size -= 1
		if size < 0:
			queue_free()
			return
	if absi(x - victim.x) < 2000 and absi(y - victim.y) < 2000 and _punch_done != 1:
		_hit_victim(250, 100, 700, 900, 400, 100)
	_counter = (_counter + 1) % 20
	if _counter == 0:
		_punch_done = 0


## Homing: accelerates towards the target; the speed clamps are the original ones (they only cap the
## speed in the "wrong" direction, so the ball overshoots and swings around the target).
func _steer_towards(tx: int, ty: int) -> void:
	if x + 2 * _speed_x > tx:
		if _speed_x > 500:
			_speed_x = 500
		_speed_x -= 25 + randi_range(-10, 10)
	if x + 2 * _speed_x < tx:
		if _speed_x < -500:
			_speed_x = -500
		_speed_x += 25 + randi_range(-10, 10)
	if y + 2 * _speed_y > ty:
		if _speed_y > 500:
			_speed_y = 500
		_speed_y -= 25 + randi_range(-10, 10)
	if y + 2 * _speed_y < ty:
		if _speed_y < -500:
			_speed_y = -500
		_speed_y += 25 + randi_range(-10, 10)
