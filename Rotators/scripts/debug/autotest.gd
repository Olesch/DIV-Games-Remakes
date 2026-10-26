class_name AutoTest
extends Node
## Automated smoke test, only active with `-- --autotest` on the command line (desktop only).
## Lets the original pattern run, checks the chain and the trail, drives the options overlay
## with simulated key presses, tries every speed mode, randomise and reset, optionally saves a
## screenshot (`--screenshot=<path>`, taken of the original pattern) and quits.
## Options are not saved to user:// while this runs (see Options._persist).

var _main: Node
var _elapsed := 0.0
var _phase := 0
var _screenshot_path := ""
var _failures: Array[String] = []


func _ready() -> void:
	_main = get_parent()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_check(Options.is_default(), "starts with the original settings")
	_check(_main.rotator_count() == 22, "22 rotators (got %d)" % _main.rotator_count())
	print("AUTOTEST start: rotators=", _main.rotator_count(), " fps=", Engine.physics_ticks_per_second)


func _process(delta: float) -> void:
	_elapsed += delta
	match _phase:
		0:
			var wait := 8.0 if _screenshot_path != "" else 2.0
			if _elapsed > wait:
				_check(_main.dots_drawn() > 1000, "trail dots drawn (%d)" % _main.dots_drawn())
				if _screenshot_path != "":
					get_viewport().get_texture().get_image().save_png(_screenshot_path)
					print("screenshot saved: ", _screenshot_path)
				_next()
		1:
			_test_options_overlay()
			_next()
		2:
			if _elapsed > 1.0:
				_test_modes()
				_next()
		3:
			if _elapsed > 1.0:
				_check(_main.dots_drawn() > 0, "random pattern draws")
				Options.reset_to_original()
				_check(Options.is_default(), "reset restores the original")
				_check(_main.rotator_count() == 22, "reset rebuilds 22 rotators")
				_finish()


func _next() -> void:
	_phase += 1
	_elapsed = 0.0


func _test_options_overlay() -> void:
	_press(KEY_TAB)
	var panel: OptionsPanel = _main.options_panel()
	_check(panel.visible, "Tab opens the options")
	_press(KEY_DOWN)  # -> Rotators row
	_check(panel.selected_row() == 1, "Down selects the next row")
	_press(KEY_RIGHT)
	_press(KEY_RIGHT)
	_check(Options.get_value(&"chain_length") == 22, "Right adds rotators")
	_check(_main.rotator_count() == 24, "pattern rebuilt with 24 rotators (got %d)" % _main.rotator_count())
	_press(KEY_DOWN)
	_press(KEY_LEFT)  # first speed 5.0 -> 4.5
	_check(Options.get_value(&"first_speed") == 4500, "Left lowers the first speed")
	_press(KEY_UP)
	_press(KEY_UP)
	_press(KEY_LEFT)  # speed mode Counted -> Table
	_check(Options.get_value(&"speed_mode") == Options.SpeedMode.TABLE, "speed mode cycles")
	_press(KEY_ESCAPE)
	_check(not panel.visible, "Esc closes the options")
	print("options after keys: ", Options.values)


func _test_modes() -> void:
	Options.reset_to_original()
	Options.set_value(&"speed_mode", Options.SpeedMode.TABLE)
	var speeds: Array[int] = []
	for i in Options.rotator_count():
		speeds.append(Options.table_speed(i))
	print("table speeds (with the original overrun): ", speeds)
	for trails in Options.Trails.values():
		Options.set_value(&"trails", trails)
	Options.set_value(&"show_rotators", false)
	Options.set_value(&"trail_colour", Options.TrailColour.RAINBOW)
	Options.set_value(&"chain_length", 0)
	_check(_main.rotator_count() == 2, "chain length 0 still makes 2 rotators")
	Options.randomise()
	Options.set_value(&"speed_mode", Options.SpeedMode.RANDOM)
	Options.set_value(&"trails", Options.Trails.ALL)
	_check(_main.rotator_count() == Options.rotator_count(), "random pattern built")


func _press(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		Input.parse_input_event(event)
	Input.flush_buffered_events()


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures.append(what)
		push_error("AUTOTEST FAIL: " + what)


func _finish() -> void:
	print("AUTOTEST done: ", "OK" if _failures.is_empty() else "FAILED %s" % [_failures],
		"  rotators=", _main.rotator_count(), " dots=", _main.dots_drawn())
	if not OS.has_feature("web"):
		get_tree().quit(0 if _failures.is_empty() else 1)
