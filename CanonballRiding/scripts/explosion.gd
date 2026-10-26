class_name Explosion
extends AnimatedSprite2D
## Hit explosion at a player (DIV: PROCESS explode(x, y, 500)): graphics 30..35, 1.5 frames each.

const SIZE_PCT := 500
const FRAME_LENGTH := 1.5  # DIV: FRAME(150)


func _ready() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"boom")
	frames.set_animation_speed(&"boom", 24.0)
	frames.set_animation_loop(&"boom", false)
	for code in range(30, 36):
		frames.add_frame(&"boom", Gfx.tex(code), FRAME_LENGTH)
	sprite_frames = frames
	centered = false
	offset = -Gfx.CP0[30]
	scale = Vector2.ONE * (SIZE_PCT / 100.0)
	reset_physics_interpolation()  # full size at once, not growing from 100 % in the first tick
	animation_finished.connect(queue_free)
	play(&"boom")
