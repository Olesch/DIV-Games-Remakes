class_name Fighter
extends Node2D
## One fighter (DIV: PROCESS Fighter). The original runs one big per-frame routine; here it is one
## `_step()` per physics tick (60 ticks/s, like set_fps(60)), split into small methods that are called
## in the original order. Positions, speeds and counters keep DIV's units (hundredths of a pixel per
## tick), because fighting-game balance depends on exact frame counts.
##
## Two characters share this script: "Template" (the Template and Chain graphics) and "Eigen"
## (extra moves and fireballs); per-character numbers come from FighterProfile.

@warning_ignore_start("integer_division")

const S := Defs.State
const AT := Defs.AttackType

@onready var sprite: Sprite2D = $Sprite2D

# --- setup -------------------------------------------------------------------------------------
var player_number: int = 1            # DIV: Spielernr
var is_cpu: bool = false              # DIV: Spielerart == 2
var recoloured: bool = false          # DIV: convert_palette on player 2's FPG
var profile: FighterProfile
var opponent: Fighter                 # DIV: Otherfighter_id
var locked: bool = false              # round over: buttons are ignored

# --- state (DIV units) ---------------------------------------------------------------------------
var x: int = 0
var y: int = Defs.FLOOR_Y
var facing: int = 1                   # DIV: Richtung (1 right, -1 left)
var flipped: bool = false             # DIV: flags=1 (mirror)
var state: int = S.STAND              # DIV: Position
var old_state: int = S.STAND          # DIV: OldPosition
var picture_number: int = 1
var graph: int = 1
var jump_speed: int = 0               # DIV: Jumpspeed (vertical, + = up)
var jump_speed_lr: int = 0            # DIV: Jumpspeedlr
var slz: int = 0                      # DIV: SLZ "SchlagLaehmZeit": stun, negative while stunned
var recovery_speed: int = 0           # DIV: ErhohlSpeed
var slz_wait_plus: int = 0            # DIV: SLZWaitPlus
var slz_time: int = 0                 # DIV: SLZTime (Eigen)
var fly_x: int = 0                    # DIV: xFlug
var fly_y: int = 0                    # DIV: yFlug
var life: int = Defs.START_LIFE       # DIV: Lifepoints
var damage: int = 0                   # DIV: Schaden (pending, applied after blocking)
var frame_var: int = 0                # DIV: FrameVar (ticks into the current move)
var punch_done: int = 0               # DIV: PunchWait (this move already hit)
var attack_type: int = 0              # DIV: AngriffsArt of the last incoming hit
var block_position: int = 0           # DIV: BlockPosition
var stance: int = 0                   # DIV: StehPosition
var mana: int = 0
var special_on: int = 0
var special_ratio: int = 0            # DIV: Spezialratio
var spark_x: int = 0                  # DIV: AttackAnimX/Y/Size/Graph (where to show the incoming hit)
var spark_y: int = 0
var spark_size: int = 0
var spark_graph: int = 0

# --- buttons (DIV: _Links_Knopf ...) -------------------------------------------------------------
var btn_left := false
var btn_right := false
var btn_up := false
var btn_down := false
var btn_light := false
var btn_heavy := false
var last_buttons: Array[int] = [0, 0, 0, 0, 0, 0]  # DIV: LB[1..5]: 1 down, 2 left, 3 right, 4 up
var clicked_wait: int = 0

var _ffp_light := false               # fast-fire prevention
var _ffp_heavy := false
var _ai := FighterAI.new()
var _actions: Dictionary = {}


func setup(number: int, character: int, cpu: bool, other_is_same_character: bool) -> void:
	player_number = number
	is_cpu = cpu
	profile = FighterProfile.make(character)
	# Both players the same character: player 2 gets the shifted palette (index + 16).
	recoloured = number == 2 and other_is_same_character
	x = Defs.START_X[number - 1]
	y = Defs.FLOOR_Y
	for action_name in ["left", "right", "up", "down", "light", "heavy"]:
		_actions[action_name] = StringName("p%d_%s" % [number, action_name])
	process_physics_priority = number - 1  # fighter 1 acts before fighter 2, like DIV's process order


func _ready() -> void:
	_sync_visuals()
	reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	# DIV: the end of the Fighter loop waits while Dontmove >= 1.
	if Game.hit_pause >= 1:
		return
	_step()
	_sync_visuals()


