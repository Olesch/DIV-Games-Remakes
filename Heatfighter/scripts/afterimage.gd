class_name Afterimage
extends Sprite2D
## Fading copy of a fighter drawn behind it (DIV: PROCESS SpezialAnim): five stages of 5 ticks,
## growing 5% twice and turning translucent for the last two.

const SCENE := preload("res://scenes/afterimage.tscn")
const STAGE_TICKS := 5

var _age: int = 0
var _flip: float = 1.0


static func spawn(parent: Node, fighter: Fighter) -> void:
	var image := SCENE.instantiate() as Afterimage
	image.texture = fighter.sprite.texture
	image.offset = fighter.sprite.offset
	image.position = fighter.position
	image._flip = fighter.sprite.scale.x
	image.scale = Vector2(image._flip, 1.0)
	parent.add_child(image)
	image.reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	_age += 1
	var stage := _age / STAGE_TICKS
	if stage >= 5:
		queue_free()
		return
	z_index = -10 - stage   # DIV: z = 10, 11, 12 ...
	var factor := 1.0
	if stage >= 2:
		factor = 1.05
	if stage >= 4:
		factor = 1.10
	scale = Vector2(_flip * factor, factor)
	modulate.a = 0.5 if stage >= 3 else 1.0
