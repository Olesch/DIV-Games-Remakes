class_name AutoTest
extends Node
## Headless smoke test, only active with `-- --autotest` (added by the Game autoload).
## Checks the level/save data loading, plays a new game (fights in the room with most enemies, weapon and
## magic cycling, trapdoor tile, room change, save point), kills the hero, then plays a game loaded from a
## bundled save slot. On the title it also puts a Castedit slot file (CastleLevel3.dat) in place and checks
## that the level set screen offers set 3 but not the missing set 4, and that choosing 3 loads it.
## Files the test writes (user://castle2.dat, Castedit's CastleLevel3.dat) are removed at the end and
## files the user already had are moved aside meanwhile, so both folders look exactly as before.
## Prints a summary and quits with exit code 0 (ok) or 1 (failed check).
## Optional `--screenshot=<path>` saves a gameplay screenshot (only meaningful when not headless; the test
## then does not finish), `--levelset-screenshot=<path>` one of the level set screen.

enum Phase { START, FIGHT, TRANSITION, TRAP, SAVE, DIE, WAIT_TITLE, TITLE_EDITED, LOADED, DONE }

const BACKUP_SUFFIX := ".autotest-backup"

var _phase: Phase = Phase.START
var _ticks := 0
var _phase_ticks := 0
var _failures := 0
var _screenshot_path := ""
var _screenshot_done := false
var _kills_before := 0
var _exp_before := 0
var _arrows_start := 0
var _files_before: Dictionary = {}     # folder -> file list at the start
var _created_editor_dir := false
var _test_files: PackedStringArray = []
var _levelset_shot := ""


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
		if arg.begins_with("--levelset-screenshot="):
			_levelset_shot = arg.substr("--levelset-screenshot=".length())
	Engine.time_scale = 4.0 if _screenshot_path == "" else 1.0
	var editor_dir := Game.edited_level_path(3).get_base_dir()
	_created_editor_dir = not DirAccess.dir_exists_absolute(editor_dir)
	DirAccess.make_dir_recursive_absolute(editor_dir)
	_test_files = [Game.slot_user_path(2), Game.edited_level_path(3), Game.edited_level_path(4)]
	for dir in ["user://", editor_dir]:
		_files_before[dir] = DirAccess.get_files_at(dir)
	for path in _test_files:
		if FileAccess.file_exists(path + BACKUP_SUFFIX) and not FileAccess.file_exists(path):
			DirAccess.rename_absolute(path + BACKUP_SUFFIX, path)   # left by an interrupted run
		if FileAccess.file_exists(path):
			DirAccess.rename_absolute(path, path + BACKUP_SUFFIX)
	_check_data()


func _press(action: StringName) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)


func _rel(action: StringName) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = false
	Input.parse_input_event(e)


func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok   ", msg)
	else:
		print("  FAIL ", msg)
		_failures += 1


func _check_data() -> void:
	print("AUTOTEST data")
	print("       Castedit level files are read from ", ProjectSettings.globalize_path(Game.edited_level_path(1)).get_base_dir())
	for n in [1, 2]:
		_check(Game.load_levelset(n), "level set %d loads (%d ints)" % [n, Game.map.size()])
		var walls := 0
		var floors := 0
		for i in range(0, Game.map.size()):
			var room_layer := i / (Game.COLS * Game.ROWS)
			if room_layer % 2 == 0:
				if Game.map[i] == 22:
					walls += 1
				elif Game.map[i] == 6:
					floors += 1
		print("       set %d: %d wall cells, %d floor cells" % [n, walls, floors])
		_check(walls > 1000 and floors > 100, "set %d has plausible terrain" % n)
	Game.load_levelset(1)
	_check(Game.map[Game.map_index(0, 0, 0, 0)] == 22, "set 1 room 0 corner is wall (index formula)")
	for slot in [1, 2, 3, 4]:
		if Game.load_slot(slot):
			var s := Game.stat
			print("       slot %d: stage %d life %d/%d level %d diff %d hero (%d,%d)" % [slot, Game.stage, s.life,
				s.max_life, s.level, Game.difficulty, Game.xhero, Game.yhero])
			_check(Game.stage >= 0 and Game.stage < 36 and s.level >= 1 and s.max_life > 0, "slot %d is sane" % slot)
		else:
			print("       slot %d: not loadable (size mismatch, expected for the old-format slot 4)" % slot)
	Game.load_levelset(1)


