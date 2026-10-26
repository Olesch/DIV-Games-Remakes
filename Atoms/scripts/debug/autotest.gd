extends Node
## Automated smoke test, only added by main.gd with `-- --autotest` on the command line.
## 1. unit-tests the molecule rules (AtomBoard), 2. plays through the real menus with simulated key
## presses (easy round with pre-set atoms, bombs, scoring; hard round with fewer 4-bond atoms and
## random play), 3. checks the invariants, prints a summary and quits.
## Optional: `--screenshot=<png>` saves the gameplay frame, `--shotdir=<dir>` saves one frame per screen.

var _fails := 0
var _screenshot_path := ""
var _shot_dir := ""


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
		elif arg.begins_with("--shotdir="):
			_shot_dir = arg.substr("--shotdir=".length())
	Engine.time_scale = 6.0
	seed(20261023)
	Game.score_files = ["user://autotest_easy.dat", "user://autotest_hard.dat"]
	Game.hi_easy = 0
	Game.hi_hard = 0
	_run()


func _expect(cond: bool, msg: String) -> void:
	if not cond:
		_fails += 1
		print("FAIL: ", msg)
	else:
		print("ok:   ", msg)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


## Sends one press (and release) of an InputMap action through the normal input pipeline.
func _tap(action: StringName, wait := 0.06) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)
	await _wait(0.02)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	await _wait(wait)


func _taps(action: StringName, n: int) -> void:
	for i in n:
		await _tap(action, 0.02)


func _shot(name: String) -> void:
	if _shot_dir == "":
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	var image := get_viewport().get_texture().get_image()
	if image:
		image.save_png("%s/%s.png" % [_shot_dir, name])


func _unit_tests() -> void:
	print("--- board rules")
	var b := AtomBoard.new()
	b.field = 3
	b.mode = 0
	b.cell(0, 0).exists = true
	b.cell(0, 0).up = true
	b.cell(0, 0).left = true
	b.check(0, 0)
	_expect(not b.no_atom, "easy: corner atom bonded to the walls is complete")
	_expect(b.kill() == 1 and not b.cell(0, 0).exists, "easy: it is removed, count 1")

	b = AtomBoard.new()
	b.field = 3
	b.mode = 1
	b.cell(0, 0).exists = true
	b.cell(0, 0).up = true
	b.cell(0, 0).left = true
	b.check(0, 0)
	_expect(b.no_atom, "hard: bonds into the wall are open")
	_expect(b.kill() == 0 and b.cell(0, 0).exists and not b.no_atom, "hard: nothing removed, flags reset")

	for mode in [0, 1]:
		b = AtomBoard.new()
		b.field = 2
		b.mode = mode
		var a := b.cell(1, 1)
		var c := b.cell(1, 2)
		a.exists = true
		a.down = true
		c.exists = true
		c.up = true
		b.check(1, 1)
		_expect(not b.no_atom, "mode %d: two atoms bonded to each other" % mode)
		_expect(b.kill() == 2, "mode %d: both removed (count 2)" % mode)

	b = AtomBoard.new()
	b.field = 2
	b.cell(1, 1).exists = true
	b.cell(1, 1).down = true
	b.cell(1, 2).exists = true
	b.check(1, 1)
	_expect(b.no_atom, "one-sided bond is open")
	_expect(b.kill() == 0, "open group stays")

	# chain of three, long molecule, easy mode, bonds to the walls at both ends
	b = AtomBoard.new()
	b.field = 4
	b.mode = 0
	for x in 5:
		b.cell(x, 4).exists = true
		b.cell(x, 4).down = true         # wall below
		if x > 0:
			b.cell(x, 4).left = true
		if x < 4:
			b.cell(x, 4).right = true
	b.cell(0, 4).left = true             # wall left
	b.cell(4, 4).right = true            # wall right
	b.check(2, 4)
	_expect(not b.no_atom and b.kill() == 5, "chain of 5 along the wall (easy)")


func _count_atoms() -> int:
	return Game.board.atom_count()


