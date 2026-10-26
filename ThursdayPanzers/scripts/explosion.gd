class_name Explosion
extends AnimatedSprite2D
## DIV: Explode(x,y,size) - graphics 60..65, one frame each, then it vanishes.

const FRAME_CODES := [60, 61, 62, 63, 64, 65]

var size_percent: int = 100


static func spawn(parent: Node, pos: Vector2, percent: int) -> void:
	var e := preload("res://scenes/explosion.tscn").instantiate() as Explosion
	e.size_percent = percent
	e.position = pos
	parent.add_child(e)


func _ready() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"boom")
	frames.set_animation_speed(&"boom", Game.FPS)
	frames.set_animation_loop(&"boom", false)
	for code: int in FRAME_CODES:
		frames.add_frame(&"boom", load("res://assets/fpg/thurpanz/%d.png" % code))
	sprite_frames = frames
	scale = Vector2.ONE * size_percent / 100.0
	animation_finished.connect(queue_free)
	play(&"boom")
	reset_physics_interpolation()
