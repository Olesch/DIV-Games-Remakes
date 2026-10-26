class_name Hero
extends Node2D
## DIV: PROCESS Hero(...). One DIV frame = one physics tick (project ticks = 24/s), so the integer
## movement (3 px/frame walking, 2 diagonal, +1 running) and the tile/distance tests are kept as they were.

const DEATH_WAIT_TICKS := 24       # DIV: FRAME(2400)
const DEATH_ANIM_TICKS := 190      # DIV: FOR(Size=100; Size<2000; Size+=10)
const TRANSITION_TICKS := 2        # DIV: FRAME(200) when walking into the next room

signal died

var ix: int = 30                   # DIV: x, y (pixels in the 800x600 room)
var iy: int = 30
var weap: int = 0                  # 0 sword, 1 bow, 2 magic
var hit_damage: int = 0            # DIV: Hit_Damage (written by shots / enemies)
var graph: int = 4
var dir: int = 0                   # 0 up, 1 right, 2 down, 3 left
var movement: int = 0              # walk-cycle counter (Movement)

## Held state of the movement keys, maintained from input events (no polling).
const HELD_ACTIONS: Array[StringName] = [&"hero_up", &"hero_down", &"hero_left", &"hero_right",
	&"hero_run", &"hero_save_mod", &"hero_cheat_alt"]
var _held: Dictionary = {}
## One-shot requests (the original debounced these with AnFaSho): at most one is served per frame.
var _want_weapon: bool = false
var _want_magic: bool = false
var _want_attack: bool = false

var _transition_wait: int = 0
var _transition_delta: int = 0
var _transition_axis: int = 0
var _dying: bool = false
var _death_tick: int = 0

@onready var _sprite: Sprite2D = $Sprite


func setup(px: int, py: int) -> void:
	ix = px
	iy = py


func _ready() -> void:
	_show_graph(graph)
	position = Vector2(ix, iy)


func _unhandled_input(event: InputEvent) -> void:
	for a in HELD_ACTIONS:
		if event.is_action_pressed(a):
			_held[a] = true
		elif event.is_action_released(a):
			_held[a] = false
	if event.is_action_pressed(&"hero_weapon", false, true):
		_want_weapon = true
	if event.is_action_pressed(&"hero_magic", false, true):
		_want_magic = true
	if event.is_action_pressed(&"hero_attack", false, true):
		_want_attack = true


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_held.clear()


func _down(action: StringName) -> bool:
	return _held.get(action, false)


func _show_graph(g: int) -> void:
	if g != graph or _sprite.texture == null:
		graph = g
		Gfx.apply(_sprite, g)


func _physics_process(_delta: float) -> void:
	if _dying:
		_death_step()
		return
	if _transition_wait > 0:
		_transition_wait -= 1
		if _transition_wait == 0:
			_finish_transition()
		position = Vector2(ix, iy)
		return
	_tick()
	position = Vector2(ix, iy)


