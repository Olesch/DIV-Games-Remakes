class_name Planet
extends SpaceBody
## The planet in the middle (DIV process Planet): pulls ships, rockets and asteroids with integer
## inverse-square gravity and kills any ship that touches it.
## DIV: Fx = (k*x)/sqrt(pow(pow(x,2)+pow(y,2),3)), distances in units of 10 px.

var weight := 8000
var size_percent := 100

@onready var sprite: Sprite2D = $Sprite2D


func setup(x: int, y: int, gravity_value: int) -> void:
	px = x
	py = y
	weight = gravity_value
	size_percent = (weight + 2000) / 100
	radius = 39.0 * size_percent / 100.0


func _ready() -> void:
	Gfx.apply(sprite, Gfx.PLANET)
	sprite.centered = true
	sprite.offset = Vector2.ZERO
	sprite.scale = Vector2.ONE * size_percent / 100.0
	place(true)


func _physics_process(_delta: float) -> void:
	for body: SpaceBody in get_tree().get_nodes_in_group(&"gravity_bodies"):
		var dx := (body.px - px) / 1000
		var dy := (body.py - py) / 1000
		var r := DivMath.isqrt(dx * dx + dy * dy)
		var r3 := r * r * r
		if r3 == 0:
			continue                       # the original would divide by zero here
		body.xinc -= (weight * dx) / r3
		body.yinc -= (weight * dy) / r3
	for ship in Game.alive_ships():
		if overlaps(ship):
			ship.energy = -500
