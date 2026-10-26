class_name Blast
extends Node2D
## New (the original has no hits): a burst of square "pixels" in the fire colours of the
## PANZERS.FPG palette (16..31, dark red -> yellow), cooling down while they fly apart.
## Small for a shell hit, big when a tank is destroyed. Frees itself when done.

## Palette colours 31..19 (hottest first).
const FIRE: Array[Color] = [
	Color8(255, 243, 227), Color8(255, 223, 170), Color8(255, 203, 113), Color8(255, 182, 56),
	Color8(255, 162, 0), Color8(255, 130, 0), Color8(255, 97, 0), Color8(255, 65, 0),
	Color8(255, 32, 0), Color8(255, 0, 0), Color8(219, 0, 0), Color8(182, 0, 0), Color8(146, 0, 0),
]

var _pos: PackedVector2Array = []
var _vel: PackedVector2Array = []
var _life: PackedFloat32Array = []
var _age: PackedFloat32Array = []
var _size: PackedFloat32Array = []


## Add a blast of `count` pixels at `at` to `parent`.
static func spawn(parent: Node, at: Vector2, count: int, speed: float, duration: float, pixel: float) -> Blast:
	var blast := Blast.new()
	blast.position = at
	blast.z_index = 3
	for i in count:
		blast._pos.append(Vector2.ZERO)
		blast._vel.append(Vector2.from_angle(randf() * TAU) * speed * randf_range(0.2, 1.0))
		blast._life.append(duration * randf_range(0.5, 1.0))
		blast._age.append(0.0)
		blast._size.append(pixel * randf_range(0.6, 1.0))
	parent.add_child(blast)
	return blast


func _process(delta: float) -> void:
	var alive := false
	for i in _pos.size():
		_age[i] += delta
		_pos[i] += _vel[i] * delta
		_vel[i] *= 1.0 - minf(3.0 * delta, 1.0)
		alive = alive or _age[i] < _life[i]
	if not alive:
		queue_free()
	queue_redraw()


func _draw() -> void:
	for i in _pos.size():
		if _age[i] >= _life[i]:
			continue
		var t := _age[i] / _life[i]
		var colour := FIRE[mini(int(t * FIRE.size()), FIRE.size() - 1)]
		var s := _size[i]
		draw_rect(Rect2((_pos[i] - Vector2(s, s) * 0.5).floor(), Vector2(s, s).ceil()), colour)
