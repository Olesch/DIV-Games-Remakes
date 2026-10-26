class_name Shot
extends Area2D
## Bullet (DIV: Schuss): flies straight at 16 px/frame, dies on its first enemy hit or off screen.

const SPEED := 16.0 * 24.0  # DIV: advance(1600) at resolution 100 = 16 px/frame @ 24 fps

var direction := Vector2.RIGHT


func _ready() -> void:
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	for area in get_overlapping_areas():
		if area is Enemy:
			(area as Enemy).hit()
			queue_free()
			return
	if not Rect2(Vector2(-10, -10), Game.VIEW_SIZE + Vector2(20, 20)).has_point(position):
		queue_free()
