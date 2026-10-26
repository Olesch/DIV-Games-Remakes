@warning_ignore_start("integer_division")
class_name Unit
extends Proc
## DIV PROCESS Unit(art, player): everything that fights on the battlefield (group "units").
## Each DIV frame = [rest of the previous loop pass ("post")] + [top of the loop ("pre")], see _frame().
## Players: 0 = left castle (walks right), 1 = right castle (walks left, graphics mirrored via flags).

var art := 0
var player := 0
var lp := 0                 # DIV LP: life points
var fly := 0                # flying units do not fight (and are not hit by airship/dragon shots)
var big := 0                # big units can be hit by arrows, stones, bolts ...
var hitsize := 0            # radius of "projectile hits me"
var movefreq := 0
var res := 0                # shot timer
var mensch := 0             # "human": raises a skeleton when it dies next to a casting necromancer
var from_x := 0             # DIV father.x / father.y (only the skeleton uses them)
var from_y := 0

var _started := false
var _dir := 1               # DIV (1-player*2)


func begin() -> void:
	add_to_group(&"units")
	_dir = 1 - player * 2
	x = 49 + player * 221
	y = 221
	flags = player
	movefreq = randi_range(0, 4)
	match art:
		Defs.UnitArt.KRIEGER:
			mensch = 1
			graph = 101
			lp = Defs.LP_KRIEGER
		Defs.UnitArt.RAMME:
			mensch = 1
			graph = 131
			lp = Defs.LP_RAMME
		Defs.UnitArt.BOMBER:
			mensch = 1
			graph = 141
			lp = 1
		Defs.UnitArt.RANKEN:
			z = 5
			graph = 171
			lp = Defs.LP_RANKEN
			x = 80 + player * 159
			big = 1
			hitsize = 24
		Defs.UnitArt.RITTER:
			mensch = 1
			graph = 181
			lp = Defs.LP_RITTER
		Defs.UnitArt.WOLKE:
			z = -5
			graph = 191
			lp = Defs.LP_WOLKE
			x = 126 + player * 67
			y = 165
			fly = 1
			big = 1
			hitsize = 30
			size = 0
		Defs.UnitArt.ELEFANT:
			mensch = 1
			graph = 221
			lp = Defs.LP_ELEFANT
			big = 1
			hitsize = 24
		Defs.UnitArt.TURM:
			mensch = 1
			z = 5
			graph = 231
			lp = Defs.LP_TURM
			big = 1
			hitsize = 24
			x = 110 + player * 99
		Defs.UnitArt.LUFTSCHIFF:
			graph = 271
			lp = Defs.LP_LUFTSCHIFF
			fly = 1
			big = 1
			hitsize = 24
			y = 160
		Defs.UnitArt.GOLEM:
			graph = 281
			lp = Defs.LP_GOLEM
			big = 1
			hitsize = 30
		Defs.UnitArt.DRACHE:
			graph = 291
			lp = Defs.LP_DRACHE
			fly = 1
			big = 1
			hitsize = 24
			y = 160
		Defs.UnitArt.TOTENBESCHWOERER:
			graph = 301
			lp = Defs.LP_TOTENBESCHWOERER
		Defs.UnitArt.SKELETT:
			x = from_x
			y = from_y
			mensch = 0
			graph = 311
			lp = Defs.LP_SKELETT
	# the DIV process runs up to its first FRAME right away
	_pre()
	_started = true


func _frame() -> void:
	if not _started:
		return
	if not _post():
		return
	_pre()


# ---- start of the LOOP: movement, fighting, shooting -------------------------------------------------
func _pre() -> void:
	match art:
		Defs.UnitArt.KRIEGER, Defs.UnitArt.RAMME, Defs.UnitArt.BOMBER, Defs.UnitArt.ELEFANT, \
		Defs.UnitArt.SKELETT:
			if movefreq == 0:
				_step_forward()
			_fight()
		Defs.UnitArt.RITTER:
			if movefreq == 0:
				x += _dir * (1 + (randi_range(0, Defs.SPD_RITTER) / (Defs.SPD_RITTER - 1)))
			_fight()
		Defs.UnitArt.GOLEM:
			if (graph == 282 or graph == 284) and movefreq == 0:
				_step_forward()
			_fight()
		Defs.UnitArt.TOTENBESCHWOERER:
			# walks to x<105 (player 0) / x>214 (player 1), then stands and conjures
			if movefreq == 0 and _necro_walking():
				_step_forward()
			_fight()
		Defs.UnitArt.RANKEN:
			_fight()
		Defs.UnitArt.TURM:
			# the tower dies when an enemy ground unit gets close
			for hit: Unit in world.units():
				if _dist_to(hit) < 8 and hit.fly != 1 and player != hit.player:
					lp = 0
					break
		Defs.UnitArt.LUFTSCHIFF:
			res += 1
			if res > Defs.TIM_LUFTSCHIFF and ((player == 0 and x > 120) or (player == 1 and x < 200)):
				res = 0
				world.spawn_shot(Defs.ShotArt.LUFTSCHIFF, player, x, y)
		Defs.UnitArt.DRACHE:
			if movefreq == 0 or movefreq == Defs.SPD_DRACHE / 2:
				_step_forward()