func _run() -> void:
	_unit_tests()
	var main := get_parent()
	var cursor: AtomCursor = main.get_node("Cursor")
	print("--- menus")
	await _wait(0.5)
	await _shot("1_intro")
	_expect(main.current_state() == main.State.INTRO, "intro keeps ignoring input at first")
	await _tap(&"confirm")
	_expect(main.current_state() == main.State.INTRO, "Enter is ignored during the 4 s title")
	await _wait(4.0 + 0.2)
	_expect(main.current_state() == main.State.INTRO_MENU, "intro menu after 72/18 s")
	await _shot("2_intro_menu")
	await _tap(&"rules")
	_expect(main.current_state() == main.State.RULES_PICTURE, "H shows the rules picture")
	await _wait(0.1)
	await _shot("3_rules_picture")
	await _tap(&"confirm")
	_expect(main.current_state() == main.State.RULES_KEYS, "Enter shows the key list")
	await _wait(0.1)
	await _shot("4_rules_keys")
	await _tap(&"confirm")
	_expect(main.current_state() == main.State.MODE, "Enter leads to the mode menu")
	await _wait(0.1)
	await _shot("5_mode_menu")
	await _tap(&"choice_1")
	_expect(Game.mode == 0 and main.current_state() == main.State.QUAD, "easy mode chosen")
	await _wait(0.1)
	await _shot("6_quad_menu")
	await _tap(&"choice_1")
	_expect(Game.quad == 0 and main.current_state() == main.State.SIZE, "normal 4-atoms chosen")
	await _wait(0.1)
	await _shot("7_size_menu")
	await _taps(&"right", 4)
	_expect(Game.field == 8, "grid size selector capped at 8 (value %d)" % Game.field)
	await _tap(&"confirm")
	_expect(Game.field == 7, "grid index is size-1 (8x8)")
	await _taps(&"right", 9)
	var wanted := Game.given_atoms
	_expect(wanted == 9, "given atoms selector counts up (%d)" % wanted)
	await _wait(0.1)
	await _shot("8_given_menu")
	await _tap(&"confirm")
	_expect(Game.given_atoms == 0, "pre-set atoms placed, counter back to 0")
	_expect(Game.board.atom_count() == wanted, "board holds exactly the chosen number of atoms (%d)" % Game.board.atom_count())
	await _taps(&"right", 3)
	var bombs_chosen := Game.bombs
	await _tap(&"confirm")
	await _taps(&"left", 30)
	_expect(Game.bomb_need == 5, "bomb threshold clamps at 5")
	await _tap(&"confirm")
	await _taps(&"right", 3)
	_expect(Game.con_info == 3, "shown atoms selector (%d)" % Game.con_info)
	await _tap(&"confirm")
	await _wait(0.1)

	print("--- easy round")
	_expect(main.current_state() == main.State.ROUND, "round started")
	_expect(Game.bombs == bombs_chosen, "bombs as chosen (%d)" % Game.bombs)
	_expect(Game.points == 0, "points start at 0")
	if Game.board.cell(0, 0).exists:
		var before := Game.bombs
		await _tap(&"bomb")
		_expect(Game.bombs == before - 1 and not Game.board.cell(0, 0).exists, "bomb removes the atom under the cursor")
	Game.connections[0] = 1
	await _tap(&"confirm")
	_expect(Game.cursor_state == 1 and Game.board.cell(0, 0).exists, "enter places an atom, bond mode on")
	await _tap(&"up", 0.4)
	_expect(Game.points == 1 and not Game.board.cell(0, 0).exists, "1-bond atom at the wall scores 1 (points %d)" % Game.points)
	_expect(Game.cursor_state == 0, "back to moving after the molecule vanished")
	Game.connections[0] = 2
	await _tap(&"confirm")
	await _tap(&"left")
	await _tap(&"up", 0.4)
	_expect(Game.points == 2, "2-bond corner atom scores 1 more (one atom = one point) (points %d)" % Game.points)
	# movement: a slide blocks further input until it ends (4/18 s)
	await _tap(&"right", 0.0)
	await _tap(&"down", 0.0)      # ignored: still sliding
	await _wait(0.4)
	_expect(is_equal_approx(cursor.position.x, 240.0), "cursor moved one cell right (x=%s)" % cursor.position.x)
	_expect(is_equal_approx(cursor.position.y, 130.0), "input during the slide is ignored (y=%s)" % cursor.position.y)
	await _tap(&"down", 0.4)
	_expect(is_equal_approx(cursor.position.y, 170.0), "cursor moved one cell down")
	# random play
	var actions: Array[StringName] = [&"up", &"down", &"left", &"right", &"confirm", &"bomb"]
	for i in 160:
		await _tap(actions[randi() % actions.size()], 0.05 + randf() * 0.25)
		if i == 120:
			await _shot("9_game_easy")
	_expect(Game.points >= 2, "points never decrease (%d)" % Game.points)
	await _wait(0.4)
	if _screenshot_path != "":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)
	var easy_points := Game.points
	await _tap(&"new_round")
	_expect(main.current_state() == main.State.MODE, "ESC returns to the mode menu")
	_expect(Game.board.atom_count() == 0 and Game.cursor_state == 0, "ESC clears the board for a new round")
	_expect(Game.hi_easy == easy_points, "easy hiscore stored (%d)" % Game.hi_easy)
	_expect(FileAccess.file_exists("user://autotest_easy.dat"), "hiscore file written to user://")

	print("--- hard round")
	await _tap(&"choice_2")
	_expect(Game.mode == 1, "hard mode chosen")
	await _tap(&"choice_2")
	_expect(Game.quad == 1, "fewer 4-bond atoms chosen")
	await _taps(&"left", 2)
	_expect(Game.field == 3, "size selector went down (value %d)" % Game.field)
	await _taps(&"right", 3)
	_expect(Game.field == 6, "size selector went up again (value %d)" % Game.field)
	await _tap(&"confirm")
	await _taps(&"right", 6)
	var hard_given := Game.given_atoms
	_expect(hard_given == 6 and hard_given <= (Game.field - 1) * (Game.field - 1), "given atoms limited to the interior (%d)" % hard_given)
	await _tap(&"confirm")
	_expect(Game.board.atom_count() == hard_given, "hard: atoms on board = chosen (%d)" % Game.board.atom_count())
	await _tap(&"confirm")      # bombs 0
	await _tap(&"confirm")      # bomb need 100
	await _taps(&"right", 12)
	_expect(Game.con_info == 10, "shown atoms capped at 10 (%d)" % Game.con_info)
	await _tap(&"confirm")
	await _wait(0.1)
	var fours := 0
	for i in 400:
		fours += 1 if Game.random_connections() == 4 else 0
	_expect(fours > 40 and fours < 130, "fewer 4s with quad=1 (%d of 400, expect ~18%%)" % fours)
	for i in 200:
		await _tap(actions[randi() % actions.size()], 0.05 + randf() * 0.25)
		if i == 150:
			await _shot("10_game_hard")
	print("hard round: points=", Game.points, " atoms=", Game.board.atom_count(), " bombs=", Game.bombs)
	await _tap(&"new_round")
	await _tap(&"new_round")     # at the mode menu: quit
	_expect(main.current_state() == main.State.THANKS, "ESC on the mode menu shows the thanks screen")
	await _wait(0.1)
	await _shot("11_thanks")
	print("AUTOTEST done, failures: ", _fails)
	get_tree().quit(1 if _fails > 0 else 0)
