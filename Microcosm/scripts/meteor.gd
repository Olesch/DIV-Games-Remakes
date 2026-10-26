class_name Meteor
extends Area2D
## DIV: PROCESS Meteor(x, xincr, yincr, angleincr, Art).
## Kinds: NORMAL (dies on one hit), IRON (needs 2), DOUBLE (splits into two normal ones),
## DOUBLE_IRON (needs a hit to crack), DOUBLE_IRON_CRACKED (splits into two iron ones).

const SCENE_PATH := "res://scenes/meteor.tscn"
const GRAPHIC_BASE := 25  # DIV: graph = 25 + Art

## Drift in pixels per DIV frame (kept in original units; the formula that the super Duk uses
## to predict where a meteor goes needs them as they are).
var xincr: int = 0
var yincr: int = 4
## Spin in thousandths of a degree per frame, counter-clockwise (DIV: angleincr)
var angleincr: int = 0
var kind: Defs.MeteorKind = Defs.MeteorKind.NORMAL

var _dead := false

@onready var _sprite: Sprite2D = $Sprite
@onready var _single_shape: CollisionShape2D = $SingleShape
@onready var _double_shape: CollisionShape2D = $DoubleShape


## Call before add_child().
func setup(pos: Vector2, drift_x: int, drift_y: int, spin: int, meteor_kind: Defs.MeteorKind) -> void:
	position = pos
	xincr = drift_x
	yincr = drift_y
	angleincr = spin
	kind = meteor_kind
	rotation = deg_to_rad(randf_range(-180.0, 180.0))  # DIV: angle = rand(-180000, 180000)


func _ready() -> void:
	add_to_group(&"meteors")
	Game.atom_blast.connect(_on_atom_blast)
	_set_kind(kind)


func _physics_process(delta: float) -> void:
	if Gfx.is_outside_screen(position, _sprite.texture.get_size(), rotation):
		queue_free()
		return
	position += Vector2(xincr, yincr) * Defs.FPS * delta
	rotation -= deg_to_rad(angleincr / 1000.0 * Defs.FPS) * delta  # DIV angles run counter-clockwise

	var hit := _find_hit()
	if hit != null:
		if hit is Shot:
			(hit as Shot).absorb_hit()
		elif hit is Bird:
			(hit as Bird).die()
		take_hit()
		if _dead:
			return
	if position.y > Defs.GROUND_Y:
		blow_up(100)


func is_metal() -> bool:
	return kind == Defs.MeteorKind.IRON or kind == Defs.MeteorKind.DOUBLE_IRON \
		or kind == Defs.MeteorKind.DOUBLE_IRON_CRACKED


## Explode and disappear (also used by Duks that get hit).
func blow_up(explosion_size: int) -> void:
	if _dead:
		return
	_dead = true
	Explosion.spawn(get_parent(), position, explosion_size)
	queue_free()


## One hit by a rocket, bird or atom bomb pulse.
func take_hit() -> void:
	if _dead:
		return
	match kind:
		Defs.MeteorKind.NORMAL:
			blow_up(100)
		Defs.MeteorKind.IRON:
			Explosion.spawn(get_parent(), position, 100)
			_set_kind(Defs.MeteorKind.NORMAL)
		Defs.MeteorKind.DOUBLE:
			Explosion.spawn(get_parent(), position, 175)
			_set_kind(Defs.MeteorKind.NORMAL)
			_split()
		Defs.MeteorKind.DOUBLE_IRON:
			Explosion.spawn(get_parent(), position, 200)
			_set_kind(Defs.MeteorKind.DOUBLE_IRON_CRACKED)
		Defs.MeteorKind.DOUBLE_IRON_CRACKED:
			Explosion.spawn(get_parent(), position, 175)
			_set_kind(Defs.MeteorKind.IRON)
			_split()


func _set_kind(new_kind: Defs.MeteorKind) -> void:
	kind = new_kind
	Gfx.apply(_sprite, GRAPHIC_BASE + kind)
	var is_double := kind >= Defs.MeteorKind.DOUBLE
	_single_shape.set_deferred(&"disabled", is_double)
	_double_shape.set_deferred(&"disabled", not is_double)


## DIV: xincr = rand(-3,3); CLONE (random angle and spin, mirrored xincr) END
func _split() -> void:
	xincr = randi_range(-3, 3)
	var twin := (load(SCENE_PATH) as PackedScene).instantiate() as Meteor
	twin.setup(position, -xincr, yincr, randi_range(-25000, 25000), kind)
	get_parent().add_child.call_deferred(twin)


## First rocket (otherwise bird) overlapping this meteor.
func _find_hit() -> Area2D:
	var areas := get_overlapping_areas()
	for area in areas:
		if area is Shot and not area.is_queued_for_deletion():
			return area
	for area in areas:
		if area is Bird and not area.is_queued_for_deletion():
			return area
	return null


func _on_atom_blast() -> void:
	take_hit()
