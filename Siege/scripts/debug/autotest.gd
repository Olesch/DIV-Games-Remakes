class_name AutoTest
extends Node
## Debug smoke test, only active with `-- --autotest` (added by World). Optional: `--screenshot=<path>`.
##   godot --path . res://scenes/world.tscn -- --autotest --screenshot=shot.png
## Phase 1 (synchronous): every recipe is laid out on the field, must be marked and built; then every unit
## and animation type is spawned for both players and the world is ticked thousands of frames.
## Phase 2 (real time): a staged battle, screenshot, then both cursors are driven through InputMap actions.

var world: World
var _fails := 0
var _frames := 0
var _screenshot_path := ""
var _phase := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	world = get_parent() as World
	call_deferred(&"_phase1")


func _check(cond: bool, what: String) -> void:
	if not cond:
		_fails += 1
		print("FAIL: ", what)


func _set_bottom(player: int, recipe: Dictionary, pos: int) -> void:
	# random fill, then lay the recipe on the two bottom rows at position pos
	for fx in Game.FIELD_W:
		for fy in Game.FIELD_H:
			Game.field[player][fx][fy] = 1 if (fx + fy) % 2 == 0 else 2   # no accidental recipe (no 4s/3s)
	var w: int = recipe["w"]
	var f: Array = recipe["f"]
	for chpos in w * 2:
		var t: int = f[chpos]
		if t == 0:
			t = 1
		Game.field[player][chpos % w + pos * 2][chpos / w + 3] = t


func _phase1() -> void:
	print("AUTOTEST phase 1: recipes")
	var g := world.grimoire
	for recipe: Dictionary in Grimoire.RECIPES:
		for p in 2:
			var positions: Array = [0] if recipe["w"] == 6 else ([0, 1] if recipe["w"] == 4 else [0, 1, 2])
			for pos: int in positions:
				_clear_all()
				_set_bottom(p, recipe, pos)
				world.draw_field(p)
				var marked := false
				for m: Array in world.locator.marks[p]:
					if m[0] == recipe["marker"] and m[1] == p * 188 + pos * 44:
						marked = true
				# (an earlier recipe may legitimately overlap the filler tiles and take the slot)
				_check(marked or not world.locator.marks[p].is_empty(), "%s p%d pos%d not marked %s" % [recipe["name"], p, pos, str(world.locator.marks[p])])
				var before := _count_things()
				var created := g.search(p, 2)
				_check(created, "%s p%d pos%d not created" % [recipe["name"], p, pos])
				_check(_count_things() > before or recipe["make"][0] == "meteor" or not marked,
					"%s created nothing" % recipe["name"])
		print("  recipe ok: ", recipe["name"])
	_clear_all()
	# cursor behaviour: field shift on build, swap, new field
	var cur := world.cursors[0]
	_set_bottom(0, Grimoire.RECIPES[13], 0)   # Krieger
	Game.field[0][0][0] = 3
	Game.field[0][0][1] = 4
	world.draw_field(0)
	cur.build()
	_check(Game.field[0][0][2] == 3 and Game.field[0][0][3] == 4, "build shifts field down by two rows")
	cur.xpos = 1
	cur.ypos = 1
	var a: int = Game.field[0][1][1]
	var b: int = Game.field[0][2][2]
	cur.click()
	cur.xpos = 2
	cur.ypos = 2
	cur.click()
	_check(Game.field[0][1][1] == b and Game.field[0][2][2] == a, "swap")
	cur.new_field()
	_check(cur.angle != 0, "new field spin started")

	print("AUTOTEST phase 1a: necromancer")
	_clear_all()
	var necro := world.spawn_unit(Defs.UnitArt.TOTENBESCHWOERER, 1)
	necro.x = 200
	necro.graph = 305
	var warrior := world.spawn_unit(Defs.UnitArt.KRIEGER, 1)
	warrior.x = 150
	warrior.lp = 0
	_manual_tick()
	var skeletons := 0
	for u: Unit in world.units():
		if u.art == Defs.UnitArt.SKELETT:
			skeletons += 1
			_check(u.x >= 148 and u.x <= 154, "skeleton rises where the warrior died (x=%d)" % u.x)
	_check(skeletons == 1, "one skeleton raised (%d)" % skeletons)
	# warriors of both sides meet and trade blows
	_clear_all()
	var wa := world.spawn_unit(Defs.UnitArt.KRIEGER, 0)
	var wb := world.spawn_unit(Defs.UnitArt.KRIEGER, 1)
	wa.x = 100
	wb.x = 105
	_manual_tick()
	_check(wa.lp == Defs.LP_KRIEGER - 2 and wb.lp == Defs.LP_KRIEGER - 2, "pair trades 2 life points per frame (%d/%d)" % [wa.lp, wb.lp])
	# castle hit
	_clear_all()
	var rider := world.spawn_unit(Defs.UnitArt.RITTER, 0)
	rider.x = 262
	_manual_tick()
	_manual_tick()
	_check(Game.life[1] == 100 - int(sqrt(Defs.LP_RITTER * 4)), "castle damage sqrt(LP*4) (life=%d)" % Game.life[1])

	print("AUTOTEST phase 1b: mass battle (16x speed)")
	_clear_all()
	for art in range(1, 14):
		for p in 2:
			world.spawn_unit(art, p, 100, 221)
	for i in 6:
		world.spawn_anim(Defs.AnimArt.PEST, i % 2)
	Game.fps = Defs.FPS * 16   # 16x faster: more ticks per second, timers scaled the same
	Engine.physics_ticks_per_second = Game.fps
	Engine.max_physics_steps_per_frame = 64
	_phase = 2


