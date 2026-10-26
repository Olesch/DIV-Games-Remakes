class_name Boomer
extends Enemy
## DIV: Boomer(x,y,speed,moneypr,angle,anglenear,life) - homing "boomerang" that turns towards a
## random player by at most `anglenear` per frame and slowly burns out (life drops every 11th frame).

var speed := 650
var money_prob := 1
var angle := 180000
var angle_near := 2000
var pict := 4
var target := 0


static func spawn(x: int, y: int, spd: int, moneypr: int, start_angle: int, turn: int, hit_points: int) -> Boomer:
	var b := Scenes.BOOMER.instantiate() as Boomer
	b.position = Vector2(x, y) / 100.0
	b.speed = spd
	b.money_prob = moneypr
	b.angle = start_angle
	b.angle_near = turn
	b.life = hit_points
	Game.add_entity(b)
	return b


func _ready() -> void:
	add_to_group(&"boomers")
	target = Game.pick_target()
	Gfx.apply($Sprite, 201)
	Gfx.fit_shape($Shape, 201, 4.0)
	rotation = Div.rot(angle)


func _physics_process(_delta: float) -> void:
	position += Div.vec(angle, speed / 100.0)
	if life <= 0:
		if Div.rand(0, money_prob) == 0:
			Pickup.spawn(Pickup.Kind.MONEY, position)
		Explosion.spawn(position, 150, 2)
		queue_free()
		return
	var touched := Hit.ships_touching($Shape)
	if not touched.is_empty():
		Game.players[touched[0].index].killed = true
		target = Game.pick_target()
	var ship := Game.ship_of(target)
	if ship == null:
		target = Game.pick_target()
		ship = Game.ship_of(target)
	if ship != null:
		angle = Div.near_angle(angle, Div.angle_to(position, ship.position), angle_near)
	rotation = Div.rot(angle)
	if pict == 1:
		life -= 1
	pict = (pict % 11) + 1
	Gfx.apply($Sprite, pict / 6 + 201)
	apply_blast_damage(14.0)
