class_name AutoTest
extends Node
## Headless smoke test, only with `-- --autotest`. Checks the line routine, sends the "2" key
## action, counts the drawn pixels and checks that further keys are ignored. Optionally saves a
## screenshot (`--screenshot=<path>`, an explicit path; nothing is written to user://).
## Quits unless running in a web build.

var _failures := 0


func _ready() -> void:
	_run.call_deferred()


func _check(cond: bool, what: String) -> void:
	if not cond:
		_failures += 1
		printerr("AUTOTEST FAIL: ", what)


func _lit(image: Image) -> int:
	var n := 0
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.0:
				n += 1
	return n


func _run() -> void:
	var main := get_parent()
	var canvas: PixelCanvas = main.canvas
	# line routine on a scratch canvas: endpoints included, one pixel per major-axis step
	var scratch := PixelCanvas.new()
	scratch.draw_line_div(10, 10, 20, 13)
	_check(_lit(scratch.image) == 11, "shallow line has 11 pixels")
	_check(scratch.image.get_pixel(20, 13).a > 0.0, "line reaches its end point")
	scratch.draw_line_div(50, 60, 47, 40)
	_check(scratch.image.get_pixel(47, 40).a > 0.0, "steep line reaches its end point")
	scratch.draw_line_div(5, 5, 5, 5)  # would hang in the original
	scratch.free()

	_check(_lit(canvas.image) == 0, "screen starts empty")
	var ev := InputEventAction.new()
	ev.action = &"draw_koch"
	ev.pressed = true
	Input.parse_input_event(ev)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(main.drawn, "key 2 draws")
	var lit := _lit(canvas.image)
	print("lit pixels after drawing: ", lit)
	_check(lit > 10000, "Sierpinski triangle drawn")
	for v: Vector2i in [Vector2i(512, 100), Vector2i(924, 668), Vector2i(100, 668), Vector2i(306, 384)]:
		_check(canvas.image.get_pixel(v.x, v.y).a > 0.0, "pixel at %s" % v)
	# further keys change nothing
	var before := canvas.image.get_data()
	var ev1 := InputEventAction.new()
	ev1.action = &"draw_sierpinski"
	ev1.pressed = true
	Input.parse_input_event(ev1)
	await get_tree().process_frame
	_check(canvas.image.get_data() == before, "second key press ignored")

	await get_tree().create_timer(0.3).timeout
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(arg.substr("--screenshot=".length()))
			print("screenshot saved")
	print("AUTOTEST done, failures=", _failures)
	if not OS.has_feature("web"):
		get_tree().quit(1 if _failures > 0 else 0)
