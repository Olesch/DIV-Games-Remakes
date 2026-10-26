extends Node
## Headless/automated smoke test, only active with `-- --autotest` on the command line.
## Drives the real input actions tick by tick (one physics tick = one DIV frame): previews,
## a full draw (checked against the iteration formula), panning, zooming into the 32-bit
## overflow range, the WASD preview keys, the clear key; optionally saves a screenshot after
## the full draw (`--screenshot=<path>`, never inside user://), prints a summary and quits
## (not on web). It writes no files of its own.

const HELD_ACTIONS: Array[StringName] = [&"preview_zoom_out", &"zoom_out", &"move_up", &"move_left",
		&"color_mode_up"]

var _canvas: FractalCanvas
var _main: Node
var _phase := 0
var _ticks := 0         # ticks spent in the current phase
var _failures := 0
var _draw_start_msec := 0
var _screenshot_path := ""
var _shot_view := Vector3i.ZERO


func _ready() -> void:
	_main = get_parent()
	_canvas = _main.get_node("FractalCanvas") as FractalCanvas
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
		elif arg.begins_with("--shot-view="):  # zoom,xshi,yshi for the screenshot's full draw
			var v := arg.substr("--shot-view=".length()).split(",")
			_shot_view = Vector3i(int(v[0]), int(v[1]), int(v[2]))
	print("AUTOTEST start")


func _physics_process(_delta: float) -> void:
	_ticks += 1
	match _phase:
		0:  # F2 preview of the centre half
			if _tap(&"draw_preview_half"):
				_next()
		1:
			if _idle():
				_check_samples(&"F2 preview", 5, 2)
				_next()
		2:  # F1 full picture
			if _ticks == 1 and _shot_view != Vector3i.ZERO:
				_canvas.zoom = _shot_view.x
				_canvas.shift_x = _shot_view.y
				_canvas.shift_y = _shot_view.z
			if _tap(&"draw_full"):
				_draw_start_msec = Time.get_ticks_msec()
				_next()
		3:
			if _idle():
				print("full draw took ", Time.get_ticks_msec() - _draw_start_msec, " ms")
				_check_samples(&"F1 full draw", 1, 1)
				_save_screenshot()
				if _shot_view == Vector3i.ZERO:
					_expect(_canvas.color_index_at(512, 384) == 240, "centre (0,0) is inside the set: colour 240")
				_canvas.zoom = 100
				_canvas.shift_x = 0
				_canvas.shift_y = 0
				_next()
		4:  # two arrow-right frames and one + frame: view only
			if _ticks <= 2:
				Input.action_press(&"move_right")
			elif _ticks == 3:
				Input.action_release(&"move_right")
				Input.action_press(&"zoom_in")
			else:
				Input.action_release(&"zoom_in")
				_expect(_canvas.zoom == 150 and _canvas.shift_x == 300 and _canvas.shift_y == 0,
						"arrows/+ -> zoom 150, xshi 300 (got %d, %d)" % [_canvas.zoom, _canvas.shift_x])
				_expect(not _canvas.is_drawing(), "arrows/+ do not draw")
				_next()
		5:  # F3 preview
			if _tap(&"draw_preview_third"):
				_next()
		6:
			if _idle():
				_check_samples(&"F3 preview", 10, 3)
				_next()
		7:  # D: move right + preview
			if _tap(&"preview_right"):
				_expect(_canvas.shift_x == 400, "D moves right (xshi=%d)" % _canvas.shift_x)
				_expect(_canvas.is_drawing(), "D starts a preview")
				_next()
		8:
			if _idle():
				_check_samples(&"D preview", 5, 6)
				_next()
		9:  # hold 1 for 30 frames: zoom far past the 32-bit range, previews whenever idle
			if _ticks <= 30:
				Input.action_press(&"preview_zoom_in")
			else:
				Input.action_release(&"preview_zoom_in")
				print("zoom after holding 1 for 30 frames: ", _canvas.zoom, " xshi=", _canvas.shift_x)
				_next()
		10:
			if _idle():
				_next()
		11:
			if _tap(&"draw_preview_half"):
				_next()
		12:
			if _idle():
				_check_samples(&"overflow preview", 5, 2)
				_next()
		13:  # hold Q, -, up, left and 3 for 12 frames
			if _ticks <= 12:
				for a: StringName in HELD_ACTIONS:
					Input.action_press(a)
			else:
				for a: StringName in HELD_ACTIONS:
					Input.action_release(a)
				_expect(_main.get("color_mode") == 13, "3 raises malen (got %s)" % _main.get("color_mode"))
				print("view after backing out: zoom ", _canvas.zoom, " shift ", _canvas.shift_x, ",", _canvas.shift_y)
				_next()
		14:
			if _idle():
				_next()
		15:
			if _tap(&"clear_screen"):
				_expect(_canvas.color_index_at(0, 0) == 1 and _canvas.color_index_at(1023, 767) == 1
						and _canvas.color_index_at(512, 384) == 1, "F4 fills the screen with colour 1")
				_next()
		16:
			_finish()


# ----------------------------------------------------------------- helpers

## Presses the action for exactly one tick; true on the tick it is released.
func _tap(action: StringName) -> bool:
	if not Input.is_action_pressed(action):
		Input.action_press(action)
		return false
	Input.action_release(action)
	return true


func _idle() -> bool:
	return not _canvas.is_drawing()


func _next() -> void:
	_phase += 1
	_ticks = 0


func _expect(ok: bool, what: String) -> void:
	if ok:
		print("  ok   ", what)
	else:
		_failures += 1
		print("  FAIL ", what)


## Re-computes random points of the area that was just drawn (the same grid as the original
## Draw loops) and compares them with the screen.
func _check_samples(label: StringName, step: int, divisor: int) -> void:
	var half_w := FractalCanvas.HALF_W / divisor
	var half_h := FractalCanvas.HALF_H / divisor
	var columns := (2 * half_w + step - 1) / step
	var rows := (2 * half_h + step - 1) / step
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var bad := 0
	for i in 400:
		var x := -half_w + rng.randi_range(0, columns - 1) * step
		var y := -half_h + rng.randi_range(0, rows - 1) * step
		var expected := _canvas.point_color(x + _canvas.shift_x, y + _canvas.shift_y)
		if _canvas.color_index_at(x + FractalCanvas.HALF_W, y + FractalCanvas.HALF_H) != expected:
			bad += 1
	_expect(bad == 0, "%s matches the formula (zoom %d, shift %d,%d, %d bad of 400)" %
			[label, _canvas.zoom, _canvas.shift_x, _canvas.shift_y, bad])


func _save_screenshot() -> void:
	if _screenshot_path == "" or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image:
		image.save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)


func _finish() -> void:
	print("user:// contains files=", DirAccess.get_files_at("user://"),
			" dirs=", DirAccess.get_directories_at("user://"))
	print("AUTOTEST done: %s, failures=%d" % ["PASS" if _failures == 0 else "FAIL", _failures])
	set_physics_process(false)
	if not OS.has_feature("web"):
		get_tree().quit(1 if _failures > 0 else 0)
