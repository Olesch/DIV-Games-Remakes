class_name FighterAI
extends RefCounted
## Computer opponent (DIV: "Die KI greift ein" inside the Template and Eigen blocks of Fighter).
## Every tick it decides which buttons the computer "presses" from the distance to the enemy and
## the enemy's state, using the same random odds per tick as the original.

var _wants_block := false  # DIV: KIToBlock


static func _roll(max_value: int) -> bool:
	return randi_range(0, max_value) == 0


func press_buttons(f: Fighter) -> void:
	var o := f.opponent
	var xd := absi(f.x - o.x)
	var yd := absi(f.y - o.y)
	if f.profile.kind == FighterProfile.Kind.EIGEN:
		_think_eigen(f, o, xd, yd)
	else:
		_think_template(f, o, xd, yd)


func _hold_block(f: Fighter) -> void:
	# Hold "away from the enemy".
	if f.facing == -1:
		f.btn_right = true
	if f.facing == 1:
		f.btn_left = true


func _walk_towards(f: Fighter) -> void:
	if f.facing == -1:
		f.btn_left = true
	if f.facing == 1:
		f.btn_right = true


func _enemy_ducking_or_lying(o: Fighter, xd: int, duck_odds: int, lie_odds: int) -> bool:
	return (o.state == Defs.State.DUCK and xd < 6000 and _roll(duck_odds)) \
		or (o.state == Defs.State.LIE and xd < 6000 and _roll(lie_odds))


func _think_template(f: Fighter, o: Fighter, xd: int, yd: int) -> void:
	var s := f.state
	if _roll(75):
		_wants_block = false
	if _roll(50):
		_wants_block = true
	if _wants_block and s >= Defs.State.STAND and s <= Defs.State.DUCK:
		_hold_block(f)

	if s == Defs.State.STAND:
		if f.mana > 500 and _roll(150) and o.state == Defs.State.HIT and xd < 18000 and yd < 4000:
			# fire the special: down, back + light punch
			f.clicked_wait = 10
			f.last_buttons[2] = 1
			f.last_buttons[1] = 2 if f.facing == 1 else 3
			f.btn_light = true
		if xd < 7000 and yd < 3000 and _roll(12):
			f.btn_light = true
		if xd < 10000 and yd < 3000 and _roll(18):
			f.btn_heavy = true
		if xd > 4000 and not _wants_block:
			_walk_towards(f)
		if (yd > 8000 and _roll(30)) or _roll(80):
			f.btn_up = true
		if _roll(300) or _enemy_ducking_or_lying(o, xd, 24, 10):
			f.btn_down = true
	if s == Defs.State.WALK:
		if xd > 4000 and not _wants_block:
			_walk_towards(f)
		if (yd > 8000 and _roll(30)) or _roll(80):
			f.btn_up = true
		if _roll(300) or _enemy_ducking_or_lying(o, xd, 24, 10):
			f.btn_down = true
	if s == Defs.State.JUMP:
		if yd > 1000 and _roll(10):
			f.btn_up = true
		if xd > 3000 and not _wants_block:
			_walk_towards(f)
		if xd < 14000 and yd < 16000 and _roll(10):
			f.btn_light = true
		if xd < 19000 and yd < 16000 and _roll(15):
			f.btn_heavy = true
	if s == Defs.State.DUCK:
		f.btn_down = true
		if _roll(300) or (xd > 5000 and _roll(60)) or (o.state == Defs.State.JUMP and _roll(30)):
			f.btn_down = false
		if xd < 10000 and yd < 4000 and _roll(10):
			f.btn_light = true
		if xd < 16000 and yd < 4000 and _roll(15):
			f.btn_heavy = true
	if s >= Defs.State.HIT and s <= Defs.State.LIE:
		_recover_moves(f)


func _recover_moves(f: Fighter) -> void:
	if f.slz >= 0:
		if _roll(20):
			if f.facing == 1:
				f.btn_right = true
			if f.facing == -1:
				f.btn_left = true
		if _roll(30):
			f.btn_up = true
		if _roll(40):
			if f.facing == 1:
				f.btn_left = true
			if f.facing == -1:
				f.btn_right = true


func _eigen_fireball_motion(f: Fighter) -> void:
	# LB[1] is the newest press: forward... DIV stores 3 = right, 2 = left, 1 = down.
	if f.facing == 1:
		f.last_buttons[1] = 3
		f.last_buttons[2] = 1
		f.last_buttons[3] = 2
	if f.facing == -1:
		f.last_buttons[1] = 2
		f.last_buttons[2] = 1
		f.last_buttons[3] = 3
	f.btn_heavy = true


func _think_eigen(f: Fighter, o: Fighter, xd: int, yd: int) -> void:
	var s := f.state
	if _roll(20):
		_wants_block = false
	if _roll(150):
		_wants_block = true
	if _wants_block and s >= Defs.State.STAND and s <= Defs.State.DUCK:
		_hold_block(f)

	if s == Defs.State.STAND:
		if xd > 5000 and f.mana == Defs.MAX_MANA:
			_eigen_fireball_motion(f)
		if f.mana > 1000 and _roll(10) and xd < 14000 and yd < 4000:
			f.clicked_wait = 10
			f.last_buttons[2] = 1
			f.last_buttons[1] = 3 if f.facing == 1 else 2
			f.btn_light = true
		if xd < 7000 and yd < 3000 and _roll(3):
			f.btn_light = true
		if xd < 10000 and yd < 3000 and _roll(2):
			f.btn_heavy = true
		if xd > 4000 and not _wants_block:
			_walk_towards(f)
		if (yd > 8000 and _roll(6)) or _roll(12):
			f.btn_up = true
		if _roll(200) or _enemy_ducking_or_lying(o, xd, 15, 6):
			f.btn_down = true
	if s == Defs.State.WALK:
		if xd > 20000 and f.mana > 4500 and _roll(50):
			_eigen_fireball_motion(f)
		if xd > 5000 and f.mana == Defs.MAX_MANA:
			_eigen_fireball_motion(f)
		if xd > 4000 and not _wants_block:
			_walk_towards(f)
		if (yd > 8000 and _roll(30)) or _roll(80):
			f.btn_up = true
		if _roll(200) or _enemy_ducking_or_lying(o, xd, 15, 6):
			f.btn_down = true
	if s == Defs.State.JUMP:
		if yd > 1000:
			if f.jump_speed < 700:
				if f.mana > 3000:
					f.btn_up = true
			else:
				f.btn_up = true
		if xd > 3000 and not _wants_block:
			_walk_towards(f)
		if xd < 14000 and yd < 16000 and _roll(3):
			f.btn_light = true
		if xd < 19000 and yd < 16000 and _roll(2):
			f.btn_heavy = true
	if s == Defs.State.DUCK:
		f.btn_down = true
		if _roll(300) or (xd > 6000 and _roll(60)) or (o.state == Defs.State.JUMP and _roll(30)):
			f.btn_down = false
		if xd < 7000 and yd < 4000 and _roll(2):
			f.btn_light = true
		if xd < 8000 and yd < 4000 and _roll(1):
			f.btn_heavy = true
	if s >= Defs.State.HIT and s <= Defs.State.LIE:
		_recover_moves(f)
	if s == Defs.State.DUCK_HEAVY and f.punch_done == 1 and _roll(1):
		f.btn_up = true
