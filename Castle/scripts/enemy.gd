class_name Enemy
extends Node2D
## DIV: PROCESS Enemy(Initgraph,Life,Strength,x,y,DefRad,expgive,weapon,resist,spec).
## spec: 0 nothing, 1 regeneration, 2 two weapon style (bow far away, sword close, twice the power),
##       3 mana absorbing, 4 wall walking, 5 = 3+4.
## weapon: 0 sword, 1 bow, 2 stone thrower (bow with graph 47).
## resist: three digits hundreds = magic, tens = bow, ones = sword resistance (x*10 %).
## Walks 1-3 px per frame towards the hero (see _tick), one tick = one DIV frame (24/s).

var initgraph: int = 200
var life: int = 10
var strength: int = 3
var ix: int = 0
var iy: int = 0
var defrad: int = 80         # aggro radius ("DefRad"); 5000 = always chasing
var expgive: int = 10
var weapon: int = 0
var resist: int = 0
var spec: int = 0

var hit_damage: int = 0      # DIV: Hit_Damage, written by shots
var dir: int = 0
var movement: int = 0
var attackwait: int = 0
var weapgraph: int = 0
var inix: int = 0            # grid cell of the map object this enemy came from
var iniy: int = 0
var inilife: int = 0
var graph: int = 0

@onready var _sprite: Sprite2D = $Sprite


func setup(p_initgraph: int, p_life: int, p_strength: int, px: int, py: int, p_defrad: int,
		p_expgive: int, p_weapon: int, p_resist: int, p_spec: int) -> void:
	initgraph = p_initgraph
	life = p_life
	strength = p_strength
	ix = px
	iy = py
	defrad = p_defrad
	expgive = p_expgive
	weapon = p_weapon
	resist = p_resist
	spec = p_spec


func _ready() -> void:
	if weapon == 1:
		weapgraph = 42
	if weapon == 2:
		weapon = 1
		weapgraph = 47
	inix = (ix - 10) / 20
	iniy = (iy - 10) / 20
	inilife = life
	strength = (strength * (100 + Game.difficulty * 10)) / 100
	life = (life * (100 + Game.difficulty * 8)) / 100
	if spec == 4 or spec == 5:
		_sprite.modulate.a = 0.5   # flags=4
	graph = initgraph
	Gfx.apply(_sprite, graph)
	position = Vector2(ix, iy)
	add_to_group(&"enemies")


func _physics_process(_delta: float) -> void:
	_tick()
	position = Vector2(ix, iy)


