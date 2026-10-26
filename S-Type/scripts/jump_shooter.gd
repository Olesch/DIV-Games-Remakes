class_name JumpShooter
extends Enemy
## DIV: Jump_Shooter(x,y,movspeed,Standtime,decsp,moneypr,art,weaponspeed,graph,life) - leaps towards
## a player, decelerates, stands still for `stand_time` frames, then drifts backwards faster and
## faster. Shoots at its target every `weapon_wait` frames. art 1 spawns two more next to it.

var mov_speed := 700
var stand_time := 70
var decel := 20
var money_prob := 5
var art := 0
var weapon_wait := 30
var graph := 207
var angle := 0
var target := 0
var shot_wait := 0


static func spawn(x: int, y: int, mov: int, stand: int, dec: int, moneypr: int, movement: int,
		weapon_speed: int, graph_code: int, hit_points: int) -> void:
	var pos := Vector2(x, y) / 100.0
	var tgt := Game.pick_target()
	var ship := Game.ship_of(tgt)
	var aim := Div.angle_to(pos, ship.position) if ship else 180000
	_make(pos, mov, stand, dec, moneypr, weapon_speed, graph_code, hit_points, tgt, aim)
	if movement == 1:
		# DIV: CLONE - two more shooters 110 px to either side (perpendicular to the aim)
		_make(pos + Div.vec(aim - 90000, 110.0), mov, stand, dec, moneypr, weapon_speed, graph_code, hit_points, tgt, aim)
		_make(pos + Div.vec(aim + 90000, 110.0), mov, stand, dec, moneypr, weapon_speed, graph_code, hit_points, tgt, aim)


static func _make(pos: Vector2, mov: int, stand: int, dec: int, moneypr: int, weapon_speed: int,
		graph_code: int, hit_points: int, tgt: int, aim: int) -> void:
	var j := Scenes.JUMP_SHOOTER.instantiate() as JumpShooter
	j.position = pos
	j.mov_speed = mov
	j.stand_time = stand
	j.decel = dec
	j.money_prob = moneypr
	j.weapon_wait = weapon_speed
	j.graph = graph_code
	j.life = hit_points
	j.target = tgt
	j.angle = aim
	Game.add_entity(j)


func _ready() -> void:
	add_to_group(&"jump_shooters")
	Gfx.apply($Sprite, graph)
	Gfx.fit_shape($Shape, graph, 3.0)
	rotation = Div.rot(angle)


func _physics_process(_delta: float) -> void:
	var ship := Game.ship_of(target)
	if ship == null:
		target = Game.pick_target()
		ship = Game.ship_of(target)
	if ship != null:
		angle = Div.near_angle(angle, Div.angle_to(position, ship.position), 5000 + Game.psh * 1000)
	rotation = Div.rot(angle)

	if mov_speed > 0:
		position += Div.vec(angle, mov_speed / 100.0)
		mov_speed -= decel
	elif stand_time > 0:
		stand_time -= 1
	else:
		position += Div.vec(angle, mov_speed / 100.0)
		mov_speed -= decel

	if life <= 0:
		if money_prob != 100:
			if Div.rand(0, money_prob) == 0:
				Pickup.spawn(Pickup.Kind.MONEY, position)
		else:
			Pickup.spawn(Pickup.Kind.LIFE, position)
		Explosion.spawn(position, 70, 0)
		queue_free()
		return
	if position.x < -200.0 or position.y > 800.0 or position.y < -200.0 or position.x > 1000.0:
		queue_free()
		return
	Hit.kill_touching_ships($Shape)
	shot_wait += 1
	if shot_wait > weapon_wait:
		EnemyShot.fire(position, angle, 103)
		shot_wait = 0
		target = Game.pick_target()
	apply_blast_damage(14.0)
