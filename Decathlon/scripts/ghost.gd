class_name Ghost
extends Sprite2D
## Fading afterimage of an arm segment. DIV: process Specani (flags=4 half transparent, z=50,
## lives 28 frames at the default 18 fps).

const LIFETIME := 28.0 / Game.TICKS_PER_SECOND


func setup(source: Sprite2D) -> void:
	texture = source.texture
	centered = false
	offset = source.offset
	position = source.position
	rotation = source.rotation
	modulate.a = 0.5
	z_index = -50  # DIV z=50: behind the arm itself


func _ready() -> void:
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)