func _tick() -> void:
	var hero := Game.hero
	if hero == null or not is_instance_valid(hero):
		return
	var hx := hero.ix
	var hy := hero.iy
	var d := Gfx.idist(ix, iy, hx, hy)   # DIV: get_dist(stat[0].hero_id)

	if spec == 2:
		if d < 45 and weapon == 1:
			weapon = 0
			strength = strength * 2
		if d > 44 and weapon == 0:
			weapon = 1
			strength = strength / 2

	var xinc := 0
	var yinc := 0
	movement += 1
	var angle := int(rad_to_deg(atan2(-(hy - iy), hx - ix)) * 1000.0)   # DIV: get_angle(hero)
	if angle > 45000 and angle <= 135000:
		dir = 0
	if angle > -45000 and angle <= 45000:
		dir = 1
	if angle > -135000 and angle <= -45000:
		dir = 2
	if (angle <= 180000 and angle > 135000) or (angle >= -180000 and angle <= -135000):
		dir = 3

	if hy < iy:
		yinc += hy - iy
		if yinc <= -3:
			yinc = -3
		if weapon == 1:
			if d < 20:
				dir += 10
				yinc = 3
				if hx == ix:
					xinc += randi_range(-1, 1)
			else:
				yinc = 0
	if hx > ix:
		xinc += hx - ix
		if xinc >= 3:
			xinc = 3
		if weapon == 1:
			if d < 20:
				dir += 10
				xinc = -3
				if hy == iy:
					yinc += randi_range(-1, 1)
			else:
				xinc = 0
	if hy > iy:
		yinc += hy - iy
		if yinc >= 3:
			yinc = 3
		if weapon == 1:
			if d < 20:
				dir += 10
				yinc = -3
				if hx == ix:
					xinc += randi_range(-1, 1)
			else:
				yinc = 0
	if hx < ix:
		xinc += hx - ix
		if xinc <= -3:
			xinc = -3
		if weapon == 1:
			if d < 20:
				dir += 10
				xinc = 3
				if hy == iy:
					yinc += randi_range(-1, 1)
			else:
				xinc = 0

	if dir > 9:
		dir = ((dir % 10) + 2) % 4

	if weapon == 1 and d > 25 and xinc == 0 and yinc == 0:
		# "Event" for aiming archers: sidestep until lined up with the hero
		if hx - ix > 0 and hx - ix < 11:
			xinc = 3 if hx - ix > 2 else 1
		if hy - iy > 0 and hy - iy < 11:
			yinc = 3 if hy - iy > 2 else 1
		if hx - ix < 0 and hx - ix > -11:
			xinc = -3 if hx - ix < -2 else -1
		if hy - iy < 0 and hy - iy > -11:
			yinc = -3 if hy - iy < -2 else -1

	# the sprite faces right and is rotated to the facing direction
	if dir == 0:
		rotation = -deg_to_rad(90.0)
	if dir == 1:
		rotation = 0.0
	if dir == 2:
		rotation = deg_to_rad(90.0)
	if dir == 3:
		rotation = deg_to_rad(180.0)

	if xinc > 2 and yinc > 2:
		xinc = 2
		yinc = 2
	if xinc < -2 and yinc > 2:
		xinc = -2
		yinc = 2
	if xinc > 2 and yinc < -2:
		xinc = 2
		yinc = -2
	if xinc < -2 and yinc < -2:
		xinc = -2
		yinc = -2
	if d < 15 and weapon == 0:
		xinc = xinc / 2
		yinc = xinc / 2   # sic: DIV uses Xinc here (original quirk kept)

	if d > defrad + randi_range(-10, 10):
		xinc = 0
		yinc = 0
		movement -= 1

	if movement > 20:
		movement = 1
	if movement < 0:
		movement += 1
	if movement == 0:
		movement = randi_range(1, 20)

	if movement > -5 and movement < 1:
		graph = initgraph + 3
	if movement > 0 and movement < 6:
		graph = initgraph
	if movement > 5 and movement < 11:
		graph = 1 + initgraph
	if movement > 10 and movement < 16:
		graph = initgraph
	if movement > 15 and movement < 21:
		graph = 2 + initgraph
	Gfx.apply(_sprite, graph)

	if randi_range(0, 8) == 0 and attackwait > 11:
		# DIV: XOR of the four comparisons = true when an odd number of them holds (kept)
		var off_axis := (int(hy < iy - 11) ^ int(hy > iy + 11) ^ int(hx < ix - 11) ^ int(hx > ix + 11)) == 1
		if weapon == 1 and d > 19 and off_axis:
			Game.world.spawn_shot(ix, iy, dir, strength, 800, weapgraph, 10)
			movement = -4
			attackwait = 0
		if weapon == 0 and d < 18:
			if dir == 0:
				Game.world.spawn_blood(hx, hy, randi_range(70000, 110000), 150)
			if dir == 1:
				Game.world.spawn_blood(hx, hy, randi_range(-20000, 20000), 150)
			if dir == 2:
				Game.world.spawn_blood(hx, hy, randi_range(-110000, -70000), 150)
			if dir == 3:
				Game.world.spawn_blood(hx, hy, randi_range(-200000, -160000), 150)
			hero.hit_damage += strength
			movement = -4
			attackwait = 0
			if (spec == 3 or spec == 5) and Game.stat.mana > 2:
				Game.stat.mana -= 3

	attackwait += 1

	var nomove := Game.terrain_at(ix, iy)
	if nomove == Game.T_SLIME:
		xinc = signi(xinc)
		yinc = signi(yinc)

	var old_x := ix
	var old_y := iy
	var wall_walker := spec == 4 or spec == 5

	ix += xinc
	if Game.is_walkable_blocker(Game.terrain_at(ix, iy)) and not wall_walker:
		ix = old_x
	if _too_close(hero):
		ix = old_x

	iy += yinc
	if Game.is_walkable_blocker(Game.terrain_at(ix, iy)) and not wall_walker:
		iy = old_y
	if _too_close(hero):
		iy = old_y

	if hit_damage != 0:
		life -= hit_damage
		hit_damage = 0
		defrad = 5000   # once hurt it always chases

	if life < 1:
		_die()
		return
	if spec == 1 and life < inilife:
		if randi_range(0, 5) == 0:
			life += 1


## DIV: any Hero or other Enemy closer than 10 px (but not at the very same spot) blocks the step.
func _too_close(hero: Hero) -> bool:
	var dh := Gfx.idist(ix, iy, hero.ix, hero.iy)
	if dh < 10 and dh != 0:
		return true
	for e: Enemy in get_tree().get_nodes_in_group(&"enemies"):
		var de := Gfx.idist(ix, iy, e.ix, e.iy)
		if de < 10 and de != 0:
			return true
	return false


func _die() -> void:
	remove_from_group(&"enemies")
	var world: World = Game.world
	world.spawn_blood(ix, iy, randi_range(-180000, 180000), 250)
	world.spawn_blood(ix, iy, randi_range(-180000, 180000), 250)
	world.spawn_blood(ix, iy, randi_range(-180000, 180000), 250)
	Game.stat.exp += expgive
	Game.set_cell(1, inix, iniy, 0)
	if weapon == 1 or spec == 2:
		world.spawn_pickup(66, randi_range(1, 3), ix, iy)
	queue_free()
