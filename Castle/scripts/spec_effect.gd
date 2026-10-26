class_name SpecEffect
extends Node2D
## DIV: PROCESS SpecEffect(x,y,angle,angpl,size) - title-screen particle: a 50% transparent red ball
## (graph 99) that flies along `angle` at 8 px/frame, turns by `angpl` per frame and shrinks 3% per frame.

var ang: int = 0        # thousandths of a degree, counter-clockwise
var ang_step: int = 0
var size_pct: int = 100
var ix: int = 0
var iy: int = 0

@onready var _sprite: Sprite2D = $Sprite


func setup(px: int, py: int, angle_thousandths: int, angle_step: int, size_value: int) -> void:
	ix = px
	iy = py
	ang = angle_thousandths
	ang_step = angle_step
	size_pct = size_value


func _ready() -> void:
	Gfx.apply(_sprite, 99)
	_sprite.modulate.a = 0.5
	_apply()
	if size_pct <= 0:
		queue_free()


func _physics_process(_delta: float) -> void:
	# DIV: FRAME; advance(8); angle+=angpl; size-=3
	var a := deg_to_rad(ang / 1000.0)
	ix += int(cos(a) * 8.0)
	iy += int(-sin(a) * 8.0)
	ang += ang_step
	size_pct -= 3
	if size_pct <= 0:
		queue_free()
		return
	_apply()


func _apply() -> void:
	position = Vector2(ix, iy)
	rotation = -deg_to_rad(ang / 1000.0)
	scale = Vector2.ONE * (size_pct / 100.0)
