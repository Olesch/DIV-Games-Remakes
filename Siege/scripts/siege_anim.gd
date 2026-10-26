@warning_ignore_start("integer_division")
class_name SiegeAnim
extends Proc
## DIV PROCESS Animation(art, player): the "build" animations of archers, catapults, ballistas, mages,
## workers and the plague (group "animations"). They fire their shot / deal their damage in the middle of
## the animation. Durations are in frames (DIV FRAME(700) = 7 frames).
##   1 archer  2 catapult  3 ballista  4 mage  5 worker  6 plague

var art := 0
var player := 0

var _worker_time := 0
var _worker_target := Vector2i.ZERO
var _worker_moving := false


func begin() -> void:
	add_to_group(&"animations")
	x = 39 + player * 241 + randi_range(-6, 6)
	y = 221
	flags = player
	z = -5
	match art:
		Defs.AnimArt.BOGENSCHUETZE:
			play([
				[func() -> void: graph = 111, 7],
				[func() -> void: graph = 112, 2],
				[func() -> void:
					graph = 113
					world.spawn_shot(Defs.ShotArt.PFEIL, player, x, y), 4],
			])
		Defs.AnimArt.KATAPULT:
			play([
				[func() -> void: graph = 151, 15],
				[func() -> void: graph = 152, 2],
				[func() -> void: graph = 153, 2],
				[func() -> void:
					graph = 154
					world.spawn_shot(Defs.ShotArt.STEIN, player, x, y), 2],
				[func() -> void: graph = 155, 7],
			])
		Defs.AnimArt.BALLISTE:
			play([
				[func() -> void: graph = 161, 15],
				[func() -> void: graph = 161, 2],
				[func() -> void: graph = 162, 2],
				[func() -> void: graph = 163, 2],
				[func() -> void:
					graph = 164
					world.spawn_shot(Defs.ShotArt.BOLZEN, player, x, y), 7],
			])
		Defs.AnimArt.MAGIER:
			x = 60 + player * 199
			play([
				[func() -> void: graph = 201, 10],
				[func() -> void: graph = 201, 2],
				[func() -> void: graph = 202, 2],
				[func() -> void: graph = 203, 2],
				[func() -> void:
					graph = 204
					_mage_damage(), 2],
				[func() -> void: graph = 206, 2],
				[func() -> void: graph = 205, 2],
				[func() -> void: graph = 204, 2],
				[func() -> void: graph = 203, 2],
				[func() -> void: graph = 202, 7],
			])
		Defs.AnimArt.ARBEITER:
			graph = 211
			_worker_time = Defs.TIM_ARBEITER * 15
			Game.life[player] = mini(Game.life[player] + Defs.LP_ARBEITER, 100)
			_worker_pass_start()
		Defs.AnimArt.PEST:
			x = randi_range(120, 200)
			var steps: Array = []
			for g in range(251, 256):
				steps.append([func() -> void: graph = g, 1])
			steps.append([func() -> void:
				graph = 256
				_plague_damage(), 1])
			steps.append([func() -> void: graph = 257, 2])
			steps.append([func() -> void: graph = 258, 2])
			steps.append([func() -> void: graph = 259, 2])
			steps.append([func() -> void: graph = 260, 2])
			steps.append([func() -> void: graph = 261, 1])
			play(steps)


func _frame() -> void:
	if art == Defs.AnimArt.ARBEITER:
		_worker_frame()


func _mage_damage() -> void:
	# fget_dist(x,0,hit.x,0)<115: horizontal distance only, enemy ground units
	for hit: Unit in world.units():
		if absi(x - hit.x) < 115 and hit.player != player and hit.fly != 1:
			hit.lp -= Defs.DAM_MAGIER


func _plague_damage() -> void:
	# hurts every non-flying unit nearby (own ones too); an enemy killed by it spawns another plague
	for hit: Unit in world.units():
		if int(Vector2(x - hit.x, y - hit.y).length()) < Defs.EXP_PEST and hit.fly != 1:
			hit.lp -= Defs.DAM_PEST
			if hit.lp < 1 and hit.player != player:
				world.spawn_anim(Defs.AnimArt.PEST, player)


# ---- worker: repairs the castle at once, then runs around for TIM_ARBEITER*15 frames ----------------------
## Top of one pass of "FOR(time...)" up to its FRAME: a new run target every 15 passes.
func _worker_pass_start() -> void:
	if _worker_time % 15 == 0:
		graph = 215
		_worker_target = Vector2i(randi_range(10, 50) + 260 * player, randi_range(142, 221))
		_worker_moving = true
		_worker_run_step()
		if _worker_moving:
			return   # the blurred run takes frames, see _worker_frame
	_worker_idle_frame_setup()


func _worker_run_step() -> void:
	# WHILE(fget_dist(x,y,xpos,ypos)>10) angle=fget_angle(..); advance(15); FRAME; END
	var to := Vector2(_worker_target.x - x, _worker_target.y - y)
	if to.length() > 10.0:
		var a := atan2(-to.y, to.x)   # DIV ccw angle
		angle = int(rad_to_deg(a) * 1000.0)
		x += int(cos(a) * 15.0)
		y += int(-sin(a) * 15.0)
	else:
		x = _worker_target.x
		y = _worker_target.y
		graph = 210
		angle = 0
		_worker_moving = false


func _worker_idle_frame_setup() -> void:
	graph += 1
	if graph > 214:
		graph = 211


func _worker_frame() -> void:
	if _worker_moving:
		_worker_run_step()
		if _worker_moving:
			return
		_worker_idle_frame_setup()
		return
	_worker_time -= 1
	if _worker_time <= 0:
		finish()
		return
	_worker_pass_start()
