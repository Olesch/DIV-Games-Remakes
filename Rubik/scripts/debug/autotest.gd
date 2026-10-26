class_name AutoTest
extends Node
## Headless smoke test, only with `-- --autotest`. Checks the move tables, cursor wrapping, the
## scramble/undo cycle and the dot animation. Writes no files. Quits unless running in a web build.

var _failures := 0


func _ready() -> void:
	_run.call_deferred()


func _check(cond: bool, what: String) -> void:
	if not cond:
		_failures += 1
		printerr("AUTOTEST FAIL: ", what)


func _run() -> void:
	var main := get_parent()
	var puzzle: Puzzle = main.puzzle
	# every move is a 3-cycle: applying it three times is the identity
	for c in range(1, 13):
		var before := puzzle.cells.duplicate()
		for i in 3:
			puzzle.apply_move(c)
		_check(puzzle.cells == before, "cursor %d cycle order 3" % c)
	# inverse pairs
	for pair in [[1, 9], [2, 8], [3, 7], [4, 12], [5, 11], [6, 10]]:
		var before := puzzle.cells.duplicate()
		puzzle.apply_move(pair[0])
		puzzle.apply_move(pair[1])
		_check(puzzle.cells == before, "moves %s inverse" % str(pair))
	# scramble, then undo with inverse moves
	puzzle.cells = PackedInt32Array([1, 2, 3, 4, 5, 6, 7, 8, 9])
	var inverse := [0, 9, 8, 7, 12, 11, 10, 3, 2, 1, 6, 5, 4]
	var history: Array[int] = []
	for i in 40:
		history.append(puzzle.shuffle_step())
	var sorted_cells := Array(puzzle.cells)
	sorted_cells.sort()
	_check(sorted_cells == [1, 2, 3, 4, 5, 6, 7, 8, 9], "still a permutation")
	history.reverse()
	for c in history:
		puzzle.apply_move(inverse[c])
	_check(puzzle.is_solved(), "undo restores the solved board")
	# cursor wrapping
	main.cursor = 12
	main.move_cursor(1)
	_check(main.cursor == 1, "cursor wraps 12 -> 1")
	main.move_cursor(-1)
	_check(main.cursor == 12, "cursor wraps 1 -> 12")
	# input actions reach the handler
	puzzle.cells = PackedInt32Array([1, 2, 3, 4, 5, 6, 7, 8, 9])
	var ev := InputEventAction.new()
	ev.action = &"rotate"
	ev.pressed = true
	Input.parse_input_event(ev)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(not puzzle.is_solved(), "rotate action moves numbers")
	# solved -> dots animate
	puzzle.cells = PackedInt32Array([1, 2, 3, 4, 5, 6, 7, 8, 9])
	main._refresh()
	var field: PixelField = main._field
	_check(field.active, "dots active when solved")
	for i in 600:
		field.step()
	await get_tree().create_timer(0.5).timeout
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(arg.substr("--screenshot=".length()))
	puzzle.apply_move(5)
	_check(not field.active, "dots off when unsolved")
	print("AUTOTEST done, failures=", _failures)
	if not OS.has_feature("web"):
		get_tree().quit(1 if _failures > 0 else 0)
