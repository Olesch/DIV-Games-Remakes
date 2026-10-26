class_name Explosion
extends Node2D
## Five-frame explosion animation (DIV process `Explosion`, graphics 10..14, one frame each).

const FPS := 40.0
const GFX := "res://assets/fpg/hatsch1/"

var _size_percent := 100


func setup(pos: Vector2, size_percent: int) -> void:
	position = pos
	_size_percent = size_percent


func _ready() -> void:
	scale = Vector2.ONE * (_size_percent / 100.0)
	reset_physics_interpolation()  # show the final size at once, not growing from 100 %
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"boom")
	frames.set_animation_speed(&"boom", FPS)
	frames.set_animation_loop(&"boom", false)
	for code in range(10, 15):
		frames.add_frame(&"boom", load("%s%d.png" % [GFX, code]))
	var sprite := $AnimatedSprite2D as AnimatedSprite2D
	sprite.sprite_frames = frames
	sprite.animation_finished.connect(queue_free)
	sprite.play(&"boom")
