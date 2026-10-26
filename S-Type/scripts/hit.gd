class_name Hit
extends RefCounted
## Replacement for DIV collision(TYPE ...): synchronous shape queries against the physics layers
## (1 player ships, 2 enemies, 3 boss shield). Query shape = the caller's own CollisionShape2D.

const LAYER_PLAYER := 1
const LAYER_ENEMY := 2
const LAYER_SHIELD := 4

static var _params := PhysicsShapeQueryParameters2D.new()


static func query(shape_node: CollisionShape2D, mask: int) -> Array[Area2D]:
	var out: Array[Area2D] = []
	if shape_node.shape == null or shape_node.disabled or not shape_node.is_inside_tree():
		return out
	var space := shape_node.get_world_2d().direct_space_state
	_params.shape = shape_node.shape
	_params.transform = shape_node.global_transform
	_params.collision_mask = mask
	_params.collide_with_areas = true
	_params.collide_with_bodies = false
	for r in space.intersect_shape(_params, 16):
		var c := r["collider"] as Area2D
		if c:
			out.append(c)
	return out


static func ships_touching(shape_node: CollisionShape2D) -> Array[Ship]:
	var out: Array[Ship] = []
	for a in query(shape_node, LAYER_PLAYER):
		if a is Ship:
			out.append(a)
	return out


## Kill every ship that overlaps the shape (DIV: Player[hit.nummer].killed=1).
static func kill_touching_ships(shape_node: CollisionShape2D) -> void:
	for s in ships_touching(shape_node):
		Game.players[s.index].killed = true


## First enemy hit by the shape (DIV: FindHit). The boss shield is the outermost part, so it wins.
static func first_enemy(shape_node: CollisionShape2D) -> Enemy:
	var best: Enemy = null
	for a in query(shape_node, LAYER_ENEMY | LAYER_SHIELD):
		var e := a as Enemy
		if e == null:
			continue
		if e.collision_layer & LAYER_SHIELD:
			return e
		if best == null:
			best = e
	return best