func _sync_visuals() -> void:
	position = Vector2(x, y) / 100.0
	var tex := Gfx.texture(profile.gfx_set, graph, recoloured)
	sprite.visible = tex != null  # a graphic missing from the FPG draws nothing, as in DIV
	if tex:
		sprite.texture = tex
		sprite.offset = -Gfx.cp0(profile.gfx_set, graph)
	var flip := -1.0 if flipped else 1.0
	if sprite.scale.x != flip:
		sprite.scale.x = flip
		sprite.reset_physics_interpolation()  # turn around at once, not squashed through zero width


# =================================================================================================
# One tick
# =================================================================================================

func _step() -> void:
	special_on = 0
	_read_buttons()
	_record_buttons()
	if old_state != state:
		picture_number = 1
	_shove_apart()
	_keep_inside_arena()
	block_position = 0

	if state == S.STAND:
		_state_stand()
	if state == S.WALK:
		_state_walk()
	if state == S.JUMP:
		_state_jump()
	if state == S.DUCK:
		_state_duck()

	_resolve_incoming_hit()
	_update_stun()

	if state == S.HIT:
		_state_hit()
	if state == S.FLY:
		_state_fly()
	if state == S.LIE:
		_state_lie()
	for attack_state: int in profile.attacks:
		if state == attack_state:
			_state_attack(attack_state)
	if state == S.SPECIAL_1:
		_state_special_1()
	if state == S.SPECIAL_2:
		_state_special_2()

	if special_on != 0:
		_special_afterimage()
	old_state = state
	if slz > 0:
		slz = 0
	_regenerate_mana()


# =================================================================================================
# Input
# =================================================================================================

func _read_buttons() -> void:
	btn_left = false
	btn_right = false
	btn_up = false
	btn_down = false
	btn_light = false
	btn_heavy = false
	if locked:
		return
	if is_cpu:
		_ai.press_buttons(self)
		return
	btn_up = Input.is_action_pressed(_actions["up"])
	btn_down = Input.is_action_pressed(_actions["down"])
	btn_left = Input.is_action_pressed(_actions["left"])
	btn_right = Input.is_action_pressed(_actions["right"])
	var light_down := Input.is_action_pressed(_actions["light"])
	var heavy_down := Input.is_action_pressed(_actions["heavy"])
	if light_down and not _ffp_light:
		btn_light = true
		_ffp_light = true
	if not light_down:
		_ffp_light = false
	if heavy_down and not _ffp_heavy:
		btn_heavy = true
		_ffp_heavy = true
	if not heavy_down:
		_ffp_heavy = false


## Remembers the last 5 distinct direction presses for the special-move motions.
func _record_buttons() -> void:
	_push_button(1, btn_down)
	_push_button(2, btn_left)
	_push_button(3, btn_right)
	_push_button(4, btn_up)
	clicked_wait -= 1
	if clicked_wait < 0:
		for i in range(1, 6):
			last_buttons[i] = 0


func _push_button(code: int, pressed: bool) -> void:
	if pressed and last_buttons[1] != code:
		clicked_wait = 10
		for i in range(5, 1, -1):
			last_buttons[i] = last_buttons[i - 1]
		last_buttons[1] = code


## DIV: LookForMove(). Motion as if facing right: 2 = back,down,forward; -2 = forward,down,back;
## 1 = down,forward; -1 = down,back; 0 = none. Multiply by `facing` for the real direction.
func _special_motion() -> int:
	var b := last_buttons
	if b[1] == 3 and b[2] == 1 and b[3] == 2:
		return 2
	if b[1] == 2 and b[2] == 1 and b[3] == 3:
		return -2
	if b[1] == 3 and b[2] == 1:
		return 1
	if b[1] == 2 and b[2] == 1:
		return -1
	return 0


# =================================================================================================
# Positioning
# =================================================================================================

func _face_opponent() -> void:
	if opponent.x > x:
		flipped = false
		facing = 1
	else:
		flipped = true
		facing = -1


## DIV: "Gegner schubsen": fighters standing too close push each other apart.
func _shove_apart() -> void:
	var dx := absi(x - opponent.x)
	var dy := absi(y - opponent.y)
	if dx < Defs.SHOVE_DISTANCE and dy < 4500:
		if opponent.x < x:
			x += Defs.SHOVE_DISTANCE - dx
		else:
			x -= Defs.SHOVE_DISTANCE - dx


