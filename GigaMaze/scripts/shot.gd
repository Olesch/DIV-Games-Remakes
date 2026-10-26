class_name Shot
extends Node2D
## A projectile (DIV process Patron).  Flies in 1 px sub-steps, testing ships and the level each step.

var owner_ship: Ship
var cell := Vector2i.ZERO
var _dir := Vector2i.ZERO
var _speed := 0
var _damage := 0
var _score := 0
var _dead := false
var _half := Vector2(1, 1)   # half size of the graphic (all its control points are the centre)

@onready var _sprite: Sprite2D = $Sprite2D


func setup(ship: Ship, dir: int, weapon: int) -> void:
	owner_ship = ship
	cell = ship.cell
	_dir = Ship.DIR_VEC[dir]
	var def: Dictionary = Game.SHOTS[weapon]
	_speed = def["speed"]
	_damage = def["damage"]
	_score = def["score"]
	var vertical := dir == Ship.Dir.UP or dir == Ship.Dir.DOWN
	_sprite.texture = Game.tex(def["graph_v"] if vertical else def["graph_h"])
	_half = _sprite.texture.get_size() / 2.0
	position = Vector2(cell)


func _physics_process(_delta: float) -> void:
	step()


func step() -> void:
	if _dead:
		return
	for i in _speed:
		var box := Rect2(Vector2(cell) - _half, _half * 2.0)
		for stats in Game.stats:
			var target := stats.ship
			if target != owner_ship and target.get_box().intersects(box):
				stats.life -= _damage
				Game.stats[owner_ship.player].score += _score
				_die()
				return
		if Game.level.get_index(cell.x, cell.y) != Ship.FLOOR_INDEX:
			_die()
			return
		cell += _dir
	position = Vector2(cell)


func _die() -> void:
	_dead = true
	queue_free()
