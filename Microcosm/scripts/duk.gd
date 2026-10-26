class_name Duk
extends Area2D
## DIV: PROCESS Duk() - the little creature you have to protect. It wanders along the ground,
## pays a "tax" now and then, dies when a meteor touches it, and becomes a super Duk (which
## survives one hit and runs away from meteors) after drinking a potion.

const WALK_LEFT_LIMIT := 150.0
const WALK_RIGHT_LIMIT := 874.0
const FLEE_RANGE := 150.0     # DIV: get_dist(meteor) < 150
const FLEE_SPEED := 3         # px per frame (DIV: Movingspeed = 3)

var super_duk: bool = false   # DIV: Super

var _walk_dir: int = 0        # DIV: Walkdir: 1 right, 0 stand, -1 left
var _speed: int = 0           # px per DIV frame (DIV: Movingspeed)
var _dying := false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _tax_timer: Timer = $TaxTimer


func _ready() -> void:
	add_to_group(&"duks")
	position = Vector2(randi_range(0, 1) * 1024.0, randi_range(700, 720))
	z_index = int(position.y - 690.0)  # DIV: z -= y - 690
	Gfx.setup_animated(_sprite, {
		&"idle": {"frames": [[1, 1]]},
		&"walk": {"frames": [[2, 7], [1, 8]]},
		&"super_idle": {"frames": [[7, 1]]},
		&"super_walk": {"frames": [[8, 7], [7, 8]]},
		&"die": {"frames": [[3, 4], [4, 4], [5, 4], [6, 4]], "loop": false},
	})
	_sprite.animation_finished.connect(_on_animation_finished)
	_tax_timer.timeout.connect(_on_tax_timer_timeout)
	_start_tax_timer()
	_update_animation()


func _physics_process(delta: float) -> void:
	if _dying:
		return
	if _walk_dir == 1:
		_sprite.scale.x = 1.0   # DIV: flags = 0
		position.x += _speed * Defs.FPS * delta
	elif _walk_dir == -1:
		_sprite.scale.x = -1.0  # DIV: flags = 1 (mirrored)
		position.x -= _speed * Defs.FPS * delta
	if position.x > WALK_RIGHT_LIMIT:
		_walk_dir = -1
	if position.x < WALK_LEFT_LIMIT:
		_walk_dir = 1
	if super_duk:
		_flee_from_meteors()
	_update_animation()
	_check_overlaps()


func make_super() -> void:
	super_duk = true
	_update_animation()


## Paying taxes happens whenever the walking counter runs out (and picks a new direction).
func _on_tax_timer_timeout() -> void:
	_walk_dir = randi_range(-1, 1)
	_speed = randi_range(1, 2)
	var tax := 3
	if Game.difficulty > 3:
		tax += Game.difficulty - 3
	if super_duk:
		tax += 5 + Game.difficulty - 3
	Game.money += tax
	_start_tax_timer()


## DIV: Walkdircount++ every frame, and once more while standing; the Duk acts when the counter
## exceeds rand(50,100) - a new random number every frame, which makes the interval shorter
## than a plain rand(50,100). The number of frames is rolled here the same way.
func _start_tax_timer() -> void:
	var standing := _walk_dir == 0
	var count := 1 if standing else 0
	var frames := 0
	while true:
		frames += 1
		count += 1
		if count > randi_range(50, 100):
			break
		if standing:
			count += 1
	_tax_timer.start(frames / Defs.FPS)


## Super Duks run away from the meteors, away from where they will be (DIV: "wegrennen").
func _flee_from_meteors() -> void:
	for node in get_tree().get_nodes_in_group(&"meteors"):
		var meteor := node as Meteor
		if meteor == null or position.distance_to(meteor.position) >= FLEE_RANGE:
			continue
		if meteor.position.x + meteor.xincr * meteor.yincr * 2 - position.x > 0.0:
			_walk_dir = -1
		else:
			_walk_dir = 1
		_speed = FLEE_SPEED


func _update_animation() -> void:
	var prefix := "super_" if super_duk else ""
	var anim := StringName(prefix + ("idle" if _walk_dir == 0 else "walk"))
	if _sprite.animation != anim:
		_sprite.play(anim)


func _check_overlaps() -> void:
	var overlapping := get_overlapping_areas()
	for area in overlapping:
		if area is Meteor and not area.is_queued_for_deletion():
			(area as Meteor).blow_up(100)
			if not super_duk:
				_die()
				return
			Game.potions_amount -= 1
			super_duk = false
			break
	if not super_duk:
		for area in overlapping:
			if area is Potion and not area.is_queued_for_deletion():
				(area as Potion).collect()
				make_super()
				break


func _die() -> void:
	_dying = true
	remove_from_group(&"duks")
	_tax_timer.stop()
	set_deferred(&"monitoring", false)
	set_deferred(&"monitorable", false)
	_sprite.play(&"die")


func _on_animation_finished() -> void:
	if _dying:
		queue_free()
