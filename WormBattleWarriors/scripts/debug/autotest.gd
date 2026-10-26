class_name AutoTest
extends Node
## Headless self test, only active with `-- --autotest` (optional `--screenshot=<path>`).
## Drives the cursor with input events and the rules through Game, prints PASS/FAIL and quits.

var _failures := 0
var _screenshot_path := ""
var _frames := 0
var _cursor: Cursor


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_cursor = get_parent().get_node("Cursor") as Cursor
	_run()
	print("AUTOTEST finished, failures=", _failures)
	if _screenshot_path == "":
		get_tree().quit(1 if _failures > 0 else 0)


func _process(_delta: float) -> void:
	if _screenshot_path == "":
		return
	_frames += 1
	if _frames == 10:
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		get_tree().quit(1 if _failures > 0 else 0)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
	print("  ", "PASS " if ok else "FAIL ", what)


func _press(action: StringName) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	_cursor._unhandled_input(down)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	_cursor._unhandled_input(up)


func _put(c: Vector2i, unit_type: int, ap := 5) -> void:
	var i := Game.idx(c)
	Game.typ[i] = unit_type
	Game.life[i] = 50
	Game.life_max[i] = 50
	Game.move_max[i] = 5
	Game.move[i] = ap


func _clear(c: Vector2i) -> void:
	_put(c, 0, 0)
	var i := Game.idx(c)
	Game.life[i] = 0
	Game.life_max[i] = 0
	Game.move_max[i] = 0