## DIV: "Aus Bildschirm fliegen": the arena walls bounce jumping and flying fighters.
func _keep_inside_arena() -> void:
	if x > Defs.WALL_RIGHT:
		x = Defs.WALL_RIGHT - 1
		_bounce_off_wall()
	if x < 0:
		x = 1
		_bounce_off_wall()
	if y < 0:
		y = 1
		jump_speed = -jump_speed


func _bounce_off_wall() -> void:
	if state == S.JUMP or state == S.AIR_LIGHT or state == S.AIR_HEAVY:
		jump_speed_lr = -(jump_speed_lr + 10)
		jump_speed += 500
	if state == S.FLY:
		life -= absi(fly_x) / 5
		HitEffect.spawn(get_parent(), x, y, absi(fly_x) / 2, 4)
		fly_x = -(fly_x / 2)


func _jump_physics() -> void:
	y -= jump_speed
	x += jump_speed_lr
	jump_speed -= 100


# =================================================================================================
# Ground and air movement states
# =================================================================================================

func _state_stand() -> void:
	stance = Defs.Stance.MID
	_face_opponent()
	if btn_up:
		state = S.JUMP
		jump_speed = profile.jump_speed
	if btn_down:
		state = S.DUCK
	if btn_left:
		state = S.WALK
	if btn_right:
		state = S.WALK
	if btn_right and btn_left:
		state = S.STAND
	_ground_punch_buttons()
	graph = (picture_number + 15) / 15
	var cycle := 59 if profile.kind == FighterProfile.Kind.EIGEN else 29
	picture_number = (picture_number % cycle) + 1


func _state_walk() -> void:
	stance = Defs.Stance.MID
	state = S.STAND  # stops unless a direction is still held
	if btn_left:
		x -= profile.walk_speed
		state = S.WALK
		if opponent.x > x:
			block_position = 2  # walking away from the enemy = standing block
	if btn_right:
		x += profile.walk_speed
		state = S.WALK
		if opponent.x < x:
			block_position = 2
	if btn_right and btn_left:
		state = S.STAND
	if btn_up:
		state = S.JUMP
		jump_speed = profile.jump_speed
		if btn_left:
			jump_speed_lr = -profile.walk_jump_lr
		if btn_right:
			jump_speed_lr = profile.walk_jump_lr
	if btn_down:
		state = S.DUCK
	_ground_punch_buttons()
	graph = ((picture_number + 11) / 11) + (4 if profile.kind == FighterProfile.Kind.EIGEN else 1)
	picture_number = (picture_number % 21) + 1


## Light punch (also fires special 1) and strong punch (Eigen: also special 2) from the ground.
func _ground_punch_buttons() -> void:
	if btn_light:
		if _special_motion() * facing == profile.special1_dir and mana > 0:
			mana -= profile.special1_cost
			state = S.SPECIAL_1
			clicked_wait = -1
		else:
			state = S.LIGHT
	if btn_heavy:
		if _special_motion() * facing == profile.special2_dir and mana > 0:
			mana -= profile.special2_cost
			state = S.SPECIAL_2
			clicked_wait = -1
		else:
			state = S.HEAVY


func _state_jump() -> void:
	stance = Defs.Stance.HIGH
	var eigen := profile.kind == FighterProfile.Kind.EIGEN
	var boosting := false
	if eigen:
		_face_opponent()
		graph = 7
		if btn_up:
			if jump_speed > 700:
				jump_speed += 20
			elif mana > 0:
				# Eigen can hover: holding up past the apex burns mana for extra lift.
				jump_speed += 150
				mana -= 30
				boosting = true
				graph = 28
	elif btn_up:
		jump_speed += 20
	if btn_left:
		jump_speed_lr -= profile.air_steer
		if opponent.x > x:
			block_position = 3
	if btn_right:
		jump_speed_lr += profile.air_steer
		if opponent.x < x:
			block_position = 3
	if btn_light:
		state = S.AIR_LIGHT
	if btn_heavy:
		state = S.AIR_HEAVY
	_jump_physics()
	if y >= Defs.FLOOR_Y:
		y = Defs.FLOOR_Y
		state = S.STAND
		jump_speed_lr = 0
	if eigen:
		if boosting:
			graph = (picture_number / 11) + 28
		else:
			if jump_speed > 0:
				graph = 7
			if jump_speed < 0:
				graph = 8
		picture_number = (picture_number % 21) + 1
	else:
		graph = ((picture_number + 8) / 8) + 2
		picture_number = (picture_number % 15) + 1