func _manual_tick() -> void:
	# one game frame by hand (timers do not advance); only used for synchronous checks
	for c in world.procs.get_children():
		if c is Proc and (c as Proc).alive:
			c._born_tick = -1
			c._physics_process(0.0)


func _press(action: StringName) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)
	ev = InputEventAction.new()
	ev.action = action
	ev.pressed = false
	Input.parse_input_event(ev)


func _clear_all() -> void:
	for c in world.procs.get_children():
		if c is Unit or c is Shot or c is Explosion or c is SiegeAnim:
			(c as Proc).alive = false
			c.queue_free()
	for u in world.units():
		u.remove_from_group(&"units")
	for a in get_tree().get_nodes_in_group(&"animations"):
		a.remove_from_group(&"animations")
	Game.life = [100, 100]


func _count_things() -> int:
	return world.units().size() + get_tree().get_nodes_in_group(&"animations").size()


func _stage_battle() -> void:
	_clear_all()
	Game.life = [70, 45]
	for fx in Game.FIELD_W:
		for fy in Game.FIELD_H:
			Game.field[0][fx][fy] = randi_range(1, 4)
			Game.field[1][fx][fy] = randi_range(1, 4)
	_set_bottom(0, Grimoire.RECIPES[12], 0)
	_set_bottom(1, Grimoire.RECIPES[14], 1)
	world.draw_field(0)
	world.draw_field(1)
	world.spawn_unit(Defs.UnitArt.RANKEN, 0)
	world.spawn_unit(Defs.UnitArt.TURM, 1)
	world.spawn_unit(Defs.UnitArt.WOLKE, 0)
	world.spawn_unit(Defs.UnitArt.TOTENBESCHWOERER, 1)
	var u := world.spawn_unit(Defs.UnitArt.GOLEM, 0)
	u.x = 140
	u = world.spawn_unit(Defs.UnitArt.ELEFANT, 1)
	u.x = 190
	u = world.spawn_unit(Defs.UnitArt.RITTER, 0)
	u.x = 100
	u = world.spawn_unit(Defs.UnitArt.KRIEGER, 1)
	u.x = 215
	u = world.spawn_unit(Defs.UnitArt.DRACHE, 0)
	u.x = 120
	u = world.spawn_unit(Defs.UnitArt.LUFTSCHIFF, 1)
	u.x = 200
	world.spawn_anim(Defs.AnimArt.KATAPULT, 0)
	world.spawn_anim(Defs.AnimArt.BALLISTE, 1)
	world.spawn_anim(Defs.AnimArt.BOGENSCHUETZE, 1)
	world.spawn_anim(Defs.AnimArt.MAGIER, 0)
	world.spawn_anim(Defs.AnimArt.ARBEITER, 1)
	world.cursors[0].xpos = 3
	world.cursors[0].ypos = 3
	world.cursors[1].xpos = 1
	world.cursors[1].ypos = 4
	world.spawn_choosen_cursor(world.cursors[1])


func _physics_process(_delta: float) -> void:
	if _phase == 2:
		_frames += 1
		if _frames % 500 == 0:
			print("  frame ", _frames, " units=", world.units().size(), " t=", Time.get_ticks_msec(), " nodes=", get_tree().get_node_count())
		if _frames % 100 == 0:
			var p := randi() % 2
			world.spawn_unit(randi_range(1, 12), p)
			if _frames % 300 == 0:
				world.spawn_anim(randi_range(1, 6), 1 - p)
		if _frames >= 2000:
			print("  after 2000 frames: units=", world.units().size(), " life=", Game.life)
			Game.fps = Defs.FPS
			Engine.physics_ticks_per_second = Defs.FPS
			_frames = 0
			_phase = 1
			_stage_battle()
		return
	if _phase != 1:
		return
	_frames += 1
	# drive the real input path: P0 picks a tile, P1 moves right
	if _frames == 10:
		_press(&"p0_click")
	if _frames == 14:
		_press(&"p1_right")
	if _frames == 50 and _screenshot_path != "":
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path)
	if _frames == 60:
		_check(world.cursors[1].xpos == 2, "p1 cursor moved by input action (xpos=%d)" % world.cursors[1].xpos)
	if _frames > 200:
		print("AUTOTEST done: fails=", _fails, " units=", world.units().size(), " life=", Game.life)
		get_tree().quit(1 if _fails > 0 else 0)
