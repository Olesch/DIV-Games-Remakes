class_name Ship
extends SpaceBody
## One player's ship (DIV process Ship). Human (keys) or computer controlled (PC Easy .. King).
## One physics tick (30 Hz) = one DIV frame. Velocity xinc/yinc: position += inc/10 (1/100 px) per frame.

const SHOT_SCENE := preload("res://scenes/shot.tscn")
const ROCKET_SCENE := preload("res://scenes/rocket.tscn")

const SPEEDUP := 100          # thrust added to xinc/yinc per frame
const TURN := 11250           # pi/16 per frame = 337.5 deg/s
const AI_TURN_AWAY := 5625    # pi/32
const AI_MAX_SPEED := 9500    # AI stops thrusting along its heading above this speed
const START := [
	[60000, 45000, 90000],
	[20000, 15000, -90000],
	[60000, 15000, 180000],
	[20000, 45000, 0],
]

var player := 0
var energy := 0
var angle := 0                # thousandths of a degree, counter-clockwise
var portwait := 0             # frames since both turn keys were released (double tap = teleport)
var antifast_shot := 0        # DIV Antifastshot
var antifast_rocket := 0
var load_wait := 0
var intelligence := 0         # 0 Easy .. 3 King
var _jumped := false          # teleported this tick (no interpolation)

# computer control decisions of this frame (DIV KIvor/KIrechts/KIlinks/KIschuss)
var ai_thrust := false
var ai_right := false
var ai_left := false
var ai_fire := false

var _a_thrust: StringName
var _a_right: StringName
var _a_left: StringName
var _a_fire: StringName

@onready var sprite: Sprite2D = $Sprite2D


func setup(player_index: int) -> void:
	player = player_index
	energy = Game.max_energy
	px = START[player][0]
	py = START[player][1]
	angle = START[player][2]
	intelligence = Game.ship_mode[player] - 2
	radius = 9.0
	_a_thrust = StringName("p%d_thrust" % player)
	_a_right = StringName("p%d_right" % player)
	_a_left = StringName("p%d_left" % player)
	_a_fire = StringName("p%d_fire" % player)
	Game.ships[player] = self


func _ready() -> void:
	Gfx.apply(sprite, Gfx.SHIP_BASE + player)
	sprite.centered = true
	sprite.offset = Vector2.ZERO
	add_to_group(&"ships")
	add_to_group(&"gravity_bodies")
	add_to_group(&"round_entities")
	Game.effects.particles(px, py, 15, 800)
	_update_view(true)


func _exit_tree() -> void:
	if Game.ships[player] == self:
		Game.ships[player] = null


## The round is over (DIV `newstart==1`): burst and vanish.
func end_round() -> void:
	Game.effects.particles(px, py, 15, 800)
	queue_free()


func _physics_process(_delta: float) -> void:
	if Game.ship_mode[player] >= 2:
		_think()

	# energy regeneration
	load_wait += 1
	match Game.load_type:
		1:
			if load_wait > 3:
				energy += 1
				load_wait = 0
		2:
			if load_wait > 1:
				energy += 1
				load_wait = 0
		3:
			energy += 1
		4:
			energy += 3
	energy = mini(energy, Game.max_energy)
	if energy < 0:
		_die()
		return

	px += xinc / 10
	py += yinc / 10

	var key_right := Input.is_action_pressed(_a_right)
	var key_left := Input.is_action_pressed(_a_left)
	var key_fire := Input.is_action_pressed(_a_fire)
	var fx := Game.effects

	if (Input.is_action_pressed(_a_thrust) or ai_thrust) and energy > 1:
		fx.particles(px, py, 1, 100)
		xinc += DivMath.dist_x(angle, SPEEDUP)
		yinc += DivMath.dist_y(angle, SPEEDUP)
		energy -= 1
	var teleported := false
	if key_right:
		angle = DivMath.norm_angle(angle - TURN)
	if key_left:
		angle = DivMath.norm_angle(angle + TURN)
	# turn both keys again 2..8 frames after releasing them = teleport (costs 50)
	if key_right and key_left and portwait < 18 and portwait > 10 and energy > 50 and Game.play_type != 1:
		_teleport()
		teleported = true

	# both turn keys held = shield (costs 3 per frame)
	if (key_right or ai_right) and (key_left or ai_left) and energy > 3 and Game.play_type != 1:
		fx.particles(px, py, 1, 800)
		shielded = true
		energy -= 3
		fx.spec(Gfx.SHIELD, px / 100, py / 100)
		portwait = 20
	else:
		shielded = false
	portwait -= 1

	if wrap_world():
		teleported = true

	# shooting
	if (key_fire or ai_fire) and antifast_shot < 1:
		if (key_right or ai_right) and (key_left or ai_left) and Game.play_type != 1:
			if energy > 25 and antifast_rocket == 0:
				_fire_rocket()
				energy -= 25
				antifast_rocket = 1
		else:
			var stats: Array = Game.LASER_STATS[Game.laser_type]
			if energy > stats[0]:
				_fire_shot()
				energy -= stats[1]
		antifast_shot = 3
		if Game.laser_type == 5:
			antifast_shot = 70
	if not key_fire:
		if Game.laser_type != 5:
			antifast_shot = 0
		antifast_rocket = 0
	if Game.laser_type == 1 or Game.laser_type == 4:
		antifast_shot = 0
	if Game.laser_type == 3 or Game.laser_type == 5:
		antifast_shot -= 1

	# collision with other ships
	for other in Game.alive_ships():
		if other != self and overlaps(other):
			fx.particles(px, py, 5, 500)
			bump(other, true)
			other.place()
	changed -= 1

	_update_view(teleported or _jumped)
	_jumped = false


