class_name Potion
extends Area2D
## DIV: PROCESS Potion() - falls from y=600 to the ground; a Duk that walks into it becomes super.

const FALL_SPEED := 3.0 * Defs.FPS  # DIV: y += 3 per frame
const REST_Y := 711.0               # DIV: FROM y=600 TO 710 STEP 3 ends at 711

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	add_to_group(&"potions")
	position = Vector2(randi_range(200, 824), 600)
	Gfx.apply(_sprite, 38)


func _physics_process(delta: float) -> void:
	position.y = minf(position.y + FALL_SPEED * delta, REST_Y)


func collect() -> void:
	queue_free()