# ---- after the FRAME: castle hit, death, animation -----------------------------------------------------
## Returns false when the unit died (the process ended).
func _post() -> bool:
	var reaches_castle := (player == 0 and x > 259) or (player == 1 and x < 60)
	match art:
		Defs.UnitArt.KRIEGER, Defs.UnitArt.RAMME, Defs.UnitArt.BOMBER, Defs.UnitArt.RITTER, \
		Defs.UnitArt.ELEFANT, Defs.UnitArt.LUFTSCHIFF, Defs.UnitArt.GOLEM, Defs.UnitArt.DRACHE, \
		Defs.UnitArt.TOTENBESCHWOERER:
			if reaches_castle:
				_hit_castle()
		Defs.UnitArt.SKELETT:
			if reaches_castle:
				lp = 0   # skeletons vanish at the castle without hurting it

	if art == Defs.UnitArt.BOMBER:
		# special case bomber: dead or in the middle of the field -> blow up
		if lp <= 0 or (player == 0 and x > 160) or (player == 1 and x < 160):
			world.spawn_explosion(3, player, x, y)
			_die()
			return false
	elif lp <= 0:
		_die()
		return false

	match art:
		Defs.UnitArt.KRIEGER:
			_animate(Defs.SPD_KRIEGER, 101, 104)
		Defs.UnitArt.RAMME:
			_animate(Defs.SPD_RAMME, 131, 134)
		Defs.UnitArt.BOMBER:
			_animate(Defs.SPD_BOMBER, 141, 144)
		Defs.UnitArt.RANKEN:
			movefreq += 1
			if movefreq > 1:
				movefreq = 0
				graph += 1
				if graph > 176:
					graph = 176
		Defs.UnitArt.RITTER:
			_animate(0, 181, 186)   # SPD 0: graph changes every frame
		Defs.UnitArt.WOLKE:
			movefreq += 1
			if size < 100:
				size += 10
			if movefreq > 2:
				movefreq = 0
				var g := randi_range(0, 10)
				graph = g + 192 if g < 3 else 191
		Defs.UnitArt.ELEFANT:
			_animate(Defs.SPD_ELEFANT, 221, 224)
		Defs.UnitArt.TURM:
			movefreq += 1
			if movefreq > Defs.TIM_TURM:
				movefreq = 0
				world.spawn_shot(Defs.ShotArt.TURMPFEIL, player, x, y)
		Defs.UnitArt.LUFTSCHIFF:
			graph += 1
			if graph > 274:
				graph = 271
			movefreq += 1
			if movefreq > Defs.SPD_LUFTSCHIFF:
				movefreq = 0
				x += _dir
		Defs.UnitArt.GOLEM:
			_animate(Defs.SPD_GOLEM, 281, 284)
		Defs.UnitArt.DRACHE:
			res += 1
			if res > Defs.TIM_DRACHE and ((player == 0 and x > 100) or (player == 1 and x < 220)):
				res = 0
				world.spawn_shot(Defs.ShotArt.DRACHE, player, x, y)
			_animate(Defs.SPD_DRACHE, 291, 294)
		Defs.UnitArt.TOTENBESCHWOERER:
			movefreq += 1
			if movefreq > Defs.SPD_TOTENBESCHWOERER:
				movefreq = 0
				graph += 1
				if _necro_walking():
					if graph > 304:
						graph = 301
				elif graph > 308:
					graph = 305
		Defs.UnitArt.SKELETT:
			_animate(Defs.SPD_SKELETT, 311, 314)
	return true


func _animate(speed: int, first: int, last: int) -> void:
	movefreq += 1
	if movefreq > speed:
		movefreq = 0
		graph += 1
		if graph > last:
			graph = first


func _step_forward() -> void:
	x += _dir * (1 + randi_range(0, 1))


func _necro_walking() -> bool:
	return (player == 0 and x < 105) or (player == 1 and x > 214)


func _dist_to(other: Unit) -> int:
	return int(Vector2(x - other.x, y - other.y).length())


## Fight against enemy ground units within 8 pixels: both lose 1 life point per hit
## (every unit of a pair does this in its own turn, so a pair trades 2 points per frame).
func _fight() -> void:
	for hit: Unit in world.units():
		if _dist_to(hit) < 8:
			if hit.lp > 0 and lp > 0 and fly != 1 and hit.fly != 1 and player != hit.player:
				hit.lp -= 1
				lp -= 1


func _hit_castle() -> void:
	# DIV: life[1-player] -= sqrt(LP*4); LP = 0   (sqrt of a negative number: treated as 0)
	Game.life[1 - player] -= int(sqrt(maxf(0.0, lp * 4.0)))
	lp = 0


func _die() -> void:
	remove_from_group(&"units")
	alive = false
	# blood on the battlefield
	world.spawn_explosion(0, player, x, y)
	# a dying "human" next to a casting necromancer is raised as a skeleton
	if mensch == 1:
		world.raise_skeleton(player, x, y, art)
	finish()