func _state_duck() -> void:
	stance = Defs.Stance.LOW
	_face_opponent()
	if not btn_down:
		state = S.STAND
	if btn_left and opponent.x > x:
		block_position = 1
	if btn_right and opponent.x < x:
		block_position = 1
	if btn_light:
		state = S.DUCK_LIGHT
	if btn_heavy:
		state = S.DUCK_HEAVY
	graph = profile.graph_duck


# =================================================================================================
# Being hit: blocking, damage, stun (SLZ)
# =================================================================================================

func _clear_incoming_spark() -> void:
	spark_x = 0
	spark_y = 0
	spark_size = 0
	spark_graph = 0


func _show_incoming_spark() -> void:
	if spark_graph != 0:
		HitEffect.spawn(get_parent(), spark_x, spark_y, spark_size, spark_graph)
	_clear_incoming_spark()


## Full damage; the hit still stuns/launches (block of the wrong height, or no block).
func _take_unblocked_damage() -> void:
	life -= damage
	damage = 0
	_show_incoming_spark()
	attack_type = AT.NONE
	Game.hit_pause = Game.HIT_DONT_WAIT


## Correct block: 10% damage, no stun, no launch.
func _take_blocked_damage() -> void:
	slz = 0
	damage = damage / 10
	life -= damage
	damage = 0
	fly_x = 0
	fly_y = 0
	attack_type = AT.NONE
	_show_incoming_spark()
	Game.hit_pause = Game.HIT_DONT_WAIT


func _cancel_incoming_hit() -> void:
	slz = 0
	damage = 0
	fly_x = 0
	fly_y = 0
	attack_type = AT.NONE


## DIV: the block section between the movement states and the "being hit" states.
func _resolve_incoming_hit() -> void:
	# Lying fighters cannot be hit by standing/jumping attacks; ducking ones dodge standing attacks.
	if state == S.LIE:
		if attack_type == AT.MID or attack_type == AT.HIGH:
			_cancel_incoming_hit()
	if state == S.DUCK or state == S.DUCK_LIGHT or state == S.DUCK_HEAVY:
		if attack_type == AT.MID:
			_cancel_incoming_hit()

	if block_position != 0 and attack_type != 0:
		if block_position == 1:    # crouching block
			if attack_type == AT.LOW:
				_take_blocked_damage()
			elif attack_type == AT.MID:
				_cancel_incoming_hit()
				_clear_incoming_spark()
			elif attack_type == AT.HIGH:
				_take_unblocked_damage()
		else:                       # standing (2) or jumping (3) block
			if attack_type == AT.LOW:
				_take_unblocked_damage()
			elif attack_type == AT.MID or attack_type == AT.HIGH:
				_take_blocked_damage()

	# Whoever did not block gets the full hit.
	if damage != 0:
		_take_unblocked_damage()


func _update_stun() -> void:
	var eigen := profile.kind == FighterProfile.Kind.EIGEN
	if eigen and slz < 0:
		slz_time += 1
		if slz_time > 90:
			slz = 0
	if state == S.STAND or state == S.WALK or state == S.DUCK or state == S.HIT:
		if slz < 0:
			frame_var = 0
			state = S.HIT
			if slz < -500:
				frame_var = 0
				state = S.FLY
	if (state == S.JUMP or state == S.FLY) and slz < 0:
		frame_var = 0
		state = S.FLY
	if state == S.LIE and slz < 0:
		frame_var = 0
		state = S.LIE
	if slz < 0:
		if eigen:
			recovery_speed = -10
		else:
			# the longer the stun, the faster the recovery
			var fastest := -int(sqrt(absi(slz))) - 7
			if recovery_speed > fastest:
				recovery_speed = fastest
			slz_wait_plus += 1
			if slz_wait_plus == 40:
				recovery_speed -= 5
			if slz_wait_plus == 70:
				recovery_speed -= 5
			if slz_wait_plus == 90:
				recovery_speed -= 2
				slz_wait_plus = 70
	if slz > 0:
		slz = 0
	if slz == 0 and state != S.FLY and state != S.LIE:
		fly_x = 0
		fly_y = 0
	if slz == 0 and state != S.HIT and state != S.FLY and state != S.LIE:
		if eigen:
			if slz_time > 0:
				slz_time -= 3
			else:
				slz_time = 0
		if recovery_speed > 0:
			recovery_speed += 3
		else:
			recovery_speed = 0
		if slz_wait_plus > 0:
			slz_wait_plus -= 3
		else:
			slz_wait_plus = 0


