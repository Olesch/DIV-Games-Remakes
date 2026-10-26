class_name Bird
extends Area2D
## DIV: PROCESS Bird(Art=100) - a bird that paces along the ground and acts as a meteor shield:
## a meteor that touches it destroys the bird (and takes a hit itself).

const LEFT_LIMIT := 150.0
const RIGHT_LIMIT := 874.0

var _walk_dir: int = 0   # 1 right, -1 left, 0 = not started yet
var _speed: int = 4      # px per DIV frame (DIV: xincr = rand(3,5))

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	add_to_group(&"birds")
	position = Vector2(randi_range(0, 1) * 1029.0, randi_range(650, 670))
	z_index = int(position.y - 700.0)  # DIV: z -= y - 700
	_speed = randi_range(3, 5)
	Gfx.setup_animated(_sprite, {
		# DIV: graphcount<8 -> graph 37 (7 frames), else graph 36 (8 frames)
		&"walk": {"frames": [[37, 7], [36, 8]]},
	})
	_sprite.play(&"walk")


func _physics_process(delta: float) -> void:
	if _walk_dir == 1:
		_sprite.scale.x = 1.0
		position.x += _speed * Defs.FPS * delta
	elif _walk_dir == -1:
		_sprite.scale.x = -1.0
		position.x -= _speed * Defs.FPS * delta
	if position.x > RIGHT_LIMIT:
		_walk_dir = -1
		_speed = randi_range(3, 5)
	if position.x < LEFT_LIMIT:
		_walk_dir = 1
		_speed = randi_range(3, 5)


func die() -> void:
	Game.birds_amount -= 1
	queue_free()