func _update_view(teleported: bool) -> void:
	rotation = -deg_to_rad(angle / 1000.0)
	place(teleported)


func _teleport() -> void:
	var fx := Game.effects
	fx.particles(px, py, 8, 100)
	energy -= 50
	fx.teleport_out(px / 100, py / 100)
	xinc = 0
	yinc = 0
	px = randi_range(0, Game.WORLD_W)
	py = randi_range(0, Game.WORLD_H)
	fx.particles(px, py, 8, 100)
	fx.teleport_in(px / 100, py / 100)
	_jumped = true


func _die() -> void:
	Game.effects.particles(px, py, 15, 800)
	if Game.play_type == 2:
		Game.add_points(player, -1)
		var carrier := Game.follow
		# DIV: everyone but the dying ship's own carrier-ship collects +3 for the flag holder
		if is_instance_valid(carrier) and carrier.player != player:
			Game.add_points(carrier.player, 3)
	queue_free()


func _fire_shot() -> void:
	var shot := SHOT_SCENE.instantiate() as Shot
	shot.setup(px, py, angle)
	Game.entities.add_child(shot)
	shot.launch()


func _fire_rocket() -> void:
	var rocket := ROCKET_SCENE.instantiate() as Rocket
	rocket.setup(px, py, angle, xinc, yinc)
	Game.entities.add_child(rocket)
	rocket.launch()


## Computer opponent (DIV KI block). Easy..King only changes how often it shoots.
func _think() -> void:
	ai_thrust = false
	ai_right = false
	ai_left = false
	ai_fire = false
	var target: SpaceBody = null
	if Game.play_type == 2 and Game.follow != self:
		if is_instance_valid(Game.follow):
			target = Game.follow
		else:
			target = Game.flag
	if target == null:
		for c in Game.alive_ships():
			if c != self and get_dist(c) != 0:
				if target == null or get_dist(c) < get_dist(target):
					target = c

	if target != null:
		var to_target := get_angle(target)
		var to_planet := get_angle(Game.planet)
		if to_target < to_planet + 7000 and to_target > to_planet - 7000:
			# target is behind the planet: fly away from the planet instead
			angle = DivMath.near_angle(angle, to_planet + 180000, AI_TURN_AWAY)
		else:
			angle = DivMath.near_angle(angle, to_target, TURN)

	# Original bug kept: fget_angle(x, xinc, y, yinc) mixes position and velocity components,
	# so this nearly always decides to thrust.
	var drift := DivMath.angle_between(px, xinc, py, yinc)
	if drift < angle + 7000 and drift > angle - 7000:
		var movement := DivMath.isqrt(xinc * xinc + yinc * yinc)
		if movement < AI_MAX_SPEED:
			ai_thrust = true
	else:
		ai_thrust = true

	if target != null and target != Game.flag:
		if get_dist(target) < 26000:
			if not target.shielded:
				if randi_range(0, (3 - intelligence) * 5 + 1) == 0:
					ai_fire = true
			else:
				# target shields: shield too (shield + fire = rocket)
				ai_right = true
				ai_left = true
				if randi_range(0, (3 - intelligence) * 5 + 5) == 0:
					ai_fire = true

	var near_planet := get_dist(Game.planet) < Game.planet.size_percent * 55
	if energy > 50 and Game.play_type != 1 and (near_planet or randi_range(0, 1000) == 0):
		_teleport()
