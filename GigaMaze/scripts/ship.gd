class_name Ship
extends Area2D
## One player's ship (DIV process Ship).  Pressing a direction key sets the heading; the ship then keeps
## flying that way (the original never stops on key release) until a wall or another ship blocks it.
## Moves 4 px per tick in 1 px sub-steps, like the original's inner loop (160 px/s at 40 fps).

signal shot_requested(ship: Ship, dir: int, weapon: int)

enum Dir { NONE = -1, UP, RIGHT, LEFT, DOWN }

const SUBSTEPS := 4
const NOSE := 7            # distance of the wall probe in front of the centre
const SIDE := 6            # lateral offset of the two outer probes
const BLOCK_DIST := 14     # ships closer than this on both axes block each other
const FLOOR_INDEX := 1     # level colour index of free floor
const DIR_VEC := {
	Dir.UP: Vector2i(0, -1), Dir.RIGHT: Vector2i(1, 0), Dir.LEFT: Vector2i(-1, 0), Dir.DOWN: Vector2i(0, 1),
}
const DIR_GRAPH := {Dir.UP: 2, Dir.RIGHT: 1, Dir.LEFT: 3, Dir.DOWN: 4}   # + player*4
const DIR_NAME := {Dir.UP: "up", Dir.RIGHT: "right", Dir.LEFT: "left", Dir.DOWN: "down"}

var player := 0
var cell := Vector2i.ZERO
var dir: int = Dir.NONE
var stats: PlayerStats

@onready var _sprite: Sprite2D = $Sprite2D


func setup(player_index: int) -> void:
	player = player_index
	stats = Game.stats[player]
	stats.ship = self
	cell = Game.level.get_point(player + Game.POINT_PLAYER_FIRST)
	position = Vector2(cell)


func _ready() -> void:
	_sprite.texture = Game.tex(player * 4 + randi_range(1, 4))  # DIV: graph=player*4+rand(1,4)


func teleport(to: Vector2i) -> void:
	cell = to
	position = Vector2(cell)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_pressed():
		return
	for d: int in DIR_VEC:
		if event.is_action_pressed(StringName("p%d_%s" % [player, DIR_NAME[d]])):
			dir = d
			_sprite.texture = Game.tex(player * 4 + DIR_GRAPH[d])
			return
	if event.is_action_pressed(StringName("p%d_fire" % player)):
		_fire()


func _fire() -> void:
	shot_requested.emit(self, dir, stats.weapon)
	stats.ammo -= 1
	if stats.ammo < 1:
		stats.weapon = 0
		stats.ammo = Game.START_AMMO


func _physics_process(_delta: float) -> void:
	if dir == Dir.NONE:
		return
	for i in SUBSTEPS:
		_step()
	position = Vector2(cell)


func _step() -> void:
	var v: Vector2i = DIR_VEC[dir]
	if not _blocked_by_ship(v) and _front_is_free(v):
		cell += v
	# Leave the maze through a gap and re-enter on the opposite side (DIV: x=639 / y=439 / x=1 / y=1)
	var front := cell + v * NOSE
	if front.x < 1:
		cell.x = Game.PLAY_W - 1
	if front.y < 1:
		cell.y = Game.PLAY_H - 1
	if front.x > Game.PLAY_W - 1:
		cell.x = 1
	if front.y > Game.PLAY_H - 1:
		cell.y = 1


func _blocked_by_ship(v: Vector2i) -> bool:
	for other in Game.stats:
		if other.ship == null or other.ship == self:
			continue
		var d: Vector2i = cell + v - other.ship.cell
		if absi(d.x) < BLOCK_DIST and absi(d.y) < BLOCK_DIST:
			return true
	return false


func _front_is_free(v: Vector2i) -> bool:
	var front := cell + v * NOSE
	var side := Vector2i(absi(v.y), absi(v.x)) * SIDE
	for p in [front, front + side, front - side]:
		if Game.level.get_index(p.x, p.y) != FLOOR_INDEX:
			return false
	return true


func get_box() -> Rect2:
	return Rect2(Vector2(cell) - Vector2(7, 7), Vector2(14, 14))
