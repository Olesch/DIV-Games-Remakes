class_name Shot
extends Node2D
## DIV: PROCESS Shot(x,y,dir,strength,dist,graph,nummer). Sword hit (graph 41, invisible, 2 steps),
## arrows (42..45), stones (47), flame ball (46), ice balls (48, dir 0..7). nummer 10 = fired by an enemy.
## Moves 6 px per frame (diagonals 4+4) and checks hits/walls after every step.

var dir: int = 0
var strength: int = 0
var dist: int = 0        # remaining steps
var graph: int = 0
var nummer: int = 0
var ix: int = 0
var iy: int = 0
var moved: int = 0
var resist: int = 0      # DIV LOCAL resist, only used for the blood size
var _finished: bool = false

@onready var _sprite: Sprite2D = $Sprite


func setup(px: int, py: int, direction: int, damage: int, steps: int, graph_code: int, owner_nummer: int) -> void:
	ix = px
	iy = py
	dir = direction
	strength = damage
	dist = steps
	graph = graph_code
	nummer = owner_nummer
	if graph == 41:
		graph = 0
	if graph == 42:
		graph += dir


func _ready() -> void:
	Gfx.apply(_sprite, graph)
	# a DIV process runs up to its first FRAME as soon as it is created
	_step()
	position = Vector2(ix, iy)


func _physics_process(_delta: float) -> void:
	if _finished:
		return
	if dist <= 0:
		queue_free()
		return
	_step()
	position = Vector2(ix, iy)


func _step() -> void:
	if dir == 0:
		iy -= 6
	if dir == 1:
		ix += 6
	if dir == 2:
		iy += 6
	if dir == 3:
		ix -= 6
	if dir == 4:
		ix -= 4
		iy -= 4
	if dir == 5:
		ix += 4
		iy -= 4
	if dir == 6:
		ix -= 4
		iy += 4
	if dir == 7:
		ix += 4
		iy += 4

	if ix > 799 or ix < 0 or iy > 599 or iy < 0:
		_end()
		return

	moved += 6
	var world: World = Game.world
	var st := Game.stat

	if nummer != 10:
		for e: Enemy in get_tree().get_nodes_in_group(&"enemies"):
			if Gfx.idist(ix, iy, e.ix, e.iy) < 7:
				if graph == 0:
					resist = e.resist % 10
					strength = (strength * (100 - resist * 10)) / 100
					st.strength_exp += 10 - resist
					if st.strength_exp > 100 + Game.difficulty * 5:
						st.strength_exp = 0
						st.strength += 1
				if graph == 46 or graph == 48:
					resist = (e.resist - ((e.resist - (e.resist % 10)) % 100) - (e.resist % 10)) / 100
					strength = (strength * (100 - resist * 10)) / 100
					st.magic_exp += 10 - resist
					if st.magic_exp > 60 + Game.difficulty * 5:
						st.magic_exp = 0
						st.magic += 1
				if graph == 42 or graph == 43 or graph == 44 or graph == 45:
					resist = ((e.resist - (e.resist % 10)) % 100) / 10
					strength = (strength * (100 - resist * 10)) / 100
					st.bow_exp += 10 - resist
					if st.bow_exp > 80 + Game.difficulty * 5:
						st.bow_exp = 0
						st.bow += 1
				e.hit_damage += strength
				_blood_for_dir(world, 250 - resist * 10)
				_end()
				return
	else:
		var h := Game.hero
		if h != null and is_instance_valid(h) and Gfx.idist(ix, iy, h.ix, h.iy) < 7:
			_blood_for_dir(world, 150)
			h.hit_damage += strength
			_end()
			return

	var t := Game.terrain_at(ix, iy)
	if t == Game.T_WALL or t == Game.T_SILVER_DOOR or t == Game.T_GOLD_DOOR:
		_end()
		return
	if t == Game.T_THIN_LOOPHOLE and moved > 80:
		_end()
		return
	dist -= 1


func _blood_for_dir(world: World, power: int) -> void:
	if dir == 0:
		world.spawn_blood(ix, iy - 6, randi_range(70000, 110000), power)
	if dir == 1:
		world.spawn_blood(ix + 6, iy, randi_range(-20000, 20000), power)
	if dir == 2:
		world.spawn_blood(ix, iy + 6, randi_range(-110000, -70000), power)
	if dir == 3:
		world.spawn_blood(ix - 6, iy, randi_range(-200000, -160000), power)


func _end() -> void:
	_finished = true
	queue_free()