func _run() -> void:
	Game.new_game()
	_check(Game.count_units(0) == 2 and Game.count_units(1) == 2, "start: two workers per player")
	_check(Game.floor_[Game.idx(Vector2i(5, 7))] == Game.HOLE, "start: hole at (5,7)")

	# cursor via input events: to (4,7), select, step into the hole
	for i in 4:
		_press(&"move_right")
	for i in 7:
		_press(&"move_down")
	_check(Game.cursor_cell == Vector2i(4, 7), "cursor moved to (4,7)")
	_press(&"confirm")
	_check(Game.selected, "worker selected")
	_press(&"move_right")
	_check(Game.cursor_cell == Vector2i(5, 11), "hole drops the worker to (5,11)")
	_check(Game.move[Game.idx(Vector2i(5, 11))] == 4, "hole costs 1 AP")
	_press(&"move_down")
	_check(Game.cursor_cell == Vector2i(5, 12), "walks on dug earth")
	_press(&"move_up")
	_press(&"move_up")
	_check(Game.cursor_cell == Vector2i(5, 11), "cannot leave the underground upwards (original gap)")

	# digging: dirt costs 2 AP and becomes dug earth
	Game.floor_[Game.idx(Vector2i(6, 11))] = Game.DIRT
	_press(&"move_right")
	_check(Game.cursor_cell == Vector2i(6, 11) and Game.floor_[Game.idx(Vector2i(6, 11))] == Game.DUG, "dig dirt")
	_check(Game.move[Game.idx(Vector2i(6, 11))] == 0, "digging costs 2 AP")
	_press(&"cancel")
	_check(not Game.selected, "backspace releases the unit")

	# food store -> birth place -> trainer chain on a prepared strip (row 20)
	for x in range(8, 16):
		Game.floor_[Game.idx(Vector2i(x, 20))] = Game.DUG
		Game.stat[Game.idx(Vector2i(x, 20))] = 0
	_put(Vector2i(8, 20), Game.WORKER)
	Game.floor_[Game.idx(Vector2i(9, 20))] = Game.FOOD_STORE
	Game.act(Vector2i(8, 20), Vector2i(9, 20))
	var u := Game.idx(Vector2i(8, 20))
	_check(Game.typ[u] == Game.WORKER_FOOD and Game.stat[Game.idx(Vector2i(9, 20))] == 4, "worker takes food")
	Game.floor_[Game.idx(Vector2i(8, 21))] = Game.BIRTH_PLACE
	Game.act(Vector2i(8, 20), Vector2i(8, 21))
	_check(Game.typ[Game.idx(Vector2i(8, 21))] == Game.WORKER and Game.move[Game.idx(Vector2i(8, 21))] == 2, "birth place spawns a worker with 2 AP")
	_check(Game.typ[u] == Game.WORKER, "food carrier is a plain worker again")
	Game.floor_[Game.idx(Vector2i(8, 19))] = Game.TRAINER
	Game.act(Vector2i(8, 20), Vector2i(8, 19))
	_check(Game.typ[u] == Game.FIGHTER_WEAK and Game.life[u] == 100 and Game.life_max[u] == 100, "trainer makes a weak fighter (+50 life)")
	Game.floor_[Game.idx(Vector2i(7, 20))] = Game.TRAINER
	Game.act(Vector2i(8, 20), Vector2i(7, 20))
	_check(Game.typ[u] == Game.FIGHTER_STRONG and Game.move_max[u] == 7 and Game.life[u] == 150, "second trainer makes a strong fighter (+2 max AP)")
	Game.floor_[Game.idx(Vector2i(8, 22))] = Game.DIRT
	Game.act(Vector2i(8, 20), Vector2i(8, 22))
	_check(Game.floor_[Game.idx(Vector2i(8, 22))] == Game.DIRT, "fighters cannot dig")

	# leaf / branch on the surface, leaf refreshes a used food store
	_put(Vector2i(12, 7), Game.WORKER)
	Game.floor_[Game.idx(Vector2i(13, 7))] = Game.LEAF
	Game.floor_[Game.idx(Vector2i(12, 6))] = Game.BRANCH
	Game.act(Vector2i(12, 7), Vector2i(13, 7))
	_check(Game.typ[Game.idx(Vector2i(13, 7))] == Game.WORKER_LEAF and Game.floor_[Game.idx(Vector2i(13, 7))] == Game.GRASS, "worker lifts a leaf")
	Game.act(Vector2i(13, 7), Vector2i(13, 6))
	_put(Vector2i(10, 20), Game.WORKER_LEAF)
	Game.act(Vector2i(10, 20), Vector2i(9, 20))
	_check(Game.stat[Game.idx(Vector2i(9, 20))] == 0 and Game.typ[Game.idx(Vector2i(10, 20))] == Game.WORKER, "leaf carrier refreshes the food store")
	_put(Vector2i(14, 7), Game.WORKER)
	Game.floor_[Game.idx(Vector2i(15, 7))] = Game.BRANCH
	Game.act(Vector2i(14, 7), Vector2i(15, 7))
	_check(Game.typ[Game.idx(Vector2i(15, 7))] == Game.WORKER_WOOD, "worker lifts a branch")
	_put(Vector2i(16, 2), Game.WORKER)
	Game.act(Vector2i(16, 2), Vector2i(16, 3))
	_check(Game.typ[Game.idx(Vector2i(16, 2))] == Game.WORKER, "no level change air -> grass")

	# turn handling and combat (added by the port)
	Game.new_game()
	var p1 := Vector2i(4, 7)
	var p2 := Vector2i(27, 7)
	_clear(Vector2i(6, 7))
	_clear(Vector2i(25, 7))
	_put(Vector2i(10, 7), Game.FIGHTER_STRONG + 10)
	Game.life[Game.idx(Vector2i(10, 7))] = 150
	Game.move[Game.idx(p1)] = 0
	Game.end_turn()
	_check(Game.player_turn == 1 and Game.move[Game.idx(p2)] == 5, "turn passes, AP refreshed for player 2")
	_check(Game.move[Game.idx(Vector2i(10, 7))] == 5, "fighter AP refreshed")
	Game.move_cursor(Vector2i(10, 7))
	_check(Game.select_at_cursor(), "player 2 selects own unit")
	Game.end_turn()
	_check(Game.player_turn == 0 and not Game.selected, "turn ends on request")
	_check(Game.move[Game.idx(p1)] == 5, "player 1 AP refreshed")
	Game.end_turn()
	_put(Vector2i(11, 7), Game.WORKER, 5)
	for i in 2:
		Game.act(Vector2i(10, 7), Vector2i(11, 7))
	_check(Game.typ[Game.idx(Vector2i(11, 7))] == 0, "fighter kills a worker (two hits of 40)")
	_check(not Game.finished, "game continues while the opponent has units")
	# player 2 hunts down the last worker of player 1
	_clear(Vector2i(10, 7))
	_put(Vector2i(4, 8), Game.FIGHTER_STRONG + 10)
	Game.player_turn = 1
	for i in 2:
		Game.act(Vector2i(4, 8), Vector2i(4, 7))
	_check(Game.finished and Game.winner == 1, "game over when a player has no units left")
	_press(&"confirm")
	_check(not Game.finished and Game.count_units(0) == 2, "Enter starts a new game")

	if _screenshot_path != "":
		_showcase()


func _showcase() -> void:
	# a few units, a tunnel and a selection for the screenshot
	Game.new_game()
	_put(Vector2i(7, 12), Game.WORKER_FOOD)
	_put(Vector2i(8, 13), Game.FIGHTER_WEAK + 10, 2)
	Game.life[Game.idx(Vector2i(8, 13))] = 30
	_put(Vector2i(25, 14), Game.FIGHTER_STRONG + 10, 0)
	_put(Vector2i(24, 7), Game.WORKER_LEAF + 10, 3)
	Game.floor_[Game.idx(Vector2i(6, 12))] = Game.DUG
	Game.floor_[Game.idx(Vector2i(7, 12))] = Game.DUG
	Game.move_cursor(Vector2i(4, 7))
	Game.select_at_cursor()
	Game.board_changed.emit()