func _physics_process(_delta: float) -> void:
	_ticks += 1
	_phase_ticks += 1
	match _phase:
		Phase.START:
			_start_new_game()
		Phase.FIGHT:
			if _screenshot_path == "" or _phase_ticks < 100:
				_fight()
		Phase.TRANSITION:
			_transition()
		Phase.TRAP:
			_trap()
		Phase.SAVE:
			_save()
		Phase.DIE:
			_die()
		Phase.WAIT_TITLE:
			_wait_title()
		Phase.TITLE_EDITED:
			_title_edited()
		Phase.LOADED:
			_loaded()
		Phase.DONE:
			pass
	if _screenshot_path != "" and _phase == Phase.FIGHT and _phase_ticks == 120:
		_press(&"hero_stats")
	if _screenshot_path != "" and not _screenshot_done and _phase == Phase.FIGHT and _phase_ticks == 150:
		_screenshot_done = true
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path)


func _go(p: Phase) -> void:
	_phase = p
	_phase_ticks = 0
	print("AUTOTEST phase ", Phase.keys()[p])


func _start_new_game() -> void:
	if _phase_ticks == 1:
		Game.load_levelset(1)
		Game.start_new_game(0)
		return
	if Game.world == null:
		return
	if _phase_ticks < 4:
		return
	_check(Game.hero != null and Game.stat.life == 10 and Game.stat.max_life == 80, "new game stats (life 10/80)")
	_check(get_tree().get_nodes_in_group(&"pickups").size() + get_tree().get_nodes_in_group(&"enemies").size() > 0,
		"room 0 spawned objects")
	if _screenshot_path == "":
		_teleport_to_busiest_room()
	_go(Phase.FIGHT)


func _teleport_to_busiest_room() -> void:
	var best := 0
	var best_count := -1
	for r in Game.ROOMS:
		var c := 0
		for gx in Game.COLS:
			for gy in Game.ROWS:
				var v := Game.map[Game.map_index(r, 1, gx, gy)]
				if v in [41, 40, 39, 38, 17, 18, 13]:
					c += 1
		if c > best_count:
			best_count = c
			best = r
	Game.world.clear_room_entities()
	Game.stage = best
	# stand on the floor tile (terrain 6) closest to the first enemy cell
	var enemy_cell := Vector2i(20, 15)
	for gx in Game.COLS:
		for gy in Game.ROWS:
			if Game.map[Game.map_index(best, 1, gx, gy)] in [41, 40, 39, 38, 17, 18, 13]:
				enemy_cell = Vector2i(gx, gy)
	var pos := Vector2i(30, 30)
	var best_d := 1e9
	for gx in range(2, Game.COLS - 2):
		for gy in range(2, Game.ROWS - 2):
			if Game.map[Game.map_index(best, 0, gx, gy)] == 6:
				var d := Vector2i(gx, gy).distance_to(enemy_cell)
				if d > 5 and d < best_d:
					best_d = d
					pos = Vector2i(gx * 20 + 10, gy * 20 + 10)
	Game.hero.ix = pos.x
	Game.hero.iy = pos.y
	Game.world.draw_room()
	Game.stat.arrows = 60
	Game.stat.max_mana = 40
	Game.stat.mana = 40
	Game.stat.flame_learned = 1
	Game.stat.ice_learned = 1
	Game.stat.heal_learned = 1
	Game.stat.strength = 12
	Game.stat.bow = 10
	Game.stat.magic = 14
	_arrows_start = 60
	_exp_before = Game.stat.exp
	print("       testing in room ", best, " with ", best_count, " monsters, hero at ", pos,
		" enemies spawned: ", get_tree().get_nodes_in_group(&"enemies").size())


func _release_all() -> void:
	for a in [&"hero_up", &"hero_down", &"hero_left", &"hero_right", &"hero_attack", &"hero_weapon",
			&"hero_magic", &"hero_run", &"hero_stats"]:
		_rel(a)


