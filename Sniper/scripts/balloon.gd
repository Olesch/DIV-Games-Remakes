class_name Balloon
extends Area2D
## DIV: PROCESS Ballon(x,size,speed). Rises from below the screen; a shot pops it (PLOP graphic
## for 6 frames), otherwise it lives until it has left the screen.

const POP_FRAMES := 6  # DIV FRAME(600)

var rise_speed := 2.0  # px per frame (DIV `speed`)
var _pop_ticks := -1

@onready var _sprite: Sprite2D = $Sprite2D


## Call before add_child. DIV: Ballon(Rand(300,1024), Rand(15,50), Rand(2,9)), y=768.
func setup(x: float, size_pct: float, speed: float) -> void:
	position = Vector2(x, Gfx.SCREEN_SIZE.y)
	rise_speed = speed
	scale = Vector2.ONE * size_pct / 100.0


func _ready() -> void:
	add_to_group(&"balloons")
	Gfx.apply(_sprite, 9)


func _physics_process(_delta: float) -> void:
	if _pop_ticks >= 0:
		_pop_ticks -= 1
		if _pop_ticks < 0:
			queue_free()
		return
	if Gfx.is_outside_screen(position, _sprite.texture.get_size() * scale, 0.0):
		queue_free()
		return
	position.y -= rise_speed
	if not get_overlapping_areas().is_empty():
		_pop()


func _pop() -> void:
	Gfx.apply(_sprite, 10)
	_pop_ticks = POP_FRAMES
