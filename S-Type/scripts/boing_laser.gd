class_name BoingLaser
extends Area2D
## DIV: BoingLaser(x,y,angle,Power,nothit) - fast piercing-ish beam: 6 sub-steps per tick, leaves a
## trail, damages the first enemy it meets (not `nothit`) and, if Power>0, splits into two weaker
## lasers (one random, one homing on the nearest other enemy).

var angle := 0
var power := 0
var nothit: Node = null
var strength := 10
var size_pct := 50.0
var _spawn_tick := 0


static func fire(pos: Vector2, laser_angle: int, laser_power: int, not_hit: Node) -> void:
	var l := Scenes.BOING_LASER.instantiate() as BoingLaser
	l.position = pos
	l.angle = laser_angle
	l.power = laser_power
	l.nothit = not_hit
	Game.add_entity(l)


func _ready() -> void:
	_spawn_tick = Game.ticks
	strength = 10 + power * 10
	size_pct = 50.0 + power * 20.0
	Gfx.apply($Sprite, 104)
	scale = Vector2.ONE * size_pct / 100.0
	rotation = Div.rot(angle)
	var r := RectangleShape2D.new()
	r.size = Vector2(18, 6)
	$Shape.shape = r
	_step()


func _physics_process(_delta: float) -> void:
	if Game.ticks == _spawn_tick:
		return
	_step()


func _step() -> void:
	var trail := PackedVector2Array()
	for i in 6:
		trail.append(position)  # DIV: BoingLaserSpec(x,y,angle) before each advance
		position += Div.vec(angle, 0.2 * size_pct)
		var hit := Hit.first_enemy($Shape)
		if hit != null and hit != nothit:
			hit.take_damage(strength)
			if power > 0:
				_split(hit)
			_finish(trail)
			return
		if position.x > 800.0 or position.x < 0.0 or position.y > 600.0 or position.y < 0.0:
			_finish(trail)
			return
	Ghost.create(104, trail, size_pct, rotation, 3, 1.0)


func _finish(trail: PackedVector2Array) -> void:
	if not trail.is_empty():
		Ghost.create(104, trail, size_pct, rotation, 3, 1.0)
	queue_free()


func _split(hit: Enemy) -> void:
	BoingLaser.fire(position, Div.rand(-180000, 180000), power - 1, hit)
	# "Tried to make it homing": nearest living enemy of the four ordinary kinds
	var nearest: Node2D = null
	for group in [&"snakes", &"boomers", &"jump_shooters", &"bombs"]:
		for n in Game.get_tree().get_nodes_in_group(group):
			var e := n as Enemy
			if e == null or e == hit or e.life <= 0:
				continue
			if nearest == null or position.distance_to(e.position) < position.distance_to(nearest.position):
				nearest = e
	if nearest != null:
		BoingLaser.fire(position, Div.angle_to(position, nearest.position), power - 1, hit)
	else:
		BoingLaser.fire(position, Div.rand(-180000, 180000), power - 1, hit)
