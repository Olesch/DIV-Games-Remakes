class_name Shot
extends Area2D
## DIV: Schuss(x,y,angle,power,move). Starts 20 px ahead of the muzzle, then flies
## 5 px + the shooter's speed per frame for 40 frames. Hits the first other tank it touches.

const START_OFFSET := 20.0      # DIV: advance(2000) at resolution 100
const BASE_SPEED := 5.0         # DIV: advance(500+move) per frame
const LIFETIME_TICKS := 40      # DIV: FOR(way=0; way<40; way++)
const REAR_HIT_LIMIT := 135000  # DIV: hit_ang within +-135000 -> hit from behind

var shooter: Tank
var team: int = 0
var power: int = 0
var angle: int = 0              # thousandths of a degree, counter-clockwise (DIV angle)
var shooter_move: int = 0       # DIV: move, 1/100 px per frame

var _direction := Vector2.RIGHT
var _ticks := 0
var _done := false


func _ready() -> void:
	_direction = Vector2.from_angle(-deg_to_rad(angle / 1000.0))
	rotation = _direction.angle()
	position += _direction * START_OFFSET
	area_entered.connect(_on_area_entered)
	reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	if _done or _ticks >= LIFETIME_TICKS:
		queue_free()
		return
	position += _direction * (BASE_SPEED + shooter_move / 100.0)
	_ticks += 1


func _on_area_entered(area: Area2D) -> void:
	var hit := area as Tank
	if hit == null or _done or hit == shooter:
		return
	_done = true
	var damage := power
	if hit.team == team:
		@warning_ignore("integer_division")
		damage = power / 5          # friendly fire is weaker
	var to_hit := hit.position - position
	var hit_angle := int(-rad_to_deg(to_hit.angle()) * 1000.0) - hit.angle  # DIV: get_angle(hit)-hit.angle
	if hit_angle > -REAR_HIT_LIMIT and hit_angle < REAR_HIT_LIMIT:
		# DIV naming: hit from behind -> 5x damage and the AI tank backs off
		hit.life -= damage * 5
		Explosion.spawn(get_parent(), position, 20)
		hit.backstab = 50
	else:
		hit.life -= damage
	queue_free()
