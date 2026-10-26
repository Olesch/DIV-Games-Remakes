class_name AutoTest
extends Node
## Headless smoke test, only active with `-- --autotest` on the command line.
## Checks the default (ANT.PRG fixed = Langton's RL), the original's bug (one straight white line),
## the rule tables, Langton's first step,
## the options (rules, ants, canvas, wrap, speed), pause, pan and zoom; optionally saves a
## screenshot (`--screenshot=<absolute path>`, `--shot-rule=LLRR`, or `--shot-default` for the plain default run). Writes nothing to user://.

var _main: Node2D
var _canvas: AntCanvas
var _failures := 0
var _screenshot_path := ""
var _shot_rule := "LRRRRRLLR"
var _shot_ants := 1


func _ready() -> void:
	_main = get_parent() as Node2D
	_canvas = _main.get_node("AntCanvas") as AntCanvas
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
		elif arg.begins_with("--shot-rule="):
			_shot_rule = arg.substr("--shot-rule=".length())
		elif arg.begins_with("--shot-ants="):
			_shot_ants = int(arg.substr("--shot-ants=".length()))
	_run()


func _check(condition: bool, what: String) -> void:
	print(("  ok   " if condition else "  FAIL ") + what)
	if not condition:
		_failures += 1


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _run() -> void:
	print("AUTOTEST start")
	# 0) default: ANT.PRG with the table slip fixed = Langton's ant RL
	await _wait(0.5)
	_check(Settings.rule_text == "RL" and _canvas.rule.label == "RL", "default rule is RL (%s)" % Settings.rule_text)
	var white_default := _canvas.count_colour(15)
	_check(white_default > 100 and white_default + _canvas.count_colour(0) == _canvas.cells.size(),
		"default run paints a Langton pattern (%d white, %d steps)" % [white_default, _canvas.total_steps])
	var fixed := AntRule.original_fixed()
	var langton := AntRule.parse("RL")
	_check(fixed.turns.slice(0, 2) == langton.turns and fixed.paint.slice(0, 2) == langton.paint
		and fixed.state_of_colour == langton.state_of_colour, "fixed ANT.PRG tables == RL")

	# 1) the original's bug: 3001 steps straight up from (512,384), painting white (15); 384 fit on the picture
	_main.set_paused(true)
	Settings.rule_text = AntRule.ORIGINAL
	var ant := _canvas.get_node("Ants").get_child(0) as Ant
	_canvas.run_ant(ant, Settings.DEFAULT_STEPS)
	_main.set_paused(false)
	_check(_canvas.count_colour(15) == 384, "original draws a 384 px white line (got %d)" % _canvas.count_colour(15))
	_check(_canvas.colour_at(512, 0) == 15 and _canvas.colour_at(512, 383) == 15 and _canvas.colour_at(512, 384) == 0,
		"line runs from y=383 to y=0 at x=512")
	_check(ant.cell.x == 512 and ant.cell.y < 0 and ant.direction == 0, "ant left the picture going up: %s" % ant.cell)
	_check(_canvas.total_steps % Settings.DEFAULT_STEPS == 0, "steps come in frames of 3001 (%d)" % _canvas.total_steps)

	var original := AntRule.original()
	_check(original.paint == PackedByteArray([15, 0, 0]) and original.turns == PackedByteArray([0, 1, 0]),
		"original tables: paint %s turns %s" % [original.paint, original.turns])
	_check(AntRule.parse("xyz") == null and AntRule.parse("") == null and AntRule.parse("RL") != null,
		"rule string validation")

	# 2) Langton's ant, single steps
	_main.set_paused(true)
	Settings.rule_text = "RL"
	ant = _canvas.get_node("Ants").get_child(0) as Ant
	_canvas.run_ant(ant, 1)
	_check(ant.cell == Vector2i(512, 383) and ant.direction == 1 and _canvas.colour_at(512, 383) == 15,
		"RL first step: up, turn right, paint white")
	_canvas.run_ant(ant, 11000 - 1)
	var white := _canvas.count_colour(15)
	_check(white > 100 and white + _canvas.count_colour(0) == _canvas.cells.size(), "RL after 11000 steps: %d white" % white)
	var paused_steps := _canvas.total_steps
	await _wait(0.3)
	_check(_canvas.total_steps == paused_steps, "pause stops the ants")
	_main.set_paused(false)

	# 3) options: many ants, multi-colour rule, random dots, wrap, speed
	Settings.steps_per_frame = 10000
	Settings.wrap_edges = true
	Settings.ant_count = 9
	Settings.start_canvas = Settings.StartCanvas.RANDOM_DOTS
	Settings.rule_text = "LLRR"
	await _wait(1.0)
	var ants := _canvas.get_node("Ants").get_child_count()
	_check(ants == 9, "9 ants (%d)" % ants)
	var allowed := {}
	for c in AntRule.parse("LLRR").colours:
		allowed[c] = true
	var stray := 0
	for c in [1, 2, 3, 15, 22, 41, 59]:
		if not allowed.has(c):
			stray += _canvas.count_colour(c)
	_check(stray == 0, "only rule colours on the canvas")
	_check(_canvas.total_steps >= 9 * 10000, "LLRR ran %d steps" % _canvas.total_steps)
	for a: Ant in _canvas.get_node("Ants").get_children():
		if a.cell.x < 0 or a.cell.y < 0 or a.cell.x >= _canvas.width or a.cell.y >= _canvas.height:
			_failures += 1
			print("  FAIL wrapped ant outside: ", a.cell)

	# 4) view: pan right (D moves the picture left) and zoom in with Alt's action
	var start_pos := _canvas.position
	Input.action_press(&"pan_right")
	Input.action_press(&"zoom_in")
	await _wait(0.5)
	Input.action_release(&"pan_right")
	Input.action_release(&"zoom_in")
	_check(_canvas.position.x < start_pos.x, "D moves the picture left (%.0f -> %.0f)" % [start_pos.x, _canvas.position.x])
	_check(_canvas.scale.x > 1.5, "zoom in (scale %.2f)" % _canvas.scale.x)
	_main.reset_view()
	_check(_canvas.position == Vector2(512, 384) and is_equal_approx(_canvas.scale.x, 1.0), "Home resets the view")

	# 5) defaults again
	Settings.reset_to_defaults()
	await _wait(0.3)
	_check(Settings.rule_text == Settings.DEFAULT_RULE and Settings.ant_count == 1 and not Settings.wrap_edges
		and Settings.steps_per_frame == 3001, "defaults restored")

	if _screenshot_path != "":
		await _take_screenshot()

	print("AUTOTEST done: %s (%d failures)" % ["PASS" if _failures == 0 else "FAIL", _failures])
	if not OS.has_feature("web"):
		get_tree().quit(1 if _failures > 0 else 0)


func _take_screenshot() -> void:
	# --shot-default: the plain default run (settings were just reset), 100% zoom, 3001 steps per frame
	if not "--shot-default" in OS.get_cmdline_user_args():
		Settings.steps_per_frame = 30000
		Settings.ant_count = _shot_ants
		Settings.start_canvas = Settings.StartCanvas.PICTURE
		Settings.rule_text = _shot_rule
		_main.size_percent = 300.0
	await _wait(6.0)
	if "--shot-options" in OS.get_cmdline_user_args():
		(_main.get_node("UI/Root/OptionsPanel") as OptionsPanel).toggle()
		await _wait(0.3)
	_save_screenshot()


func _save_screenshot() -> void:
	var image := get_viewport().get_texture().get_image()
	if image:
		image.save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)