func _tick() -> void:
	var st := Game.stat
	var world: World = Game.world
	st.condition += 1

	var xinc := 0
	var yinc := 0
	if _down(&"hero_up"):
		movement += 1
		dir = 0
		yinc -= 3
	if _down(&"hero_right"):
		movement += 1
		dir = 1
		xinc += 3
	if _down(&"hero_down"):
		movement += 1
		dir = 2
		yinc += 3
	if _down(&"hero_left"):
		movement += 1
		dir = 3
		xinc -= 3

	# diagonal walking is slower per axis
	if xinc > 0 and yinc > 0:
		xinc = 2
		yinc = 2
		movement -= 1
	if xinc < 0 and yinc > 0:
		xinc = -2
		yinc = 2
		movement -= 1
	if xinc > 0 and yinc < 0:
		xinc = 2
		yinc = -2
		movement -= 1
	if xinc < 0 and yinc < 0:
		xinc = -2
		yinc = -2
		movement -= 1

	if _down(&"hero_run") and st.condition > 2:
		if xinc > 0:
			xinc += 1
		if xinc < 0:
			xinc -= 1
		if yinc > 0:
			yinc += 1
		if yinc < 0:
			yinc -= 1
		st.condition -= 2

	if movement > 20:
		movement = 1
	if movement < 0:
		movement += 1
	if movement == 0:
		movement = randi_range(1, 20)

	if movement > -5 and movement < 1:
		_show_graph(dir * 10 + 4)
	if movement > 0 and movement < 6:
		_show_graph(dir * 10 + 1)
	if movement > 5 and movement < 11:
		_show_graph(dir * 10 + 2)
	if movement > 10 and movement < 16:
		_show_graph(dir * 10 + 1)
	if movement > 15 and movement < 21:
		_show_graph(dir * 10 + 3)

	# slime slows down
	if Game.terrain_at(ix, iy) == Game.T_SLIME:
		xinc = signi(xinc)
		yinc = signi(yinc)

	var old_x := ix
	var old_y := iy
	ix += xinc
	_resolve_move(true, old_x, world)
	iy += yinc
	_resolve_move(false, old_y, world)

	_handle_weapons(st)

	if hit_damage != 0:
		hit_damage -= st.defense
		if hit_damage < 1:
			hit_damage = 1
		st.life -= hit_damage
		hit_damage = 0

	if st.life < 1:
		_begin_death()
		return
	if st.life > st.max_life:
		st.life = st.max_life
	if st.mana > st.max_mana:
		st.mana = st.max_mana
	if st.condition > st.max_condition:
		st.condition = st.max_condition
	if st.exp > 50 * st.level:
		st.exp -= 50 * st.level
		st.max_life += st.strength / st.level * 2 + 1
		st.max_mana += st.magic / st.level / 2 + 1
		st.max_condition += st.bow / st.level + 1
		st.life += st.strength / st.level * 2 + 1
		st.mana += st.magic / st.level / 2 + 1
		st.condition += st.bow / st.level + 1
		st.level += 1

	# walking off the room: next room (stage +1 / -1 / +6 / -6)
	if ix > 790:
		_start_transition(1, 0)
	elif ix < 10:
		_start_transition(-1, 0)
	elif iy > 590:
		_start_transition(6, 1)
	elif iy < 10:
		_start_transition(-6, 1)


## Collision of one axis step: special tiles under the hero, walls, doors, other creatures.
func _resolve_move(is_x: bool, old: int, world: World) -> void:
	var st := Game.stat
	var t := Game.terrain_at(ix, iy)
	var gx := ix / Game.TILE
	var gy := iy / Game.TILE
	if t == Game.T_TRAP_TRIGGER:
		_switch_trapdoors(Game.T_TRAP_OPEN, Game.T_TRAP_SHUT, 130, gx, gy, world)
	if t == Game.T_TRAP_OPENER:
		_switch_trapdoors(Game.T_TRAP_SHUT, Game.T_TRAP_OPEN, 101, gx, gy, world)
	if t == Game.T_SILVER_DOOR and st.silver_keys > 0:
		st.silver_keys -= 1
		Game.set_cell(0, gx, gy, Game.T_FLOOR)
		world.put_tile(101, gx, gy)
	if t == Game.T_GOLD_DOOR and st.gold_keys > 0:
		st.gold_keys -= 1
		Game.set_cell(0, gx, gy, Game.T_FLOOR)
		world.put_tile(101, gx, gy)
	# `t` is deliberately the value from before the door was opened: the step that opens a door
	# is still blocked (DIV kept using the old Nomove).
	# DIV: ...OR Nomove==212 AND NOT(key(_alt) AND key(_control)) - Alt+Ctrl lets you walk through shut trapdoors.
	var cheat := _down(&"hero_cheat_alt") and _down(&"hero_save_mod")
	var blocked := t == Game.T_WALL or t == Game.T_LOOPHOLE or t == Game.T_THIN_LOOPHOLE \
		or t == Game.T_SILVER_DOOR or t == Game.T_GOLD_DOOR or (t == Game.T_TRAP_SHUT and not cheat)
	if not blocked:
		for e: Enemy in get_tree().get_nodes_in_group(&"enemies"):
			var d := Gfx.idist(ix, iy, e.ix, e.iy)
			if d < 10 and d != 0:
				blocked = true
				break
	if blocked:
		if is_x:
			ix = old
		else:
			iy = old


