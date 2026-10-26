class_name FadingShot
extends Sprite2D
## DIV: PROCESS shrink(x, y, graph, size, 4) - a shot swallowed by its own ship shrinks away
## (size 100 -> 0 in steps of 4 per frame, no collisions).

const SCENE := preload("res://scenes/fading_shot.tscn")


static func spawn(parent: Node, pos: Vector2, owner: int) -> void:
	var fading := SCENE.instantiate() as FadingShot
	fading.position = pos
	fading.texture = Gfx.shot_tex(owner)
	parent.add_child(fading)


func _ready() -> void:
	var frames := 100 / Defs.FADE_STEP - 1
	scale = Vector2.ONE * (100 - Defs.FADE_STEP) / 100.0
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * Defs.FADE_STEP / 100.0, (frames - 1.0) / Defs.FPS)
	tween.tween_callback(queue_free)
