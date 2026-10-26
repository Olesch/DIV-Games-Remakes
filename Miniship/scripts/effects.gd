class_name Effects
extends Node2D
## All short-lived eye candy in one node: particles (DIV Particeleffect), laser trail dots (Laserspec),
## shield circles (shieldspec) and teleport rings (telspecout/telspecin).
## Each of those was a one-sprite DIV process; here they are plain data drawn in _draw().
## Runs before every other node in a tick so that effects spawned in tick N live exactly through frame N.

# particles (positions/velocities in 1/100 px)
var _pp := PackedVector2Array()
var _pv := PackedVector2Array()
# specs: {code, pos, rot, size (percent), step, left}
var _specs: Array[Dictionary] = []


func _ready() -> void:
	process_physics_priority = -100   # process_priority would only order _process
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	z_index = 5


func _physics_process(_delta: float) -> void:
	# specs
	var i := _specs.size() - 1
	while i >= 0:
		var s := _specs[i]
		s["left"] -= 1
		s["size"] += s["step"]
		if s["left"] <= 0:
			_specs.remove_at(i)
		i -= 1
	# particles: x += xinc each frame; every frame a 1/7 chance to die
	i = _pp.size() - 1
	while i >= 0:
		_pp[i] += _pv[i]
		if randi_range(0, 6) == 0:
			_remove_particle(i)
		i -= 1
	queue_redraw()


## DIV Particeleffect(x, y, count, power). x,y in 1/100 px.
func particles(x: int, y: int, count: int, power: int) -> void:
	var amount := Game.particles
	if amount == 0:
		return
	if amount == 1:
		if count == 0:
			if randi_range(0, 1) == 0:
				return
		else:
			count -= 1
	if count > 0:
		particles(x, y, count - 1, power)      # the original spawns a chain of child processes
	if amount == 2:
		power = (power * 4) / 3
	var a := randi_range(-180000, 180000)
	var v := randi_range(0, power)
	var vel := Vector2(DivMath.dist_x(a, v), DivMath.dist_y(a, v))
	var pos := Vector2(x, y) + vel               # the new process already moves once before its first FRAME
	if randi_range(0, 6) == 0:
		return
	_pp.append(pos)
	_pv.append(vel)


## One-frame sprite (laser dot, shield circle). Pixel position, size in percent.
func spec(code: int, x: int, y: int, rot: float = 0.0, size_percent := 100) -> void:
	_specs.append({"code": code, "pos": Vector2(x, y), "rot": rot, "size": size_percent, "step": 0, "left": 1})


## Teleport ring leaving (grows 100 -> 148) / arriving (shrinks 150 -> 102), one step per frame.
func teleport_out(x: int, y: int) -> void:
	_specs.append({"code": Gfx.SHIELD, "pos": Vector2(x, y), "rot": 0.0, "size": 100, "step": 3, "left": 17})


func teleport_in(x: int, y: int) -> void:
	_specs.append({"code": Gfx.SHIELD, "pos": Vector2(x, y), "rot": 0.0, "size": 150, "step": -3, "left": 17})


func clear() -> void:
	_pp.clear()
	_pv.clear()
	_specs.clear()
	queue_redraw()


func particle_count() -> int:
	return _pp.size()


func _remove_particle(i: int) -> void:
	var last := _pp.size() - 1
	_pp[i] = _pp[last]
	_pv[i] = _pv[last]
	_pp.resize(last)
	_pv.resize(last)


func _draw() -> void:
	var dot := Gfx.tex(Gfx.PARTICLE)
	for p in _pp:
		draw_texture(dot, Vector2(int(p.x / 100.0), int(p.y / 100.0)))
	for s in _specs:
		var code: int = s["code"]
		var scale_f: float = s["size"] / 100.0
		draw_set_transform(s["pos"], s["rot"], Vector2(scale_f, scale_f))
		draw_texture(Gfx.tex(code), -Gfx.CP0[code])
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
