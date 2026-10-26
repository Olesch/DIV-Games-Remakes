class_name Ship
extends Area2D
## One player's ship (DIV process `ship`). Turn, thrust, and a charge-up shot with recoil.
## The game logic is counted in physics ticks: the project runs at 40 ticks/s = DIV set_fps(40),
## so one _physics_process call equals one DIV frame and all constants keep their original values.

signal life_changed(new_life: int)
signal died(ship: Ship)

const SHOT_SCENE := preload("res://scenes/shot.tscn")
const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")
const GFX := "res://assets/fpg/hatsch1/"
const SCREEN := Vector2(800, 600)

const START_LIFE := 100
const TURN_STEP := 4.0       # DIV: angle +-= 4000 (thousandths of a degree) per frame
const THRUST := 5.0          # DIV: advance(5) per frame
const SHOT_COOLDOWN := 5     # DIV: Antifastshot=5 (frames)
const MIN_POWER := 2
const DEATH_EXPLOSION_SIZE := 500  # DIV: Explosion(x,y,500) (percent)

## Prefix of the InputMap actions: p1_right, p1_left, p1_up, p1_fire ...
@export var action_prefix := "p1"
## DIV graphic code of the ship sprite (1 = Shipa, 2 = shipb).
@export var graphic := 1

var life: int = START_LIFE:
	set(value):
		life = value
		life_changed.emit(life)

var _charge := 0            # DIV: Power (frames the fire key was held, later /10)
var _cooldown := 0          # DIV: Antifastshot

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_sprite.texture = load("%s%d.png" % [GFX, graphic])
	add_to_group(&"ships")
	life_changed.emit(life)


func _physics_process(_delta: float) -> void:
	# DIV angle is counter-clockwise: "right" key = angle -= 4000 = clockwise on screen = +rotation
	if Input.is_action_pressed(_action("right")):
		rotation += deg_to_rad(TURN_STEP)
	if Input.is_action_pressed(_action("left")):
		rotation -= deg_to_rad(TURN_STEP)
	var forward := Vector2.from_angle(rotation)
	if Input.is_action_pressed(_action("up")):
		position += forward * THRUST

	var fire_held := Input.is_action_pressed(_action("fire"))
	if fire_held and _cooldown < 1:
		_charge += 1
	if not fire_held and _charge != 0:
		_charge = maxi(_charge / 10, MIN_POWER)
		_fire_shot(_charge)
		_cooldown = SHOT_COOLDOWN
		position -= forward * (_charge * 10)  # recoil: advance(-Power*10)
		reset_physics_interpolation()  # the recoil is a jump in the original, not a slide
		_charge = 0
	_cooldown -= 1

	_wrap()

	if life < 1:
		life = 0
		_explode()


func take_damage(amount: int) -> void:
	life -= amount


func _fire_shot(power: int) -> void:
	var shot := SHOT_SCENE.instantiate() as Shot
	shot.setup(position, rotation, self, power)
	get_parent().add_child(shot)


func _explode() -> void:
	var explosion := EXPLOSION_SCENE.instantiate() as Explosion
	explosion.setup(position, DEATH_EXPLOSION_SIZE)
	get_parent().add_child(explosion)
	died.emit(self)
	queue_free()


func _wrap() -> void:
	# Original quirk kept: leaving at 0 re-enters at 800 (strict comparisons, no ship-size margin).
	var wrapped := false
	if position.x < 0.0:
		position.x = SCREEN.x
		wrapped = true
	if position.y < 0.0:
		position.y = SCREEN.y
		wrapped = true
	if position.x > SCREEN.x:
		position.x = 0.0
		wrapped = true
	if position.y > SCREEN.y:
		position.y = 0.0
		wrapped = true
	if wrapped:
		reset_physics_interpolation()


func _action(suffix: String) -> StringName:
	return StringName("%s_%s" % [action_prefix, suffix])
