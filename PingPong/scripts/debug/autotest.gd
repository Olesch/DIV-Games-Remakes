extends Node
## Automated smoke test, only active with `-- --autotest` (optionally `--screenshot=<path>`).
## Checks ball release, bat movement/clamping, bat bounce, scoring and the win banner, then quits.

var _ticks := 0
var _screenshot_path := ""
var _failures := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	print("AUTOTEST start")


func _check(cond: bool, what: String) -> void:
	print(("ok   " if cond else "FAIL ") + what)
	if not cond:
		_failures += 1


func _physics_process(_delta: float) -> void:
	_ticks += 1
	var bat1: Bat = get_parent().get_node("Bat1")
	var bat2: Bat = get_parent().get_node("Bat2")
	match _ticks:
		2:
			Input.action_press(&"p1_up")
			Input.action_press(&"p2_down")
		40:
			_check(get_tree().get_nodes_in_group(&"none").size() == 0, "no group errors")
			_check(get_parent().get_node("Balls").get_child_count() == 70, "70 balls released (%d)" % get_parent().get_node("Balls").get_child_count())
			_check(bat1.position.y == 32.0, "bat1 stops at 32 (DIV steps of 16 from 240) (%s)" % bat1.position.y)
			_check(bat2.position.y == 448.0, "bat2 stops at 448 (%s)" % bat2.position.y)
			Input.action_release(&"p1_up")
			Input.action_release(&"p2_down")
		145:
			if _screenshot_path != "":
				get_viewport().get_texture().get_image().save_png(_screenshot_path)
				print("screenshot saved: ", _screenshot_path)
		150:
			var total: int = Game.points[0] + Game.points[1]
			_check(total > 0, "points scored (%s)" % [Game.points])
			var bounced := 0
			for b: Ball in get_parent().get_node("Balls").get_children():
				if b.position.x > -8 and b.position.x < 648:
					bounced += 1
			_check(bounced > 0, "balls still in play (%d)" % bounced)
			Game.points = [0, 0]
			Game.points[1] = Game.win_margin + 1
			Game.ball_out(-1)  # player 1 missed -> player 2 scores, pushing past the margin
			_check(Game.winner == 2, "player 2 wins")
			_check(get_parent().get_node("Banner").get_child_count() == 5, "banner shown")
		170:
			print("AUTOTEST done, failures=", _failures)
			get_tree().quit(1 if _failures > 0 else 0)
