class_name Shot
extends Node2D
## Cannon shell (DIV processes Schuss + Schussbild). Spawns 40 px ahead of the turret pivot,
## flies straight at 15 px/frame and disappears when completely off screen.
## New (owner's decision 2026-10-26): unless the game runs as a sandbox, a shell that reaches
## another living tank's hull hits it and disappears. In the sandbox it hurts nothing (original).

const SPEED := 15.0 * Game.FPS        # DIV: advance(15) per frame
const SPAWN_DISTANCE := 40.0          # DIV: advance(40) on creation
const HALF_SIZE := Vector2(2.5, 2.5)  # graphic 3 is 5x5

var angle: float = 0.0  # direction (Godot rotation); the picture itself is never rotated
## The tank that fired it (its own shells never hit it)
var shooter: Tank
var _direction: Vector2


func _ready() -> void:
	_direction = Vector2.from_angle(angle)
	position += _direction * SPAWN_DISTANCE


func _process(delta: float) -> void:
	position += _direction * SPEED * delta
	# DIV: out_region(id, 0)
	if position.x + HALF_SIZE.x < 0.0 or position.x - HALF_SIZE.x > Game.SCREEN_SIZE.x \
			or position.y + HALF_SIZE.y < 0.0 or position.y - HALF_SIZE.y > Game.SCREEN_SIZE.y:
		queue_free()
		return
	if Game.is_sandbox():
		return
	for node in get_tree().get_nodes_in_group(&"tanks"):
		var tank := node as Tank
		if tank != shooter and tank.alive and tank.hull_contains(position, HALF_SIZE.x):
			tank.take_hit(position)
			queue_free()
			return