func _state_hit() -> void:
	stance = Defs.Stance.MID
	fly_x = 0
	fly_y = 0
	slz -= recovery_speed
	if slz >= 0:
		if btn_up:
			state = S.JUMP
			jump_speed = profile.jump_speed
		if btn_down:
			state = S.DUCK
		if btn_left:
			state = S.WALK
		if btn_right:
			state = S.WALK
		if btn_left and btn_right:
			state = S.STAND
	if slz < -500:
		state = S.FLY
	graph = profile.graph_hit


func _state_fly() -> void:
	stance = Defs.Stance.HIGH
	slz -= recovery_speed / profile.fly_recovery_divisor
	if slz >= 0:
		# recovered in mid-air: get-up jumps
		if btn_up:
			state = S.JUMP
			jump_speed = profile.fly_up_jump
		if btn_left:
			state = S.JUMP
			jump_speed = profile.fly_side_jump
			jump_speed_lr = -profile.fly_side_lr
		if btn_right:
			state = S.JUMP
			jump_speed = profile.fly_side_jump
			jump_speed_lr = profile.fly_side_lr
	y -= fly_y
	x += fly_x
	fly_y -= 100
	if y >= Defs.FLOOR_Y:
		y = Defs.FLOOR_Y
		state = S.LIE
		fly_x = 0
		fly_y = 0
	graph = profile.graph_fly


func _state_lie() -> void:
	stance = Defs.Stance.LOW
	jump_speed = 0
	jump_speed_lr = 0
	slz -= recovery_speed * 5
	if fly_x != 0 or fly_y != 0:
		state = S.FLY
	if slz >= 0:
		if btn_up:
			state = S.JUMP
			jump_speed = 500
		if btn_left:
			state = S.JUMP
			jump_speed = 300
			jump_speed_lr = -300
		if btn_right:
			state = S.JUMP
			jump_speed = 300
			jump_speed_lr = 300
	graph = profile.graph_lie


# =================================================================================================
# Attacks
# =================================================================================================

func _state_attack(attack_state: int) -> void:
	var a: FighterProfile.Attack = profile.attacks[attack_state]
	var airborne := attack_state == S.AIR_LIGHT or attack_state == S.AIR_HEAVY
	var ducking := attack_state == S.DUCK_LIGHT or attack_state == S.DUCK_HEAVY
	var eigen := profile.kind == FighterProfile.Kind.EIGEN
	if airborne:
		stance = Defs.Stance.HIGH
	elif ducking:
		stance = Defs.Stance.LOW
	else:
		stance = Defs.Stance.MID

	frame_var += 1
	if frame_var > a.duration:
		state = S.JUMP if airborne else (S.DUCK if ducking else S.STAND)
		frame_var = 0
		punch_done = 0
	if airborne:
		_jump_physics()
		if y >= Defs.FLOOR_Y:
			y = Defs.FLOOR_Y
			jump_speed = 0
			jump_speed_lr = 0
			state = S.STAND
			frame_var = 0
			punch_done = 0
	if slz < 0:
		state = S.FLY if airborne else S.HIT
		frame_var = 0
		punch_done = 0

	if frame_var > a.hit_after and frame_var < a.hit_before and punch_done == 0:
		x += a.advance * facing
		var dx := absi((x + a.reach * facing) - opponent.x)
		var dy := absi((y + a.y_offset) - opponent.y)
		if dx < a.x_limit and dy < a.y_limit:
			x -= a.recoil * facing
			punch_done = 1
			_hit_opponent(a.slz, a.damage, a.fly_x * facing, a.fly_y, a.push * facing, a.type,
				x + a.spark_dx * facing, y + a.spark_dy, a.spark_size, a.spark_graph)
			if attack_state == S.AIR_HEAVY and not eigen:
				state = S.AIR_LIGHT  # Template: the air smash chains into the light air attack
				punch_done = 0
				frame_var = 10

	if eigen and attack_state == S.DUCK_LIGHT and frame_var == 10:
		x += 700 * facing  # slide
	if eigen and attack_state == S.DUCK_HEAVY and btn_up and punch_done == 1:
		# jump-cancel out of a landed uppercut
		state = S.JUMP
		jump_speed = 1200
		jump_speed_lr = 500 * facing
		frame_var = 0
		punch_done = 0

	if a.graph_base >= 0:
		graph = a.graph_base
	for rule: Array in a.graph_rules:
		if frame_var < rule[0]:
			graph = rule[1]


