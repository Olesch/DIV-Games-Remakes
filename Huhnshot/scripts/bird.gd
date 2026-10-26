class_name Bird
extends Node2D
## DIV: PROCESS Bird(x, y, flags). Logic runs per tick (physics rate = DIV's 24 fps) because the
## original flight model is a per-frame random walk. Positions/speeds are kept in DIV's tenths of a
## pixel (resolution=10) and converted to pixels for the node.

const LAST_FRAME := 13   # animation graphics 10..13
const OFFSCREEN_X_MIN := -500
const OFFSCREEN_X_MAX := 24500
const OFFSCREEN_Y_MIN := -500
const OFFSCREEN_Y_MAX := 6500
const FALL_SPEED := 40          # DIV: y+=40 (tenths) per frame once shot
const FALL_LIMIT := 8000

@onready var sprite: Sprite2D = $Sprite2D

var x10: int = 0
var y10: int = 0
var flags: int = 0               # bit 1 = mirrored horizontally, bit 2 = upside down (set when shot)
var size_pct: int = 100
var x_speed: int = 0
var y_speed: int = 0
var graph: int = 10
var _anim_wait: int = 0          # DIV: Waittograph
var _points: int = 0
var _dead_shots: int = 0         # DIV: Deadshot (extra hits on the falling bird)
var _dead: bool = false


func setup(start_x10: int, start_y10: int, start_flags: int) -> void:
	x10 = start_x10
	y10 = start_y10
	flags = start_flags


@warning_ignore("integer_division")
func _ready() -> void:
	add_to_group(&"birds")
	size_pct = randi_range(25, 100)
	z_index = size_pct               # DIV: z = -size (smaller birds are further away)
	y_speed = randi_range(-20, 20)
	x_speed = (((flags * 2) - 1) * size_pct * randi_range(4, 6)) / 10
	if x_speed == 0:
		x_speed = (flags * 2) - 1
	_apply_visual()
	reset_physics_interpolation()  # appear at the spawn point instead of sliding there from (0, 0)


func _physics_process(_delta: float) -> void:
	if _dead:
		y10 += FALL_SPEED
		if y10 > FALL_LIMIT:
			queue_free()
			return
		_apply_visual()
		return
	x10 += x_speed
	y10 += y_speed
	if randi_range(0, 15) == 0:
		y_speed += 7 if randi_range(0, 1) == 0 else -7
	if y10 < 750 and randi_range(0, 1) == 0:
		y_speed += 1
	if y10 > 5250 and randi_range(0, 1) == 0:
		y_speed -= 1
	y_speed = clampi(y_speed, -30, 30)
	_anim_wait += 1
	if _anim_wait > 10:
		graph += 1
		if graph > LAST_FRAME:
			graph = 10
		_anim_wait = 0
	if x10 > OFFSCREEN_X_MAX or x10 < OFFSCREEN_X_MIN or y10 > OFFSCREEN_Y_MAX or y10 < OFFSCREEN_Y_MIN:
		queue_free()
		return
	_apply_visual()


func world_position() -> Vector2:
	return Vector2(x10 / 10.0, y10 / 10.0)


## DIV: collision() with the mouse pointer (pixel exact, also true for the falling bird).
func contains_point(world_point: Vector2) -> bool:
	return Gfx.pixel_hit(graph, world_position(), _signed_scale(), world_point)


## DIV: the cursor set Killed=1 on this bird.
@warning_ignore("integer_division")
func hit() -> void:
	if _dead:
		Game.hits += 1
		_dead_shots += 1
		if _dead_shots > 4:
			Game.popup_world(str(_points), world_position())
			if Game.dead_bird_bonus != 1:
				Game.popup_screen("VERY DEAD BIRD BONUS!!", Vector2(400, 250))
				Game.dead_bird_bonus = 1
				Game.max_ammo += 1
			Game.add_score(_points)
			Game.combo_bar += _points
			queue_free()
		return
	Game.birds_killed += 1
	Game.hits += 1
	flags += 2
	_points = (110 - size_pct) + absi(x_speed / 4) + 10
	Game.add_score(_points)
	Game.combo_bar += _points
	Game.popup_world(str(_points), world_position())
	_dead = true
	_apply_visual()
	reset_physics_interpolation()  # flip upside down at once, not squashed through zero height


func _signed_scale() -> Vector2:
	var s := size_pct / 100.0
	return Vector2(-s if flags & 1 else s, -s if flags & 2 else s)


func _apply_visual() -> void:
	position = world_position()
	scale = _signed_scale()
	if sprite.texture != Gfx.tex(graph):
		Gfx.apply(sprite, graph)
	elif sprite.texture == null:
		Gfx.apply(sprite, graph)
