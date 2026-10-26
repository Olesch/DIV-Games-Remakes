class_name AutoTest
extends Node
## Headless smoke test, only active with `-- --autotest` (added by main.gd).
## Plays: clicks the lowest ball every few ticks, holds "blow" for a while, then stops clicking
## until a ball escapes (game over). Optional `--screenshot=<path>`. Prints a summary and quits.

var _ticks := 0
var _screenshot_path := ""
var _screenshot_done := false
var _clicks := 0
var _main: Node2D
var _saw_game_over := false


func _ready() -> void:
	_main = get_parent() as Node2D
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	# start at a harder level so something happens quickly
	Game.level = 6
	Game.level_changed.emit()
	Engine.time_scale = 8.0
	print("AUTOTEST start ", OS.get_cmdline_user_args())


func _physics_process(_delta: float) -> void:
	_ticks += 1
	var balls := get_tree().get_nodes_in_group(&"balls")
	if _ticks < 400 and _ticks % 4 == 0 and not balls.is_empty():
		var target := balls[0] as Ball
		for b: Node in balls:
			if (b as Ball).position.y < target.position.y:
				target = b as Ball
		_main.click(target.position.round())
		_clicks += 1
	if _ticks > 100 and _ticks < 160:
		Input.action_press(&"blow")
	else:
		Input.action_release(&"blow")
	if _screenshot_path != "" and not _screenshot_done and Time.get_ticks_msec() > 4000:
		_screenshot_done = true
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)
	if _main.get("_game_over"):
		_saw_game_over = true
	if _ticks > 1500 or (_saw_game_over and _ticks > 600):
		print("AUTOTEST done: ticks=", _ticks, " clicks=", _clicks, " score=", Game.score,
			" level=", Game.level, " balls=", balls.size(), " game_over=", _saw_game_over,
			" hiscore=", Game.hiscore)
		get_tree().quit()
