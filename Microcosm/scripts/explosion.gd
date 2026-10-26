class_name Explosion
extends AnimatedSprite2D
## DIV: PROCESS Explosion(x, y, size) - five pictures, one frame each, then it vanishes.

const SCENE_PATH := "res://scenes/explosion.tscn"


## Create an explosion in `parent` at `pos`; `size_percent` is DIV's size (100 = normal).
static func spawn(parent: Node, pos: Vector2, size_percent: int) -> void:
	var explosion := (load(SCENE_PATH) as PackedScene).instantiate() as Explosion
	explosion.position = pos
	explosion.scale = Vector2.ONE * (size_percent / 100.0)
	parent.add_child(explosion)


func _ready() -> void:
	Gfx.setup_animated(self, {
		&"boom": {"frames": [[30, 1], [31, 1], [32, 1], [33, 1], [34, 1]], "loop": false},
	})
	animation_finished.connect(queue_free)
	play(&"boom")
