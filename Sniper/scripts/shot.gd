class_name Shot
extends Area2D
## DIV: PROCESS Shot(x,y,angle,MODE). Sniper/minigun bullets are 140x3 beams flying 70 px per
## frame; grenades (mode 2) trail smoke and curve downwards.

const SMOKE_SCENE := preload("res://scenes/smoke.tscn")
const BULLET_SPEED := 70.0   # DIV advance(70) per frame (physics runs at the game's 24 fps)
const GRENADE_SPEED := 26.0  # DIV advance(26)
const GRENADE_TURN := 2.75   # DIV Angle-=2750 (thousandths of a degree) per frame
const GRENADE_MIN_ANGLE := -90.0

var mode: int = Sniper.Mode.NORMAL
var angle_deg := 0.0  # DIV angle, counter-clockwise degrees

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _shape: CollisionShape2D = $CollisionShape2D


## Call before add_child.
func setup(pos: Vector2, angle: float, shot_mode: int) -> void:
	position = pos
	angle_deg = angle
	mode = shot_mode
	rotation = -deg_to_rad(angle_deg)


func _ready() -> void:
	add_to_group(&"shots")
	var rect := RectangleShape2D.new()
	if mode == Sniper.Mode.GRENADE:
		Gfx.apply(_sprite, 11)
		rect.size = Vector2(35, 35)
	else:
		Gfx.apply(_sprite, 8)
		rect.size = Vector2(140, 3)
		_shape.position = Vector2(0, 0.5)
	_shape.shape = rect
	_step()  # DIV: the new process runs its first loop pass immediately


func _physics_process(_delta: float) -> void:
	_step()


func _step() -> void:
	if Gfx.is_outside_screen(position, _sprite.texture.get_size(), rotation):
		queue_free()
		return
	if mode == Sniper.Mode.GRENADE:
		var smoke := SMOKE_SCENE.instantiate() as Smoke
		smoke.position = position + Vector2(randi_range(-2, 2), randi_range(-2, 2))
		get_parent().add_child(smoke)
		position += Vector2.from_angle(rotation) * GRENADE_SPEED
		if angle_deg > GRENADE_MIN_ANGLE:
			angle_deg -= GRENADE_TURN
			rotation = -deg_to_rad(angle_deg)
	else:
		position += Vector2.from_angle(rotation) * BULLET_SPEED
