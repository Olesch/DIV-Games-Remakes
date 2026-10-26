class_name Player
extends Area2D
## A rider on a cannonball (DIV: PROCESS player). Left/right keys change the horizontal
## speed x_inc (-25..25), wind pushes it, walls bounce it, and two riders swap speeds when they touch.
## One step per 24 Hz physics tick; all values are the DIV per-frame integers.

signal died

const SPEED_LIMIT := 25
const START_LIVES := 3
const HIT_COOLDOWN := 24      # frames of invulnerability after a hit (DIV: wait2)
const COLLISION_BOOST := 15   # extra speed in the frame of a rider collision
const SCREEN_W := 640

const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")

@export var player_number: int = 1
@export var left_action: StringName = &"p1_left"
@export var right_action: StringName = &"p1_right"
@export var graph: int = 1

var x: int = 320
var y: int = 400
var x_inc: int = 0            # horizontal speed in px/frame
var speed_change: int = 0     # DIV: SpeedChange - speed handed over by the other rider after a collision
var lives: int = START_LIVES  # DIV: Life (the 4th hit kills)
var angle: int = 0            # DIV angle in thousandths of a degree (ccw)

var other: Player = null      # the other rider in a two-player game
var _x_inc_work: int = 0
var _wind_counter: int = 0    # DIV: Windzaehlung
var _touch_cooldown: int = 0  # DIV: wait - no two rider collisions right after each other
var _hit_cooldown: int = 0    # DIV: wait2 - no two cannonball hits right after each other

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group(&"players")
	Gfx.apply(_sprite, graph)
	_build_collision_from_sprite()
	_apply_transform()
	reset_physics_interpolation()


## Collision polygons from the opaque pixels of the sprite (DIV: pixel-exact collision()).
func _build_collision_from_sprite() -> void:
	var image := _sprite.texture.get_image()
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image)
	for polygon in bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, image.get_size()), 2.0):
		var shape := CollisionPolygon2D.new()
		var points := PackedVector2Array()
		for p in polygon:
			points.append(p - Gfx.CP0[graph])
		shape.polygon = points
		add_child(shape)


func _physics_process(_delta: float) -> void:
	_apply_wind()
	_handle_rider_collision()
	_steer()
	if _handle_cannonball_hit():
		return
	_move()
	# DIV: Angle=((x_inc*-2000)+Angle*5)/6 - leans into the direction of travel, smoothed
	@warning_ignore("integer_division")
	angle = (x_inc * -2000 + angle * 5) / 6
	_apply_transform()


@warning_ignore("integer_division")
func _apply_wind() -> void:
	_wind_counter += 1
	if Game.wind != 0 and _wind_counter > (23 - absi(Game.wind)) / 2:
		x_inc += signi(Game.wind)
		_wind_counter = 0


func _handle_rider_collision() -> void:
	# DIV: rider 1 detects the collision and gives rider 2 its speed; rider 2 then applies it.
	_x_inc_work = x_inc
	if player_number == 1:
		if _touch_cooldown < 0 and other != null and is_instance_valid(other) and overlaps_area(other):
			x_inc = other.x_inc
			other.speed_change = _x_inc_work
			_x_inc_work = x_inc
			_x_inc_work += COLLISION_BOOST * signi(_x_inc_work)
			_touch_cooldown = 2
		if _touch_cooldown > -2:
			_touch_cooldown -= 1
	elif speed_change != 0:
		x_inc = speed_change
		speed_change = 0
		_x_inc_work = x_inc
		_x_inc_work += COLLISION_BOOST * signi(_x_inc_work)


func _steer() -> void:
	if Input.is_action_pressed(left_action):
		x_inc -= 1
	if Input.is_action_pressed(right_action):
		x_inc += 1
	x_inc = clampi(x_inc, -SPEED_LIMIT, SPEED_LIMIT)


## Returns true when this hit killed the rider.
func _handle_cannonball_hit() -> bool:
	if _hit_cooldown < 0:
		for area in get_overlapping_areas():
			if area is Cannonball and (area as Cannonball).is_dangerous():
				_hit_cooldown = HIT_COOLDOWN
				var boom := EXPLOSION_SCENE.instantiate() as Explosion
				boom.position = Vector2(x, y)
				get_parent().add_child(boom)
				lives -= 1
				if lives < 0:
					died.emit()
					queue_free()
					return true
				break
	if _hit_cooldown > -2:
		_hit_cooldown -= 1
	return false


## DIV: moves |speed|+1 single pixels, bouncing at the screen edges (and flipping x_inc).
func _move() -> void:
	if _x_inc_work == 0:
		return
	var direction := signi(_x_inc_work)
	var remaining := absi(_x_inc_work)
	while true:
		x += direction
		remaining -= 1
		if x < 1:
			direction = -direction
			x = 2
			x_inc = -x_inc
		if x > SCREEN_W - 1:
			direction = -direction
			x = SCREEN_W - 2
			x_inc = -x_inc
		if remaining < 0:
			break


func _apply_transform() -> void:
	position = Vector2(x, y)
	rotation = -deg_to_rad(angle / 1000.0)
