class_name Shot
extends SpaceBody
## Laser shot (DIV process Shot). Up to 21 steps of 10 px.
## Original: FRAME(1) after each step lets the shot run all its steps within a single frame (an
## instant "hit-scan" beam drawn as a row of dots) - except Lasershot and Machinelasershot, which add
## FRAME(99) and fly one step per frame (slow bolt, 300 px/s).

const STEPS := 21
const STEP_DIST := 1000        # advance(1000)
const MUZZLE_DIST := 1800      # advance(1800) before the first step

var angle := 0
var counter := 0
var _slow := false
var _launch_tick := -1
var _jumped := false           # this step wrapped around or was reflected by a shield

@onready var sprite: Sprite2D = $Sprite2D


func setup(x: int, y: int, a: int) -> void:
	px = x
	py = y
	angle = a
	radius = 7.0


func launch() -> void:
	Gfx.apply(sprite, Gfx.LASER)
	sprite.centered = true
	sprite.offset = Vector2.ZERO
	sprite.scale = Vector2.ONE * 1.3
	add_to_group(&"shots")
	add_to_group(&"round_entities")
	_launch_tick = Engine.get_physics_frames()
	if Game.laser_type == 6:
		angle = get_angle(Game.planet)       # GravitLaser shoots at the planet
	_laser_dot()
	_advance(MUZZLE_DIST)
	_slow = Game.laser_type == 2 or Game.laser_type == 3
	var done := _step()
	if not _slow:
		while not done:
			done = _step()
	if done:
		queue_free()
	else:
		_update_view(true)


func end_round() -> void:
	queue_free()


func _physics_process(_delta: float) -> void:
	if not _slow or Engine.get_physics_frames() == _launch_tick:
		return
	_jumped = false
	if _step():
		queue_free()
	else:
		_update_view(_jumped)


## One iteration of the DIV FOR loop. Returns true when the shot is finished.
func _step() -> bool:
	var fx := Game.effects
	var type := Game.laser_type
	if type == 0 or type == 2:
		fx.particles(px, py, 0, 100)
	elif randi_range(0, 3) == 0:
		fx.particles(px, py, 0, 100)
	_advance(STEP_DIST)
	if type == 4:
		angle += 16000                       # Spreader: the beam curls
	for ship in Game.alive_ships():
		if overlaps(ship):
			fx.particles(px, py, 5, 500)
			if not ship.shielded:
				ship.energy -= Game.LASER_STATS[type][2]
				return true
			# shield reflects the beam backwards (+-20 degrees) and costs it steps
			counter -= 7
			angle += randi_range(160000, 200000)
			_advance(MUZZLE_DIST)
			_jumped = true
			break
	for rocket: Rocket in get_tree().get_nodes_in_group(&"rockets"):
		if rocket.alive and overlaps(rocket):
			fx.particles(px, py, 4, 100)
			rocket.alive = false
			rocket.queue_free()
			return true
	if overlaps(Game.planet):
		fx.particles(px, py, 2, 200)
		return true
	for asteroid: Asteroid in get_tree().get_nodes_in_group(&"asteroids"):
		if overlaps(asteroid):
			fx.particles(px, py, 2, 200)
			var a := get_angle(asteroid)
			asteroid.xinc += DivMath.dist_x(a, 800)
			asteroid.yinc += DivMath.dist_y(a, 800)
			return true
	_laser_dot()
	if wrap_world():
		_jumped = true
	counter += 1
	return counter >= STEPS


func _advance(dist: int) -> void:
	px += DivMath.dist_x(angle, dist)
	py += DivMath.dist_y(angle, dist)


func _laser_dot() -> void:
	Game.effects.spec(Gfx.LASER, px / 100, py / 100, -deg_to_rad(angle / 1000.0), 130)


func _update_view(teleported: bool) -> void:
	rotation = -deg_to_rad(angle / 1000.0)
	place(teleported)
