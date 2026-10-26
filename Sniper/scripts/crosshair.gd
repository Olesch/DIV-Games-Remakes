class_name Crosshair
extends Node2D
## DIV: PROCESS Fadenkreuz(). The DIV mouse is a driver counter that the game itself moves
## (recoil, random tremor), so the crosshair keeps a virtual pointer fed by relative mouse motion
## (captured mouse; works in the browser too, unlike warp_mouse). Esc (release) is handled by main.gd.

const MIN_X := 150.0  # DIV: IF(x<150) mouse.x=150
const TREMOR := 8     # DIV: mouse += rand(-8,8) every frame

## Pointer position (updated live by mouse motion).
var pointer := Gfx.SCREEN_SIZE / 2.0
## Position as of the last 24 fps tick; the snipers aim at this (DIV: Fadenkreuz_id.x/y).
var aim_position := Gfx.SCREEN_SIZE / 2.0
## Set to false by tests that place the crosshair by hand.
var follow_mouse := true

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group(&"crosshair")
	Gfx.apply(_sprite, 5)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	position = pointer


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and follow_mouse:
		pointer += (event as InputEventMouseMotion).relative
		_clamp()
	elif event is InputEventMouseButton and event.pressed \
			and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(_delta: float) -> void:
	pointer += Vector2(randi_range(-TREMOR, TREMOR), randi_range(-TREMOR, TREMOR))
	_clamp()
	aim_position = pointer


func _process(_delta: float) -> void:
	position = pointer


## Gun recoil: DIV `mouse.x-=30; mouse.y-=200` (every sniper kicks the pointer).
func recoil(offset: Vector2) -> void:
	pointer += offset
	_clamp()


func _clamp() -> void:
	pointer = Vector2(clampf(pointer.x, MIN_X, Gfx.SCREEN_SIZE.x - 1.0),
		clampf(pointer.y, 0.0, Gfx.SCREEN_SIZE.y - 1.0))
