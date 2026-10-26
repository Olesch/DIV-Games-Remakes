class_name Lemming
extends Node2D
## One lemming (DIV: element of STRUCT Lomming[99], simulated by the Lomminger process).
## The original encodes state and animation phase in one number `action`; here `state` is the activity and
## `step` the position inside its animation cycle (step = action - first action of the state), so all
## frame-count based triggers (dig every 10th step, ladder every 17th, ...) behave as in the original.
## The logic is stepped once per DIV frame by the Level (24 ticks/s).

enum State { IDLE, WALK, FALL, CLIMB, JUMP, BUILD, DIG_FRONT, DIG_DIAGONAL, DIG_DOWN, STOP, DEAD, SAVED }

const GONE_CELL := Vector2i(-5000, -5000)
## DIV: Jumpy[] / Jumpx[] (per jump step)
const JUMP_Y: Array[int] = [-2, -2, -2, -2, -2, -2, -1, -1, -1, -1, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2]
const JUMP_X: Array[int] = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0]

var state := State.IDLE
var step := 0                   # DIV: action - base of the state
var dir := 0                    # DIV: dir (1 right, -1 left)
var cell := Vector2i.ZERO       # DIV: x, y (feet position, control point of the sprites)
var fallen := 0                 # DIV: Fallen (fall height; also ladder pieces / dig marker)
var has_umbrella := false       # DIV: Umbrella
var can_climb := false          # DIV: Climb
var can_jump := false           # DIV: Jump (jump when about to fall)
var countdown := 0              # DIV: Explode (0 = not exploding, 1..117)

var terrain: Terrain
var crowd: Array[Lemming]       # all lemmings of the level (for the stopper)
var exit_cell := Vector2i.ZERO

@onready var body: Sprite2D = $Body
@onready var digit: Sprite2D = $Digit


func _ready() -> void:
	hide()


func setup(level_terrain: Terrain, all_lemmings: Array[Lemming], exit_pos: Vector2i) -> void:
	terrain = level_terrain
	crowd = all_lemmings
	exit_cell = exit_pos


## DIV: the entrance spawns a lemming: Action=1, dir=1 at control point 1.
func spawn(at: Vector2i) -> void:
	cell = at
	dir = 1
	_enter(State.WALK)


func is_working() -> bool:
	# DIV: action > 63 and action < 142 (ladder and the three digs)
	return state in [State.BUILD, State.DIG_FRONT, State.DIG_DIAGONAL, State.DIG_DOWN]


## Player commands; they set the state directly like the original's cursor code did.
func command_state(new_state: State) -> void:
	_enter(new_state)


func tick() -> void:
	match state:
		State.WALK:
			_tick_walk()
		State.FALL:
			_tick_fall()
		State.CLIMB:
			_tick_climb()
		State.JUMP:
			_tick_jump()
		State.BUILD:
			_tick_build()
		State.DIG_FRONT:
			_tick_dig_front()
		State.DIG_DIAGONAL:
			_tick_dig_diagonal()
		State.DIG_DOWN:
			_tick_dig_down()
		State.STOP:
			_tick_stop()
		State.DEAD, State.SAVED:
			cell = GONE_CELL
			body.hide()
	_tick_explosion()
	# DIV: fget_dist(Exitx,Exity,x,y) < 15 -> Action=5001 (in exit)
	if Vector2(cell - exit_cell).length_squared() < Defs.EXIT_RADIUS * Defs.EXIT_RADIUS:
		state = State.SAVED


func _enter(new_state: State) -> void:
	state = new_state
	step = 0


func _air(dx: int, dy: int) -> bool:
	return terrain.is_air(cell.x + dx, cell.y + dy)


## DIV: map_xput(0,1,graph,x,y,0,100,(dir-1)/-2) - sprite drawn at the position before this tick's move,
## mirrored when walking left.
func _show(graphic: int) -> void:
	body.texture = Gfx.tex(graphic)
	body.offset = -Vector2(Gfx.cp0(graphic))
	body.scale.x = -1.0 if dir == -1 else 1.0
	position = Vector2(cell)
	body.show()
	show()


func _tick_walk() -> void:
	_show(100 if step < 7 else 101)  # Action1/2: Movea / Moveb
	step = (step + 1) % 14
	if _air(dir, 0):
		# nothing in front: look downwards for ground (up to 5 px, else fall / jump)
		for b in range(1, 6):
			if not _air(dir, b):
				cell.x += dir
				cell.y += b - 1
				break
			elif b == 5:
				if can_jump:
					_enter(State.JUMP)
				else:
					_enter(State.FALL)
					cell.x += dir
	else:
		# obstacle: try to step up (up to 4 px), else climb or turn around
		for b in range(-1, -5, -1):
			if _air(dir, b):
				cell.x += dir
				cell.y += b
				break
			elif b == -4:
				if can_climb:
					_enter(State.CLIMB)
				else:
					dir = -dir
	if cell.y >= Defs.DEATH_Y:
		state = State.DEAD