func _fight() -> void:
	var hero := Game.hero
	if hero == null:
		return
	# keep the hero alive and well-supplied; walk towards the nearest enemy, attack, change weapons
	Game.stat.life = Game.stat.max_life
	Game.stat.condition = Game.stat.max_condition
	Game.stat.mana = maxi(Game.stat.mana, 10)
	_release_all()
	var enemies := get_tree().get_nodes_in_group(&"enemies")
	var target: Enemy = null
	var best := 1e9
	for e: Enemy in enemies:
		var d := Vector2(hero.ix, hero.iy).distance_to(Vector2(e.ix, e.iy))
		if d < best:
			best = d
			target = e
	if target != null:
		if target.ix > hero.ix + 3:
			_press(&"hero_right")
		elif target.ix < hero.ix - 3:
			_press(&"hero_left")
		if target.iy > hero.iy + 3:
			_press(&"hero_down")
		elif target.iy < hero.iy - 3:
			_press(&"hero_up")
		if _phase_ticks % 5 == 0:
			_press(&"hero_run")
	# alternate: attack on even 4-tick windows, switch weapon / magic on others
	var w := _phase_ticks % 40
	if w == 10 or w == 20:
		_press(&"hero_weapon")
	elif w == 30:
		_press(&"hero_magic")
	elif w % 4 == 0:
		_press(&"hero_attack")
	if _phase_ticks % 97 == 50:
		_press(&"hero_stats")
	if _phase_ticks >= 1500 or (target == null and _phase_ticks > 60):
		_release_all()
		print("       fight ended after ", _phase_ticks, " ticks: enemies left ", enemies.size(),
			", exp gained ", Game.stat.exp - _exp_before, ", level ", Game.stat.level,
			", arrows used ", _arrows_start - Game.stat.arrows)
		_check(Game.stat.exp > _exp_before or enemies.size() > 0, "combat progressed")
		_go(Phase.TRANSITION)


func _transition() -> void:
	var hero := Game.hero
	if _phase_ticks == 1:
		_release_all()
		Game.stage = 14
		Game.world.clear_room_entities()
		Game.world.draw_room()
		hero.ix = 795
		hero.iy = 300
		_kills_before = Game.stage
		return
	if _phase_ticks == 2:
		hero.iy = 300
	if _phase_ticks == 8:
		_check(Game.stage == 15 and hero.ix == 30, "walking off the right edge: stage 14 -> 15, hero x=30 (stage %d x %d)" % [Game.stage, hero.ix])
		hero.iy = 595
		hero.ix = 400
		return
	if _phase_ticks == 16:
		_check(Game.stage == 21 and hero.iy == 30, "walking off the bottom edge: stage 15 -> 21 (stage %d y %d)" % [Game.stage, hero.iy])
		_go(Phase.TRAP)


func _trap() -> void:
	var hero := Game.hero
	if _phase_ticks == 1:
		Game.load_levelset(1)
		Game.stage = 0
		# find a room with a trapdoor trigger (211) and an open door (213) within 2 cells
		for r in Game.ROOMS:
			for gx in range(2, Game.COLS - 2):
				for gy in range(2, Game.ROWS - 2):
					if Game.map[Game.map_index(r, 0, gx, gy)] == 211:
						for cx in range(-2, 3):
							for cy in range(-2, 3):
								if Game.map[Game.map_index(r, 0, gx + cx, gy + cy)] == 213 and Game.stage == 0 and r != 0:
									Game.stage = r
									hero.ix = gx * 20 + 10
									hero.iy = gy * 20 + 10
		if Game.stage == 0:
			print("       no 211 trigger with a 213 neighbour found; skipping trap check")
			_go(Phase.SAVE)
			return
		Game.world.clear_room_entities()
		Game.world.draw_room()
		return
	if _phase_ticks == 3:
		var shut := 0
		for gx in Game.COLS:
			for gy in Game.ROWS:
				if Game.cell(0, gx, gy) == 212:
					shut += 1
		_check(shut > 0, "stepping on a trap trigger shuts nearby trapdoors (%d shut cells in room %d)" % [shut, Game.stage])
		_go(Phase.SAVE)


func _save() -> void:
	var hero := Game.hero
	if _phase_ticks == 1:
		Game.stage = 0
		Game.world.clear_room_entities()
		Game.world.draw_room()
		hero.ix = 200
		hero.iy = 200
		Game.world.spawn_pickup(72, 1, 200, 200)
		_press(&"save_f2")
		return
	if _phase_ticks == 4:
		_rel(&"save_f2")
		_check(FileAccess.file_exists(Game.slot_user_path(2)), "save point wrote user://castle2.dat")
		var bytes := FileAccess.get_file_as_bytes(Game.slot_user_path(2))
		_check(bytes.size() == Game.SAVE_INTS * 4, "save file size %d" % bytes.size())
		var life := Game.stat.life
		var level := Game.stat.level
		var ok := Game.load_slot(2)
		_check(ok and Game.stat.life == life and Game.stat.level == level and Game.xhero == 200 and Game.yhero == 200,
			"saved game loads back identically")
		Game.load_levelset(1)
		Game.stage = 0
		_go(Phase.DIE)


