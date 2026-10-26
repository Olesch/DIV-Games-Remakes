class_name HitEffect
extends Sprite2D
## Short translucent spark that grows or shrinks for a few ticks
## (DIV: PROCESS AnimHau = hit spark, size +4 per tick; EnergyLoad = charge ring, size -7 per tick).

const SCENE := preload("res://scenes/hit_effect.tscn")

var _size: int = 100        # percent
var _size_step: int = 4
var _ticks: int = 4
var _age: int = 0


## `x`, `y` are DIV units (hundredths of a pixel); `graph` is a graphic of Heatfigh.fpg.
static func spawn(parent: Node, x: int, y: int, size: int, graph: int,
		size_step: int = 4, ticks: int = 4) -> void:
	var effect := SCENE.instantiate() as HitEffect
	effect._size = size
	effect._size_step = size_step
	effect._ticks = ticks
	effect.position = Vector2(x, y) / 100.0
	Gfx.apply(effect, Gfx.SET_EFFECTS, graph)
	effect.scale = Vector2.ONE * size / 100.0
	parent.add_child(effect)
	effect.reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	_age += 1
	if _age >= _ticks:
		queue_free()
		return
	_size += _size_step
	scale = Vector2.ONE * _size / 100.0
