class_name Rocket
extends SpaceBody
## Rocket (DIV process Rocket): fired with both turn keys held + fire. Inherits the ship's velocity,
## is pulled by the planet's gravity, lives at most 600 frames (20 s), ignores shields.

const MUZZLE_DIST := 1800
const SPEED := 5000            # added to the ship's velocity (xinc units)
const MAX_FRAMES := 600
const DAMAGE := 70

var angle := 0
var alive := true
var age := 0
var _launch_tick := -1
var _wrapped := false          # this step crossed the edge of the playfield

@onready var sprite: Sprite2D = $Sprite2D


func setup(x: int, y: int, a: int, ship_xinc: int, ship_yinc: int) -> void:
	px = x
	py = y
	angle = a
	xinc = ship_xinc
	yinc = ship_yinc
	radius = 4.0


func launch() -> void:
	Gfx.apply(sprite, Gfx.ROCKET)
	sprite.centered = true
	sprite.offset = Vector2.ZERO
	add_to_group(&"rockets")
	add_to_group(&"gravity_bodies")
	add_to_group(&"round_entities")
	px += DivMath.dist_x(angle, MUZZLE_DIST)
	py += DivMath.dist_y(angle, MUZZLE_DIST)
	xinc += DivMath.dist_x(angle, SPEED)
	yinc += DivMath.dist_y(angle, SPEED)
	_launch_tick = Engine.get_physics_frames()
	_step()                      # the DIV process runs its first loop pass at creation
	if alive:
		rotation = -deg_to_rad(angle / 1000.0)
		place(true)


func end_round() -> void:
	if alive:
		Game.effects.particles(px, py, 5, 200)
		alive = false
		queue_free()


func _physics_process(_delta: float) -> void:
	if not alive or Engine.get_physics_frames() == _launch_tick:
		return
	_step()
	if alive:
		place(_wrapped)


func _step() -> void:
	var fx := Game.effects
	age += 1
	fx.particles(px, py, 0, 100)
	px += xinc / 10
	py += yinc / 10
	for ship in Game.alive_ships():
		if overlaps(ship):
			fx.particles(px, py, 5, 200)
			ship.energy -= DAMAGE
			_destroy()
			return
	if overlaps(Game.planet):
		fx.particles(px, py, 5, 200)
		_destroy()
		return
	for asteroid: Asteroid in get_tree().get_nodes_in_group(&"asteroids"):
		if overlaps(asteroid):
			fx.particles(px, py, 5, 200)
			var a := get_angle(asteroid)
			asteroid.xinc += DivMath.dist_x(a, 1400)
			asteroid.yinc += DivMath.dist_y(a, 1400)
			_destroy()
			return
	_wrapped = wrap_world()
	if age > MAX_FRAMES:
		fx.particles(px, py, 5, 200)
		_destroy()


func _destroy() -> void:
	alive = false
	queue_free()
