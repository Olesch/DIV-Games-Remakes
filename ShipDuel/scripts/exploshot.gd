class_name Exploshot
extends Node2D
## DIV: PROCESS Exploshot(x, y, angle, graph) - the "mana" attack. A wobbling projectile that flies
## through everything and leaves a trail of three small explosions per frame, which destroy any shot
## they touch. It never hurts a ship directly and cannot be stopped (no collision of its own).

const SCENE := preload("res://scenes/exploshot.tscn")

var owner_index := 0
var angle := 0
var _pos := Vector2i.ZERO

@onready var _sprite: Sprite2D = $Sprite2D


static func spawn(parent: Node, origin: Vector2, shot_angle: int, owner: int) -> void:
	var exploshot := SCENE.instantiate() as Exploshot
	exploshot.owner_index = owner
	exploshot.angle = shot_angle
	exploshot._pos = Vector2i(origin + Defs.advance_vector(shot_angle, Defs.EXPLOSHOT_SPAWN_DISTANCE))
	# DIV: explode(x, y, (exploshotrad * 3) / 2) before the loop
	Explosion.spawn(Vector2(exploshot._pos), Defs.EXPLOSHOT_RADIUS * 3 / 2)
	parent.add_child(exploshot)


func _ready() -> void:
	_sprite.texture = Gfx.shot_tex(owner_index)
	_step()
	reset_physics_interpolation()  # appear ahead of the ship instead of sliding in from (0, 0)


func _physics_process(_delta: float) -> void:
	_step()


func _step() -> void:
	if Defs.is_outside_screen(Vector2(_pos), Defs.SHOT_SIZE, angle):
		queue_free()
		return
	for i in 3:
		var spread := Defs.EXPLOSHOT_SPREAD
		var at := Vector2(_pos + Vector2i(randi_range(-spread, spread), randi_range(-spread, spread)))
		Explosion.spawn(at, Defs.EXPLOSHOT_RADIUS)
	_pos += Vector2i(Defs.advance_vector(angle, Defs.EXPLOSHOT_SPEED))
	angle += randi_range(-Defs.EXPLOSHOT_TURN, Defs.EXPLOSHOT_TURN)
	position = Vector2(_pos)
	rotation = Defs.to_rotation(angle)
