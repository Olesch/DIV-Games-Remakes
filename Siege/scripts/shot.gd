class_name Shot
extends Proc
## DIV PROCESS Shot(art, player): projectiles. The loop body runs once per frame, starting in the frame
## the shot is created. Hits are decided with get_dist() against the unit's hitsize (big units only),
## no collision shapes were used in the original either.
##   1 arrow (archer)  2 stone (catapult)  3 bolt (ballista)  4 arrow (tower)  5 meteor
##   6 airship bomb    7 dragon shot

var art := 0
var player := 0
var from_x := 0     # DIV father.x
var from_y := 0     # DIV father.y

var _vel_x := 0
var _vel_y := 0
var _old_x := 0
var _old_y := 0
var _dir := 1
var _landed := false
var _ground_explosions := 0     # explosions still to produce after landing (stone, dragon shot)
var _ground_art := 0
var _spin := 0                  # angle += _spin each frame (stone, meteor)


func begin() -> void:
	_dir = 1 - player * 2
	x = from_x
	y = from_y - 1
	_old_x = x
	_old_y = y
	match art:
		Defs.ShotArt.PFEIL:
			graph = 116
			_vel_x = 6 * _dir + randi_range(-1, 1)
			_vel_y = -13 + randi_range(-1, 1)
		Defs.ShotArt.STEIN:
			graph = 156
			y -= 13
			_vel_x = 6 * _dir + randi_range(-1, 1)
			_vel_y = -13 + randi_range(-1, 1)
			angle = 0
			size = 125
			_spin = 18345
		Defs.ShotArt.BOLZEN:
			graph = 165
			y -= 5
			_vel_x = 14 * _dir
			_vel_y = -3
			angle = 0
			size = 100
		Defs.ShotArt.TURMPFEIL:
			graph = 116
			_vel_x = (4 + randi_range(0, 1)) * _dir
			_vel_y = 0
			y -= 27
		Defs.ShotArt.METEOR:
			graph = 156
			y = 120
			_vel_x = randi_range(-3, 3)
			_vel_y = 2
			angle = 0
			size = 125
			_spin = 18345
		Defs.ShotArt.LUFTSCHIFF:
			graph = 275
			y = from_y + 5
			x = from_x + 6 * _dir
			_vel_y = -1
			angle = 0
			size = 100
		Defs.ShotArt.DRACHE:
			graph = 156
			y = from_y + 5
			x = from_x + 8 * _dir
			_vel_y = -1
			_vel_x = 2 * _dir
			angle = 0
			size = 150
	_move_and_hit()


func _frame() -> void:
	if _landed:
		# stone / dragon shot lie on the ground and produce their blasts one per frame
		world.spawn_explosion(_ground_art, player, x, y)
		_ground_explosions -= 1
		if _ground_explosions <= 0:
			finish()
		return
	_move_and_hit()


func _move_and_hit() -> void:
	_old_x = x
	_old_y = y
	x += _vel_x
	y += _vel_y
	_vel_y += 1
	if _spin != 0:
		angle += _spin
	elif art == Defs.ShotArt.PFEIL or art == Defs.ShotArt.BOLZEN or art == Defs.ShotArt.TURMPFEIL:
		# fget_angle(oldx, oldy, x, y): flight direction (the graphic faces right)
		rotation = atan2(y - _old_y, x - _old_x)
		angle = int(-rad_to_deg(rotation) * 1000.0)

	for hit: Unit in world.units():
		var d := int(Vector2(x - hit.x, y - hit.y).length())
		match art:
			Defs.ShotArt.PFEIL, Defs.ShotArt.STEIN, Defs.ShotArt.TURMPFEIL, Defs.ShotArt.METEOR:
				if d < hit.hitsize and hit.big == 1 and hit.lp > 0 and player != hit.player:
					hit.lp -= _direct_damage()
					world.spawn_explosion(2, player, x, y)
					finish()
					return
			Defs.ShotArt.BOLZEN:
				if ((d < hit.hitsize and hit.big == 1) or d < 12) and hit.lp > 0 and player != hit.player:
					y = 222
					world.spawn_explosion(5, player, x, y)
					x += Defs.EXP_BALLISTE
					world.spawn_explosion(5, player, x, y)
					finish()
					return
			Defs.ShotArt.LUFTSCHIFF:
				if d < hit.hitsize and hit.big == 1 and hit.lp > 0 and player != hit.player and hit.fly != 1:
					hit.lp -= Defs.DAM_LUFTSCHIFF
					world.spawn_explosion(2, player, x, y)
					finish()
					return
			Defs.ShotArt.DRACHE:
				if d < hit.hitsize and hit.big == 1 and hit.lp > 0 and player != hit.player and hit.fly != 1:
					hit.lp -= Defs.DAM_DRACHE * Defs.PAR_DRACHE
					world.spawn_explosion(2, player, x, y)
					y += 3
					x += 5
					world.spawn_explosion(2, player, x, y)
					x -= 9
					y += 3
					world.spawn_explosion(2, player, x, y)
					finish()
					return

	# hits the ground
	if y > 222:
		y = 222
		match art:
			Defs.ShotArt.PFEIL:
				world.spawn_explosion(1, player, x, y)
				finish()
			Defs.ShotArt.STEIN:
				_land(4, Defs.PAR_KATAPULT)
			Defs.ShotArt.BOLZEN:
				world.spawn_explosion(5, player, x, y)
				x += Defs.EXP_BALLISTE
				world.spawn_explosion(5, player, x, y)
				finish()
			Defs.ShotArt.TURMPFEIL:
				world.spawn_explosion(6, player, x, y)
				finish()
			Defs.ShotArt.METEOR:
				world.spawn_explosion(7, player, x, y)
				finish()
			Defs.ShotArt.LUFTSCHIFF:
				world.spawn_explosion(8, player, x, y)
				finish()
			Defs.ShotArt.DRACHE:
				_land(9, Defs.PAR_DRACHE)


func _direct_damage() -> int:
	match art:
		Defs.ShotArt.PFEIL: return Defs.DAM_PFEIL
		Defs.ShotArt.STEIN: return Defs.DAM_KATAPULT * Defs.PAR_KATAPULT
		Defs.ShotArt.TURMPFEIL: return Defs.DAM_TURM
		_: return Defs.DAM_METEOR


func _land(explosion_art: int, count: int) -> void:
	_landed = true
	_ground_art = explosion_art
	_ground_explosions = count