func _tick_fall() -> void:
	fallen = 0 if step == 0 else fallen + 1
	if has_umbrella:
		fallen = 0
	var offset := 4 if has_umbrella else 0  # graphics 106/107 = umbrella
	_show(102 + offset if step < 6 else 103 + offset)
	step += 1
	if step > 11:
		step = 1
	# with umbrella the lemming only sinks every second tick
	if not has_umbrella or step % 2 == 0:
		if _air(0, 1):
			cell.y += 1
		elif fallen > Defs.DEATH_FALL_HEIGHT:
			state = State.DEAD
		else:
			_enter(State.WALK)


func _tick_climb() -> void:
	_show(104 if step < 7 else 105)  # Hanglea / Hangleb
	step += 1
	if step > 13:
		step = 0
	if step % 2 == 0:
		if _air(dir, -1):
			cell.y -= 1
			cell.x += dir
			_enter(State.WALK)
		elif _air(0, -1):
			cell.y -= 1
		else:
			_enter(State.FALL)
			dir = -dir


func _tick_jump() -> void:
	_show(102 if step < 12 else 103)
	step += 1
	var jump_x := JUMP_X[step] * dir
	var jump_y := JUMP_Y[step]
	if _air(jump_x, jump_y):
		cell.y += jump_y
		cell.x += jump_x
	else:
		for b in range(-1, -5, -1):
			if _air(dir, b):
				cell.x += dir
				cell.y += b + 1
				_enter(State.WALK)
				break
			elif b == -4:
				if can_climb:
					_enter(State.CLIMB)
				else:
					dir = -dir
					_enter(State.FALL)
	if state == State.JUMP and step > 20:
		_enter(State.FALL)


func _tick_build() -> void:
	# `fallen` counts the ladder pieces built (the original reuses the fall counter)
	if step == 0:
		fallen = 0
	if fallen >= Defs.LADDER_PIECES_MAX:
		fallen += 1
		_show(110)  # "No more ladder left"
	else:
		_show(108 if step < 9 else 109)
	step += 1
	if step > 17:
		step = 1
	if step == 1 and fallen <= Defs.LADDER_PIECES_MAX:
		fallen += 1
		if _air(dir * 2, -1):
			terrain.stamp(80, cell.x + 2 * dir, cell.y)  # Ladderpiece
			cell.x += dir * 2
			cell.y -= 1
		else:
			_enter(State.WALK)
			dir = -dir
	if fallen >= 50:
		_enter(State.WALK)


func _tick_dig_front() -> void:
	if fallen != 16:
		cell.x += dir * 3
	fallen = 16  # "for easier working the mouse" (marks digging for the cursor rules)
	_show(111 if step < 10 else 112)
	step += 1
	if step > 19:
		step = 0
	if not _air(dir * 3, 0) and (step == 1 or step == 11):
		cell.x += dir * 2
		terrain.stamp(81, cell.x, cell.y)
	elif _air(dir * 3, 0):
		_enter(State.WALK)


func _tick_dig_diagonal() -> void:
	fallen = 17
	_show(113 if step < 10 else 114)
	step += 1
	if step > 19:
		step = 0
	if not _air(dir * 2, 1) and step == 10:
		cell.x += dir * 2
		cell.y += 1
		terrain.stamp(81, cell.x, cell.y)
	elif _air(dir * 2, 1):
		_enter(State.WALK)


func _tick_dig_down() -> void:
	fallen = 17
	_show(115 if step < 10 else 116)
	step += 1
	if step > 19:
		step = 0
	if not _air(0, 1) and (step == 0 or step == 10):
		cell.y += 1
		terrain.stamp(82, cell.x, cell.y)
	elif _air(0, 1):
		_enter(State.WALK)


func _tick_stop() -> void:
	_show(117 if step < 10 else 118)
	step += 1
	if step > 19:
		step = 0
	# turn all lemmings that bump into the blocker (within 4 px, same height)
	for other in crowd:
		if absi(other.cell.y - cell.y) < 5:
			var dist := other.cell.x - cell.x
			if other.dir == 1 and dist < 0 and dist > -5:
				other.dir = -1
			if other.dir == -1 and dist > 0 and dist < 5:
				other.dir = 1
	if _air(0, 1):
		_enter(State.WALK)


func _tick_explosion() -> void:
	if countdown > 0:
		countdown += 1
		digit.texture = Gfx.tex(90 + countdown / 24)  # digits 5,4,3,2,1 (graphics 90-94)
		digit.position = Vector2(cell) - position + Vector2(0, -17)  # centred 6x8 graphic at (x, y-17)
		digit.show()
		show()
	else:
		digit.hide()
	if countdown > Defs.EXPLODE_TICKS:
		state = State.DEAD
		countdown = 0
		digit.hide()
		terrain.stamp(83, cell.x, cell.y)  # explosion crater
