class_name Flag
extends SpaceBody
## The flag of "Hold the Flag" (DIV process Flag). It drifts until a ship touches it; the carrier
## drags it along (10 px up-right) and loses it by dying or by flying faster than 10000.

const DRIFT_MIN := 800
const DRIFT_MAX := 1200
const LOSE_SPEED := 10000

var immunity := 0             # frames during which a dropped flag can't be picked up again

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	Gfx.apply(sprite, Gfx.FLAG)
	radius = 6.0
	centre_offset = Vector2(-4.5, -8.0)    # centre of the 10x17 graphic relative to control point (9,16)
	px = randi_range(0, Game.WORLD_W)
	py = randi_range(0, Game.WORLD_H)
	_random_drift()
	Game.flag = self
	place(true)


func _exit_tree() -> void:
	if Game.flag == self:
		Game.flag = null


func _random_drift() -> void:
	xinc = randi_range(DRIFT_MIN, DRIFT_MAX) * (randi_range(0, 1) * 2 - 1)
	yinc = randi_range(DRIFT_MIN, DRIFT_MAX) * (randi_range(0, 1) * 2 - 1)


func _physics_process(_delta: float) -> void:
	var jumped := false
	var carrier := Game.follow
	if not is_instance_valid(carrier):
		Game.follow = null
		for ship in Game.alive_ships():
			if overlaps(ship):
				if immunity < 0:
					Game.follow = ship
				break
		px += xinc / 10
		py += yinc / 10
		jumped = wrap_world()
		if overlaps(Game.planet):
			px = randi_range(0, Game.WORLD_W)
			py = randi_range(0, Game.WORLD_H)
			jumped = true
	else:
		px = carrier.px + 1000
		py = carrier.py - 1000
		jumped = true
		if carrier.energy < 0:
			_drop()
		else:
			var movement := DivMath.isqrt(carrier.xinc * carrier.xinc + carrier.yinc * carrier.yinc)
			if movement > LOSE_SPEED:
				immunity = 5
				_drop()
	immunity -= 1
	place(jumped)


func _drop() -> void:
	Game.follow = null
	_random_drift()
	px += 2 * xinc
	py += 2 * yinc
