class_name Explosion
extends Area2D
## DIV: PROCESS explode(x, y, size) - graphs 11..16, one frame each, then it vanishes. Explosions do
## not hurt ships; they destroy every shot that touches them (which then explode too: chain reactions).

const SCENE := preload("res://scenes/explosion.tscn")

var _age := 0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _shape: CollisionShape2D = $CollisionShape2D


## Create an explosion in the "effects" layer; `size_percent` is DIV's size (100 = normal).
static func spawn(pos: Vector2, size_percent: int) -> void:
	if size_percent <= 0:
		return  # DIV: size 0 is invisible
	var tree := Engine.get_main_loop() as SceneTree
	var layer := tree.get_first_node_in_group(&"effects")
	if layer == null:
		return
	var explosion := SCENE.instantiate() as Explosion
	explosion.position = pos
	explosion.scale = Vector2.ONE * (size_percent / 100.0)
	layer.add_child(explosion)


func _ready() -> void:
	_show_frame()


func _physics_process(_delta: float) -> void:
	_age += 1
	if _age >= Defs.EXPLOSION_FRAMES:
		queue_free()
		return
	_show_frame()


func _show_frame() -> void:
	_sprite.texture = Gfx.tex(Gfx.FIRST_EXPLOSION + _age)
	# the last two pictures are sparse debris; approximating them with a disc would be wrong
	_shape.set_deferred(&"disabled", _age >= Defs.EXPLOSION_SOLID_FRAMES)
