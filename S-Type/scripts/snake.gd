class_name Snake
extends Enemy
## DIV: snake_colony(x,y,xspeed,yspeed,count,moneypr,art,weapon,graph,life) - one segment of a
## colony; `spawn` creates count+1 segments 80 px apart. `art` selects the movement pattern:
##   0 straight, 1 random up/down, 2 "jump" up down down up, 3 long jump up down,
##   4 long jump + stops on screen, 5 long jump + nearly stops, 6 jump + stops, 7 jump + nearly stops,
##   8 jump with constant movement, 9/10 turning bar clockwise/anticlockwise (no weapons),
##   11 long jump with constant movement.
## `weapon` selects the SnakeCannon set (0 none ... 7 five targeting cannons).
## graph 203 is the level 1 end enemy (big explosion + loot).

var xspeed := 500         # 1/100 px per frame
var yspeed := 0
var count := 0
var money_prob := 0       # DIV: moneypr (100 = extra life drop, 101 = shield drop)
var art := 0
var weapon := 0
var graph := 200
var amplitude := 0
var angle := 0            # only the turning bars use it


static func spawn(x: int, y: int, xs: int, ys: int, seg_count: int, moneypr: int, movement: int,
		weapon_kind: int, graph_code: int, hit_points: int) -> Snake:
	var head: Snake = null
	for i in seg_count + 1:
		var s := Scenes.SNAKE.instantiate() as Snake
		s.position = Vector2(x / 100.0 + i * 80.0, y / 100.0)  # DIV: x+8000 per segment
		s.xspeed = xs
		s.yspeed = ys
		s.count = seg_count - i
		s.money_prob = moneypr
		s.art = movement
		s.weapon = weapon_kind
		s.graph = graph_code
		s.life = hit_points
		Game.add_entity(s)
		if i == 0:
			head = s
	return head


func _ready() -> void:
	add_to_group(&"snakes")
	var g := graph
	if art == 9:
		g = 208
	elif art == 10:
		g = 209
	Gfx.apply($Sprite, g)
	Gfx.fit_shape($Shape, g, 3.0)
	amplitude = (count * 10) % 80
	if art == 9:
		angle = -15000 * count
	if art == 10:
		angle = 15000 * count
	rotation = Div.rot(angle)
	if weapon != 0 and art != 9 and art != 10:
		match weapon:
			1: _cannons([1])
			2: _cannons([2, 3])
			3: _cannons([3, 2])
			4: _cannons([4])
			5: _cannons([2, 3, 4, 5, 6])
			6: _cannons([5, 6])
			7: _cannons([4, 7, 8, 9, 10])


func _cannons(kinds: Array) -> void:
	for k in kinds:
		var c := Scenes.SNAKE_CANNON.instantiate() as SnakeCannon
		c.weapon = k
		c.blue = graph == 203
		add_child(c)


func _physics_process(_delta: float) -> void:
	position.x -= xspeed / 100.0
	if art == 1:
		yspeed += Div.rand(-10, 10)
	if art == 2 or art == 6 or art == 7 or art == 8:
		amplitude += 1
		if amplitude > 10 and amplitude < 20:
			position.y += yspeed / 100.0
		if amplitude > 30 and amplitude < 40:
			position.y += yspeed / 100.0
		if amplitude > 50 and amplitude < 60:
			position.y -= yspeed / 100.0
		if amplitude > 70 and amplitude < 80:
			position.y -= yspeed / 100.0
		if amplitude > 80:
			amplitude = 0
	if art == 3 or art == 4 or art == 5 or art == 11:
		amplitude += 1
		if amplitude > 10 and amplitude < 40:
			position.y += yspeed / 100.0
		if amplitude > 50 and amplitude < 80:
			position.y -= yspeed / 100.0
		if amplitude > 80:
			amplitude = 0
	if art == 4 or art == 6:
		if position.x < 700.0:
			xspeed = 0
	if art == 5 or art == 7:
		if position.x < 700.0:
			xspeed = 100
	if art != 2 and art != 3 and art != 4 and art != 5 and art != 6 and art != 7:
		position.y += yspeed / 100.0
	if art == 9:
		angle += 3000
		rotation = Div.rot(angle)
	if art == 10:
		angle -= 3000
		rotation = Div.rot(angle)

	if life <= 0:
		_die()
		return
	if position.x < -200.0 or position.y > 800.0 or position.y < -200.0:
		queue_free()
		return
	Hit.kill_touching_ships($Shape)
	apply_blast_damage(14.0)


func _die() -> void:
	if money_prob != 100:
		if money_prob != 101:
			if Div.rand(0, money_prob) == 0:
				Pickup.spawn(Pickup.Kind.MONEY, position)
		else:
			Pickup.spawn(Pickup.Kind.SHIELD, position)
	else:
		Pickup.spawn(Pickup.Kind.LIFE, position)
	Explosion.spawn(position, 70, 0)
	if graph == 203:
		Explosion.spawn(position, 150, 4)
		Explosion.spawn(position, 100, 6)
		Explosion.spawn(position, 70, 8)
		Explosion.spawn(position, 50, 30)
		for i in 6:
			Pickup.spawn(Pickup.Kind.MONEY, position + Vector2(Div.rand(-10000, 10000), Div.rand(-5000, 5000)) / 100.0)
		if Game.psh >= 2:
			Pickup.spawn(Pickup.Kind.LIFE, position + Vector2(Div.rand(-10000, 10000), Div.rand(-5000, 5000)) / 100.0)
	queue_free()
