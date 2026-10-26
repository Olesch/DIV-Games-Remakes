class_name Shot
extends Area2D
## A shot (DIV process `shot`). Flies straight at 10 px/frame; its graphic is scaled by `size`
## percent = power*50, and a hit costs size/50 = power life points. It never hurts its shooter.

const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")
const SPEED := 10.0 * 40.0   # DIV: advance(10) per frame @40 fps
const HIT_EXPLOSION_SIZE := 50
const SCREEN := Rect2(0, 0, 800, 600)

var _power := 2
var _shooter: Ship
var _velocity := Vector2.ZERO


func setup(start: Vector2, angle_rad: float, shooter: Ship, power: int) -> void:
	position = start
	rotation = angle_rad
	_shooter = shooter
	_power = power


func _ready() -> void:
	scale = Vector2.ONE * (_power * 50 / 100.0)  # DIV size = power*50 percent
	_velocity = Vector2.from_angle(rotation) * SPEED
	add_to_group(&"shots")
	area_entered.connect(_on_area_entered)
	reset_physics_interpolation()  # show the final size at once, not growing from 100 %


func _physics_process(delta: float) -> void:
	position += _velocity * delta
	if not SCREEN.has_point(position):  # DIV: x>800 OR x<0 OR y>600 OR y<0
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var ship := area as Ship
	if ship == null or ship == _shooter:
		return
	ship.take_damage(_power)  # DIV: hit.life -= size/50
	var explosion := EXPLOSION_SCENE.instantiate() as Explosion
	explosion.setup(position, HIT_EXPLOSION_SIZE)
	get_parent().add_child(explosion)
	set_deferred(&"monitoring", false)
	queue_free()