## Hands a hit to the opponent; it is resolved there (block/damage) in its own next step.
func _hit_opponent(stun: int, dmg: int, launch_x: int, launch_y: int, push: int, type: int,
		sx: int, sy: int, ssize: int, sgraph: int) -> void:
	opponent.receive_hit(stun, dmg, launch_x, launch_y, push, type, sx, sy, ssize, sgraph)


## Called by the attacker (or a fireball). `type` < 0 keeps the previous attack type.
func receive_hit(stun: int, dmg: int, launch_x: int, launch_y: int, push: int, type: int,
		sx: int, sy: int, ssize: int, sgraph: int) -> void:
	slz -= stun
	damage += dmg
	fly_x += launch_x
	fly_y += launch_y
	x += push
	if type >= 0:
		attack_type = type
	spark_x = sx
	spark_y = sy
	spark_size = ssize
	spark_graph = sgraph


# =================================================================================================
# Special moves
# =================================================================================================

func _state_special_1() -> void:
	if profile.kind == FighterProfile.Kind.EIGEN:
		_eigen_cast(31, 1)
		return
	# Template: down, back + light punch = charge, dash, then a flurry of blows
	stance = Defs.Stance.MID
	frame_var += 1
	if frame_var > 60:
		state = S.STAND
		frame_var = 0
		punch_done = 0
	if slz < 0:
		state = S.HIT
		frame_var = 0
		punch_done = 0
	if frame_var > 10 and frame_var < 20 and punch_done == 0:
		x += 500 * facing
		if absi((x + 2000 * facing) - opponent.x) < 3000 and absi(y - opponent.y) < 2500:
			frame_var = 20
			x -= 350 * facing
			punch_done = 1
			_hit_opponent(750, 200, 100 * facing, 800, 900 * facing, AT.MID,
				x + 2100 * facing, y, 150, 4)
	if frame_var > 20 and frame_var < 60:
		x += 500 * facing
		if absi((x + 2000 * facing) - opponent.x) < 3000 and absi(y - opponent.y) < 2500:
			x -= 550 * facing
			punch_done = 1
			Game.hit_pause = 4
			special_on = 1
			var finisher := frame_var > 55
			_hit_opponent(
				600 if finisher else 50,
				50 if finisher else randi_range(10, 20),
				0, 0,
				(2000 if finisher else 100) * facing,
				randi_range(1, 2),
				x + 3500 * facing + randi_range(-1500, 1500), y + randi_range(-3000, 3000), 75, 4)
			# the flurry assigns (not adds) the launch speed
			opponent.fly_x = (600 if finisher else 95) * facing
			opponent.fly_y = 900 if finisher else 100
	if frame_var == 1:
		Game.hit_pause = 20
		HitEffect.spawn(get_parent(), x, y, 150, 7, -7, 10)
	if frame_var > 0 and frame_var < 10:
		graph = 16
	if frame_var > 10 and frame_var < 20:
		graph = 17
		x += 700 * facing
	if frame_var > 20 and frame_var < 60:
		graph = [10, 11, 12, 14, 15, 17, 18][randi_range(0, 6)]


func _state_special_2() -> void:
	_eigen_cast(32, 2)


## Eigen's fireball moves: wind-up pose, then at tick 14 a Shot appears.
func _eigen_cast(cast_graph: int, kind: int) -> void:
	stance = Defs.Stance.MID
	frame_var += 1
	var total := 30 if kind == 1 else 70
	if frame_var > total:
		state = S.STAND
		frame_var = 0
		punch_done = 0
	if slz < 0:
		state = S.HIT
		frame_var = 0
		punch_done = 0
	if frame_var == 14:
		Shot.spawn(get_parent(), self, kind)
	if frame_var < total:
		graph = cast_graph
	if frame_var < 7:
		graph = 30


## DIV: SpezialAnim - a fading after-image trail while the flurry connects.
func _special_afterimage() -> void:
	if special_ratio > 0:
		special_ratio -= 1
	else:
		Afterimage.spawn(get_parent(), self)
		special_ratio = special_on


func _regenerate_mana() -> void:
	var gain := profile.mana_base + (Defs.START_LIFE - life) / profile.mana_life_divisor
	if mana < 0:
		gain = gain / 2
	if mana < Defs.MAX_MANA:
		mana += gain
	else:
		mana = Defs.MAX_MANA
