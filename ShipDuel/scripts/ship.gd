class_name Ship
extends Area2D
## DIV: PROCESS player(x, y, graph, angle, left, right, shoot, manashoot). A ship sits in its corner
## and only turns; it shoots along its heading. Runs one step per physics tick (= one DIV frame).

signal fired(weapon: Defs.Weapon, origin: Vector2, angle: int, owner_index: int)
signal died(owner_index: int)

const SHIELD_SCENE := preload("res://scenes/shield.tscn")

var player_index := 0           # 0..3 -> graphic 2..5, actions p1_..p4_
var angle := 0                  # 1/1000 degree, counter-clockwise (DIV: angle)
var lives := 0                  # DIV: Leben
var turn_rate := 0              # DIV: rotation - current turn speed, 1/1000 degree per frame
var _shot_wait := 0             # DIV: shotwait
var _clicked := false           # DIV: Clicked

var _left: StringName
var _right: StringName
var _shoot: StringName
var _mana: StringName

@onready var _sprite: Sprite2D = $Sprite2D


func setup(index: int, at: Vector2, start_angle: int) -> void:
	player_index = index
	position = at
	angle = start_angle
	var prefix := "p%d_" % (index + 1)
	_left = StringName(prefix + "left")
	_right = StringName(prefix + "right")
	_shoot = StringName(prefix + "shoot")
	_mana = StringName(prefix + "mana")


func _ready() -> void:
	var texture := Gfx.ship_tex(player_index)
	_sprite.texture = texture
	Shapes.add_alpha_polygons(self, texture)
	lives = Game.max_hits
	if Game.shield_mode == 1:
		add_child(SHIELD_SCENE.instantiate())
	rotation = Defs.to_rotation(angle)
	reset_physics_interpolation()  # face the centre at once, no spin from angle 0


func _physics_process(_delta: float) -> void:
	_check_hits()
	if lives < 0:
		Explosion.spawn(position, Game.ship_explosion_size)
		died.emit(player_index)
		queue_free()
		return
	_turn()
	_fire()
	_shot_wait -= 1


## DIV: collision(TYPE shot). With Eigenkilla = 0 a ship ignores its own shots (they shrink away) and
## takes one life for every foreign shot touching it; otherwise any one touching shot costs one life.
func _check_hits() -> void:
	var touching: Array[Shot] = []
	for area in get_overlapping_areas():
		var shot := area as Shot
		if shot and shot.fate == Shot.Fate.NONE and not shot.is_queued_for_deletion():
			touching.append(shot)
	if Game.own_shots_hit_ship == 0:
		for shot in touching:
			if shot.owner_index != player_index:
				lives -= 1
				shot.fate = Shot.Fate.EXPLODE
			else:
				shot.fate = Shot.Fate.FADE
	elif not touching.is_empty():
		lives -= 1
		touching[0].fate = Shot.Fate.EXPLODE


func _turn() -> void:
	if Input.is_action_pressed(_left):
		turn_rate += Game.turn_accel
	if Input.is_action_pressed(_right):
		turn_rate -= Game.turn_accel
	# DIV clamps with two IFs (not a clamp(): the settings may make the limits cross each other)
	if turn_rate >= Game.max_turn_speed:
		turn_rate = Game.max_turn_speed
	if turn_rate <= -Game.max_turn_speed:
		turn_rate = -Game.max_turn_speed
	angle += turn_rate
	# DIV: the brake can overshoot zero, which makes a nearly stopped ship jitter slightly - kept
	if turn_rate >= 1:
		turn_rate -= Game.auto_brake
	if turn_rate <= -1:
		turn_rate += Game.auto_brake
	rotation = Defs.to_rotation(angle)


## Firing exactly as in the original, including its quirk: `_clicked` is cleared by whichever of the
## two fire keys is not held, so with only one key held the ship always auto-fires and Fastfire makes
## no difference (it only matters when both keys are held together).
func _fire() -> void:
	if Input.is_action_pressed(_shoot):
		if _shot_wait < 1 and not _clicked:
			_shot_wait = Game.shot_delay
			if Game.fast_fire == 0:
				_clicked = true
			fired.emit(Defs.Weapon.SHOT, position, angle, player_index)
	else:
		_clicked = false

	if Input.is_action_pressed(_mana):
		if _shot_wait < 1 - Game.shot_delay * 3 - Defs.MANA_COOLDOWN_EXTRA and not _clicked:
			fired.emit(Defs.Weapon.EXPLOSHOT, position, angle, player_index)
			_shot_wait = Game.shot_delay
			if Game.fast_fire == 0:
				_clicked = true
	else:
		_clicked = false