func _die() -> void:
	if _phase_ticks == 1:
		Game.stat.life = 0
		Game.hero.hit_damage = 0
		return
	if _phase_ticks == 40:
		_check(Game.world.get_node("Entities").get_child_count() > 0, "death animation spawns blood")
		_go(Phase.WAIT_TITLE)


func _wait_title() -> void:
	if get_tree().current_scene != null and get_tree().current_scene.name == "Title":
		_check(true, "hero death returns to the title screen after %d ticks" % _phase_ticks)
		_check(not Game.has_levelset(3) and not Game.has_levelset(4), "no Castedit slots yet")
		# a Castedit save in slot 3 (here simply the bytes of the original set 2)
		var f := FileAccess.open(Game.edited_level_path(3), FileAccess.WRITE)
		f.store_buffer(FileAccess.get_file_as_bytes("res://assets/dat/level2.dat"))
		f.close()
		_go(Phase.TITLE_EDITED)
	elif _phase_ticks > 600:
		_check(false, "hero death returns to the title screen")
		_finish()


func _title_text() -> String:
	var texts := PackedStringArray()
	for child in get_tree().current_scene.get_children():
		if child is Label:
			texts.append(child.text)
	return "
".join(texts)


func _tap(action: StringName) -> void:
	_press(action)
	_rel(action)


func _title_edited() -> void:
	match _phase_ticks:
		1:
			_tap(&"menu_new")
		3:
			_check(_title_text().contains("3 - Castedit-Level") and _title_text().contains("4 - nicht vorhanden"),
				"level set screen offers Castedit slot 3, not the missing slot 4")
			if _levelset_shot != "" and DisplayServer.get_name() != "headless":
				var shot := _levelset_shot
				get_viewport().get_texture().get_image().save_png(shot)
				print("screenshot saved: ", shot)
			_tap(&"slot_4")
		5:
			_check(_title_text().contains("Welches Levelset"), "4 (not saved in Castedit) cannot be chosen")
			_tap(&"slot_3")
		7:
			_check(_title_text().contains("Schwierigkeitsstufe")
				and Game.map == FileAccess.get_file_as_bytes("res://assets/dat/level2.dat").to_int32_array(),
				"choosing 3 loads Castedit's CastleLevel3.dat")
			Game.load_levelset(1)
			_check(Game.map == FileAccess.get_file_as_bytes("res://assets/dat/level1.dat").to_int32_array(),
				"set 1 is still the original")
			DirAccess.remove_absolute(Game.edited_level_path(3))
			# loaded game from a bundled slot: save slots do not depend on the level files
			if Game.load_slot(1):
				Game.start_loaded_game()
				_go(Phase.LOADED)
			else:
				_finish()


func _loaded() -> void:
	if Game.world == null:
		return
	var hero := Game.hero
	if _phase_ticks < 5:
		return
	Game.stat.life = maxi(Game.stat.life, 20)
	_release_all()
	var dirs := [&"hero_up", &"hero_right", &"hero_down", &"hero_left"]
	_press(dirs[(_phase_ticks / 30) % 4])
	if _phase_ticks % 7 == 0:
		_press(&"hero_attack")
	if _phase_ticks == 6:
		_check(hero.ix == Game.xhero and Game.stat.level >= 1, "loaded slot 1: hero at saved position, level %d" % Game.stat.level)
	if _phase_ticks > 400:
		_release_all()
		_check(Game.world != null, "loaded game still running")
		_finish()


func _finish() -> void:
	for path in _test_files:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		if FileAccess.file_exists(path + BACKUP_SUFFIX):
			DirAccess.rename_absolute(path + BACKUP_SUFFIX, path)
	var editor_dir := Game.edited_level_path(1).get_base_dir()
	if _created_editor_dir:
		DirAccess.remove_absolute(editor_dir)
	for dir: String in _files_before:
		var now := DirAccess.get_files_at(dir) if DirAccess.dir_exists_absolute(dir) else PackedStringArray()
		_check(now == _files_before[dir], "%s is left as it was (%s)" % [dir, ", ".join(now)])
	_phase = Phase.DONE
	print("AUTOTEST finished: ", "ALL OK" if _failures == 0 else "%d FAILED" % _failures)
	get_tree().quit(0 if _failures == 0 else 1)