## DIV: the 5x5 loop around the hero that opens/closes trapdoors.
func _switch_trapdoors(from_code: int, to_code: int, tile_code: int, gx: int, gy: int, world: World) -> void:
	for cx in range(-2, 3):
		for cy in range(-2, 3):
			var nx := gx + cx
			var ny := gy + cy
			if nx >= 0 and nx <= 39 and ny >= 0 and ny <= 29:
				if Game.cell(0, nx, ny) == from_code:
					Game.set_cell(0, nx, ny, to_code)
					world.put_tile(tile_code, nx, ny)


func _handle_weapons(st: HeroStats) -> void:
	var world: World = Game.world
	var served := false
	if _want_weapon:
		weap = (weap + 1) % 3
		if weap == 2 and st.chosen_magic == 0:
			weap = 0
		served = true

	if st.chosen_magic == 0:
		if st.heal_learned > 0:
			st.chosen_magic = 3
		if st.ice_learned > 0:
			st.chosen_magic = 2
		if st.flame_learned > 0:
			st.chosen_magic = 1

	if _want_magic and not served:
		st.chosen_magic += 1
		if st.chosen_magic >= 4:
			st.chosen_magic = 1
		if st.chosen_magic == 1 and st.flame_learned == 0:
			st.chosen_magic += 1
		if st.chosen_magic == 2 and st.ice_learned == 0:
			st.chosen_magic += 1
		if st.chosen_magic == 3 and st.heal_learned == 0:
			st.chosen_magic = 1
		served = true

	if _want_attack and not served:
		if weap == 0 and st.condition > 10:
			world.spawn_shot(ix, iy, dir, st.strength, 2, 41, 0)
			movement = -4
			st.condition -= 10
		if weap == 1 and st.arrows > 0 and st.condition > 5:
			world.spawn_shot(ix, iy, dir, st.bow, 200, 42, 0)
			st.arrows -= 1
			st.condition -= 7
		if weap == 2:
			if st.chosen_magic == 1 and st.mana > 0:
				world.spawn_shot(ix, iy, dir, st.magic + st.flame_learned * 7, 200, 46, 0)
				st.mana -= 1
			if st.chosen_magic == 2 and st.mana > 2:
				for d in 8:
					world.spawn_shot(ix, iy, d, (st.magic / 2) + st.ice_learned * 4, 200, 48, 0)
				st.mana -= 3
			if st.chosen_magic == 3 and st.mana > 0:
				st.mana -= 1
				st.life += st.heal_learned
	_want_weapon = false
	_want_magic = false
	_want_attack = false


func _start_transition(stage_delta: int, axis: int) -> void:
	# DIV: Otherlevel=1; FRAME(200): every room entity ends, then the new room is drawn
	Game.world.clear_room_entities()
	_transition_wait = TRANSITION_TICKS
	_transition_delta = stage_delta
	_transition_axis = axis


func _finish_transition() -> void:
	var target := Game.stage + _transition_delta
	if target < 0 or target >= Game.ROOMS:
		# not in the original (it would index outside Map); stay in the room instead
		if _transition_axis == 0:
			ix = clampi(ix, 12, 788)
		else:
			iy = clampi(iy, 12, 588)
		Game.world.draw_room()
		return
	Game.stage = target
	Game.world.draw_room()
	match _transition_delta:
		1:
			ix = 30
		-1:
			ix = 770
		6:
			iy = 30
		-6:
			iy = 570


# ----------------------------------------------------------------- death

func _begin_death() -> void:
	# DIV: let_me_alone(); FRAME(2400); growing, spinning hero with blood; exit("Bye",0)
	_dying = true
	_death_tick = 0
	Game.world.begin_death()
	died.emit()


func _death_step() -> void:
	if _death_tick >= DEATH_WAIT_TICKS:
		var k := _death_tick - DEATH_WAIT_TICKS
		if k >= DEATH_ANIM_TICKS:
			Game.to_title()
			return
		var size_pct := 100 + 10 * k
		scale = Vector2.ONE * (size_pct / 100.0)
		rotation = -deg_to_rad(15.0 * k)
		Game.world.spawn_blood(ix, iy, randi_range(-180000, 180000), size_pct)
	_death_tick += 1
