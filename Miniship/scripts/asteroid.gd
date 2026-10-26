class_name Asteroid
extends SpaceBody
## Asteroid (DIV process Asteroid): drifts, is pulled by the planet, bumps ships (10 damage per weight)
## and other asteroids. Falling into the planet makes it vanish for 70 frames, then it restarts at (0,0).

const HIDDEN_FRAMES := 70      # FRAME(7000)

var weight := 1
var _hidden := 0
var _angle := 0                # only the sprite rotation

@onready var sprite: Sprite2D = $Sprite2D


func setup(x: int, y: int) -> void:
	px = x
	py = y
	_randomize_motion()


func _randomize_motion() -> void:
	weight = randi_range(1, 3)
	var a := randi_range(-180000, 180000)
	var speed := randi_range(2000, 7000) / weight
	xinc = DivMath.dist_x(a, speed)
	yinc = DivMath.dist_y(a, speed)
	_angle = randi_range(-180000, 180000)
	radius = [10.0, 15.0, 20.0][weight - 1]
	if sprite:
		_apply_graphic()


func _apply_graphic() -> void:
	Gfx.apply(sprite, Gfx.ASTEROID_BASE + weight)
	sprite.centered = true
	sprite.offset = Vector2.ZERO
	rotation = -deg_to_rad(_angle / 1000.0)


func _ready() -> void:
	_apply_graphic()
	add_to_group(&"asteroids")
	add_to_group(&"gravity_bodies")
	place(true)


func _physics_process(_delta: float) -> void:
	if _hidden > 0:
		_hidden -= 1
		if _hidden == 0:
			px = 0
			py = 0
			_randomize_motion()
			place(true)
		return
	px += xinc / 10
	py += yinc / 10
	if overlaps(Game.planet):
		Game.effects.particles(px, py, 15, 700)
		px = -80000
		py = -80000
		_hidden = HIDDEN_FRAMES
		place(true)
		return
	var jumped := wrap_world()
	for ship in Game.alive_ships():
		if overlaps(ship):
			Game.effects.particles(px, py, 5, 500)
			bump(ship, false)
			ship.place()
			ship.energy -= 10 * weight
			_swap_with(ship)
	for other: Asteroid in get_tree().get_nodes_in_group(&"asteroids"):
		if other != self and other._hidden == 0 and overlaps(other):
			Game.effects.particles(px, py, 5, 500)
			bump(other, false)
			other.place()
			_swap_with(other)
	changed -= 1
	place(jumped)


func _swap_with(other: SpaceBody) -> void:
	if changed < 1 and other.changed < 1:
		var t := other.xinc
		other.xinc = xinc
		xinc = t
		t = other.yinc
		other.yinc = yinc
		yinc = t
		changed = 2
