class_name Shot
extends Area2D
## DIV: PROCESS shot(x, y, angle, graph). Flies at 7 px/frame, bounces off the wall map and off
## shields, and dies (with an explosion) when it has touched the wall too often, hits another shot,
## runs into an explosion, hits a ship, or leaves the screen.

const SCENE := preload("res://scenes/shot.tscn")
const SHIELD_LAYER := 1 << 2    # physics layer 3 "shield"

## DIV: Whatdo - set by whoever hit the shot. 1 = blow up, 2 = shrink away (own shot swallowed by its ship).
enum Fate { NONE, EXPLODE, FADE }

var owner_index := 0            # which ship fired it; the shot graphic is 7 + owner (DIV: graph = ship graph + 5)
var angle := 0                  # 1/1000 degree, counter-clockwise (DIV: angle)
var fate: Fate = Fate.NONE      # DIV: Whatdo
var _wall_hits := 0             # DIV: Treffer
var _pos := Vector2i.ZERO       # DIV coordinates are whole pixels
var _snapped := false           # turned around by a shield or bounced this step: no interpolation

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _shape: CollisionShape2D = $CollisionShape2D


## Fire a shot from a ship at `origin`; it appears 36 px ahead and makes its first step at once.
static func spawn(parent: Node, origin: Vector2, shot_angle: int, owner: int) -> Shot:
	var shot := SCENE.instantiate() as Shot
	shot.owner_index = owner
	shot.angle = shot_angle
	shot._pos = Vector2i(origin + Defs.advance_vector(shot_angle, Defs.SHOT_SPAWN_DISTANCE))
	parent.add_child(shot)
	return shot


func _ready() -> void:
	_sprite.texture = Gfx.shot_tex(owner_index)
	_apply_transform()
	_step()  # DIV: a new process runs up to its first FRAME before the caller continues
	reset_physics_interpolation()  # appear ahead of the ship instead of sliding in from (0, 0)


func _physics_process(_delta: float) -> void:
	_step()


func _step() -> void:
	if Defs.is_outside_screen(Vector2(_pos), Defs.SHOT_SIZE, angle):
		_explode()
		return
	_advance(Defs.SHOT_SPEED)

	var areas := get_overlapping_areas()
	# a shield turns the shot around (DIV: collision(TYPE Playershield)). Checked at the position just
	# reached, like DIV: the polled overlap list is one tick old, so it would still report the shield
	# after the turn-around and flip the shot back every tick - the shot got stuck in the shield.
	if _touches_shield():
		angle += 180000
		_advance(Defs.SHIELD_PUSHBACK)
		_snapped = true

	# touching the map (DIV: collision(TYPE screen)) costs "life", then bounce off the side that was hit
	if WallMap.overlaps(_pos, Gfx.shot_pixels()):
		_wall_hits += Defs.WALL_HIT_COST
		if _wall_hits > Game.shot_life:
			_explode()
			return
		_bounce_off_walls()
		_snapped = true

	# shot against shot (DIV: Eigenkillb). Only the first overlapping shot is looked at, like collision().
	var other := _first_in_group(areas, &"shots") as Shot
	if other:
		if Game.shots_hit_own_shots == 0:
			if other.owner_index != owner_index:
				other.fate = Fate.EXPLODE
				_explode()
				return
		else:
			other.fate = Fate.EXPLODE
			_explode()
			return

	if _first_in_group(areas, &"explosions"):
		_explode()
		return
	if fate == Fate.EXPLODE:
		_explode()
		return
	if fate == Fate.FADE:
		FadingShot.spawn(get_parent(), Vector2(_pos), owner_index)
		queue_free()
		return
	_apply_transform()


## Immediate shape query against the shield layer at the current (not yet drawn) position.
func _touches_shield() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _shape.shape
	query.transform = Transform2D(0.0, Vector2(_pos))  # the shape is a circle, rotation does not matter
	query.collision_mask = SHIELD_LAYER
	query.collide_with_areas = true
	query.collide_with_bodies = false
	return not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _advance(distance: int) -> void:
	_pos += Vector2i(Defs.advance_vector(angle, distance))


## The four map probes of the original: wall 18 px to the left / right / above / below the shot.
func _bounce_off_walls() -> void:
	var probe := Defs.WALL_PROBE
	if WallMap.is_wall(_pos.x - probe, _pos.y):
		angle = 540000 - angle  # DIV: Rech=360000-angle; Rech=90000-Rech; angle=270000-Rech
		_pos.x += Defs.WALL_PUSH
	if WallMap.is_wall(_pos.x + probe, _pos.y):
		angle = 540000 - angle
		_pos.x -= Defs.WALL_PUSH
	if WallMap.is_wall(_pos.x, _pos.y - probe):
		angle = 360000 - angle  # DIV: Rech=90000-angle; Rech=90000-Rech; angle=360000-Rech
		_pos.y += Defs.WALL_PUSH
	if WallMap.is_wall(_pos.x, _pos.y + probe):
		angle = 360000 - angle
		_pos.y -= Defs.WALL_PUSH


func _explode() -> void:
	Explosion.spawn(Vector2(_pos), Game.shot_explosion_size)
	queue_free()


func _apply_transform() -> void:
	position = Vector2(_pos)
	rotation = Defs.to_rotation(angle)
	if _snapped:
		reset_physics_interpolation()  # new heading at once, not a half-turn sweep
		_snapped = false


static func _first_in_group(areas: Array[Area2D], group: StringName) -> Area2D:
	for area in areas:
		if area.is_in_group(group) and not area.is_queued_for_deletion():
			return area
	return null
