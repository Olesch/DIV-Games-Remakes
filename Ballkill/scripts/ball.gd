class_name Ball
extends Node2D
## DIV: PROCESS Ball. Rises from the bottom; clicking it with the pin lowers its life; the dryer
## (Foen) blows it down. A ball reaching the top ends the game.
## Logic runs once per physics tick (the project runs at 18 ticks/s = the original set_fps(18));
## positions are kept in 1/100 px like the original resolution=100.

signal escaped

const SPAWN_Y := 60000          # 1/100 px
const SPAWN_X_MAX := 80000
const WIND_HALF_WIDTH := 4000   # the dryer covers +-40 px
const WIND_PUSH := 10           # DIV: Xinc-=10 under the dryer
const SPEED_RECOVERY := 3       # DIV: Xinc+=3 every frame
const POP_TIME := 1.0 / 18.0    # the "pop" graphic is shown for one frame
const CENTRE := Vector2(20, 20) # control point 0 of the ball graphic

const BALL_TEX := preload("res://assets/fpg/ballkill/1.png")
const POP_TEX := preload("res://assets/fpg/ballkill/2.png")
const PIN_TEX := preload("res://assets/fpg/ballkill/3.png")

static var _ball_alpha: Image
static var _pin_pixels: PackedVector2Array

var foen: Foen
var life: int = 0
var max_speed: int = 100   # DIV: MaxXinc (1/100 px per frame)
var speed: int = 100       # DIV: Xinc
var x_centi: int = 0
var y_centi: int = SPAWN_Y
var _alive := true

@onready var _sprite: Sprite2D = $Sprite


## Randomise a new ball for the given level (DIV: top of PROCESS Ball).
func setup(level: int, foen_node: Foen) -> void:
	foen = foen_node
	life = randi_range(0, level)
	max_speed = maxi(randi_range(0, level) * 100, 100)
	speed = max_speed
	x_centi = randi_range(0, SPAWN_X_MAX)
	y_centi = SPAWN_Y


func _ready() -> void:
	add_to_group(&"balls")
	_update_visual()
	reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	if not _alive:
		return
	var under_dryer: bool = x_centi < foen.x_centi + WIND_HALF_WIDTH and x_centi > foen.x_centi - WIND_HALF_WIDTH
	if under_dryer and y_centi < SPAWN_Y:
		speed -= WIND_PUSH
	speed = mini(speed + SPEED_RECOVERY, max_speed)
	y_centi -= speed
	_update_visual()
	if y_centi < 0:
		_alive = false
		remove_from_group(&"balls")
		escaped.emit()


## Mouse click at `point` (DIV: mouse.left and collision(TYPE mouse)): a pixel of the pin
## graphic must overlap an opaque pixel of the ball. Returns true if the ball was hit.
func try_hit(point: Vector2) -> bool:
	if not _alive or not _pin_touches(point):
		return false
	life -= 1
	Game.add_score(1)
	if life < 1:
		Game.add_score(1)
		_pop()
	else:
		_update_visual()
	return true


## Stop moving and stay visible (the game is over).
func freeze() -> void:
	_alive = false


func _pop() -> void:
	_alive = false
	remove_from_group(&"balls")
	_sprite.texture = POP_TEX
	get_tree().create_timer(POP_TIME).timeout.connect(queue_free)


func _update_visual() -> void:
	position = Vector2(x_centi, y_centi) / 100.0
	_sprite.scale = Vector2.ONE * _size_factor()


## DIV: size=100+Life*10 percent.
func _size_factor() -> float:
	return 1.0 + maxf(life, 0) * 0.1


func _pin_touches(point: Vector2) -> bool:
	_init_masks()
	var factor := _size_factor()
	var centre := position.floor()
	for p in _pin_pixels:
		var local := (point + p + Vector2(0.5, 0.5) - centre) / factor + CENTRE
		var ix := floori(local.x)
		var iy := floori(local.y)
		if ix >= 0 and iy >= 0 and ix < 40 and iy < 40 and _ball_alpha.get_pixel(ix, iy).a > 0.0:
			return true
	return false


static func _init_masks() -> void:
	if _ball_alpha != null:
		return
	_ball_alpha = BALL_TEX.get_image()
	var pin := PIN_TEX.get_image()
	for y in pin.get_height():
		for x in pin.get_width():
			if pin.get_pixel(x, y).a > 0.0:
				_pin_pixels.append(Vector2(x, y))  # pin control point 0 is (0,0)
