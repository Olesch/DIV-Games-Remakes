class_name Boss
extends Enemy
## DIV: Endenemy1Hitpoint(art,life,y) with Endenemy1graph / Endenemy1shield / Endenemy1Cannon /
## Endenemy1laser - the level 2 end boss. This node is the vulnerable core (and the thing that
## kills ships on contact); body picture, rotating shield, six cannons and lasers are children.
## The cannons cannot be damaged in the original, so they are plain decorations that shoot.

const CANNONS := [  # weapon, x offset, y offset (px)
	[1, -11, -36], [1, -12, -12], [1, -14, 8], [1, -10, 31], [2, 24, -12], [3, 24, 8],
]

var art := 0
var amplitude := 25
var laser_wait := 0


static func spawn(boss_art: int, hit_points: int, y: int) -> Boss:
	var b := Scenes.BOSS.instantiate() as Boss
	b.art = boss_art
	b.life = hit_points
	b.position = Vector2(800, y / 100.0)
	Game.add_entity(b)
	return b


func _ready() -> void:
	Gfx.apply($Body, 400)
	Gfx.apply($Pods, 404)
	var r := RectangleShape2D.new()
	r.size = Vector2(30, 54)
	$Shape.shape = r
	$Shape.position = Vector2(5, 0)
	add_child(Scenes.BOSS_SHIELD.instantiate())
	for c in CANNONS:
		var cannon := Scenes.BOSS_CANNON.instantiate() as BossCannon
		cannon.weapon = c[0]
		cannon.position = Vector2(c[1], c[2])
		add_child(cannon)


func _physics_process(_delta: float) -> void:
	if art == 0:
		if position.x > 650.0:
			position.x -= 1.5
	else:
		position.x -= 1.5
	amplitude += 1
	if amplitude > 10 and amplitude < 40:
		position.y += 2.0
	if amplitude > 50 and amplitude < 80:
		position.y -= 2.0
	if amplitude > 80:
		amplitude = 0
	laser_wait += 1
	if laser_wait > 250 and laser_wait % 3 == 0:
		Charger.spawn(self, 406, 100)
	if laser_wait > 280:
		if Div.rand(0, 2) == 0:
			if Div.rand(0, 4) == 0:
				for a in [50000, 25000, 0, -25000, -50000]:
					_laser(a)
			else:
				_laser(25000)
				_laser(-25000)
		else:
			_laser(0)
		laser_wait = 0

	if life <= 0:
		Explosion.spawn(position, 150, 4)
		Explosion.spawn(position, 100, 6)
		Explosion.spawn(position, 70, 8)
		Explosion.spawn(position, 50, 30)
		if art == 0:
			Pickup.spawn(Pickup.Kind.LIFE, position + _scatter())
			for i in 6:
				Pickup.spawn(Pickup.Kind.MONEY, position + _scatter())
			if Game.psh >= 2:
				Pickup.spawn(Pickup.Kind.LIFE, position + _scatter())
		queue_free()
		return
	if position.x < -200.0 or position.y > 800.0 or position.y < -200.0:
		queue_free()
		return
	Hit.kill_touching_ships($Shape)


func _scatter() -> Vector2:
	return Vector2(Div.rand(-10000, 10000), Div.rand(-5000, 5000)) / 100.0


func _laser(laser_angle: int) -> void:
	var l := Scenes.BOSS_LASER.instantiate() as BossLaser
	l.angle = laser_angle
	l.position = Vector2(-25, 0)
	add_child(l)
	l.reset_physics_interpolation()  # its _ready() sets the rotation: no sweep from angle 0
