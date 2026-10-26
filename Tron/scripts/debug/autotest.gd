class_name AutoTest
extends Node
## Automated smoke test, only active with `-- --autotest`.  Steers the cycles around,
## checks that trails get drawn and crashes are detected, optionally saves a screenshot
## (`--screenshot=<path>`), prints a summary and quits.

var _ticks := 0
var _shot_path := ""
var _shot_done := false
var _arena: Arena
var _red: LightCycle
var _blue: LightCycle


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_shot_path = arg.substr("--screenshot=".length())
	_arena = get_parent() as Arena
	_red = _arena.get_node("CycleOne") as LightCycle
	_blue = _arena.get_node("CycleTwo") as LightCycle
	print("AUTOTEST start")


func _turn(cycle: LightCycle, left: bool) -> void:
	cycle._pending_turn += 1 if left else -1


func _physics_process(_delta: float) -> void:
	_ticks += 1
	# Red zig-zags (down, right, down ...) every 20 ticks, blue spirals left/up.
	if _ticks % 20 == 0:
		_turn(_red, _ticks % 40 == 0)
		_turn(_blue, _ticks % 60 != 0)
	if _shot_path != "" and not _shot_done and _ticks == 35:
		_shot_done = true
		get_viewport().get_texture().get_image().save_png(_shot_path)
	if _ticks >= 600 or (not _red.alive and not _blue.alive):
		_finish()


func _finish() -> void:
	var red_px := _arena.count_pixels(22)
	var blue_px := _arena.count_pixels(54)
	print("AUTOTEST red alive=%s px=%d cell=%s | blue alive=%s px=%d cell=%s ticks=%d" % [
		_red.alive, red_px, _red.cell, _blue.alive, blue_px, _blue.cell, _ticks])
	var ok := red_px > 100 and blue_px > 100
	# Force a self-collision test: reverse red onto its own trail.
	if _red.alive:
		_turn(_red, true)
		_turn(_red, true)
		for i in 5:
			_red._step()
		ok = ok and not _red.alive
		print("AUTOTEST reverse-into-own-trail crash: ", not _red.alive)
	print("AUTOTEST ", "PASS" if ok else "FAIL")
	get_tree().quit(0 if ok else 1)
