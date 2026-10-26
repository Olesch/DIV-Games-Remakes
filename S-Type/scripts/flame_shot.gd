class_name FlameShot
extends Area2D
## DIV: Flameshot(x,y,angle,power) - short-lived growing flame blob that follows the ship's
## movement a little; damages one enemy and vanishes.

var angle := 0
var power := 1
var strength := 2
var size_pct := 5.0
var ship: Ship = null
var _last_ship_pos := Vector2.ZERO
var _inc := Vector2.ZERO
var _first := true


static func fire(pos: Vector2, flame_angle: int, flame_power: int, owner_ship: Ship) -> void:
	var f := Scenes.FLAME_SHOT.instantiate() as FlameShot
	f.position = pos
	f.angle = flame_angle
	f.power = flame_power
	f.ship = owner_ship
	Game.add_entity(f)


func _ready() -> void:
	strength = 2 + Game.passive_loss * 2
	Gfx.apply($Sprite, 105)
	modulate.a = 0.5  # DIV flags=4
	_last_ship_pos = ship.position if ship else position
	$Shape.shape = CircleShape2D.new()
	_apply_size()


func _apply_size() -> void:
	scale = Vector2.ONE * size_pct / 100.0
	rotation = Div.rot(angle)
	($Shape.shape as CircleShape2D).radius = 13.0


func _physics_process(_delta: float) -> void:
	if _first:
		# DIV: "FRAME;" first, then the ship's movement during that frame becomes the drift
		_first = false
		if ship != null and is_instance_valid(ship):
			_inc = ship.position - _last_ship_pos
			_last_ship_pos = ship.position
		return
	position += _inc
	size_pct += 3.0
	angle += 1000
	_apply_size()
	for i in 2:
		position += Div.vec(angle, 2.5)
		var hit := Hit.first_enemy($Shape)
		if hit != null:
			hit.take_damage(strength)
			queue_free()
			return
	if ship != null and is_instance_valid(ship):
		_inc = (ship.position - _last_ship_pos) / 3.0
		_last_ship_pos = ship.position
	else:
		_inc = Vector2.ZERO
	if position.x > 800.0 or position.x < 0.0 or position.y > 600.0 or position.y < 0.0 \
			or size_pct > 50.0 + power * 30.0:
		queue_free()
