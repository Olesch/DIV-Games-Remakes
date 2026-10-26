class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest` on the command line.
## Plays a two-player game with held keys, forces cannonball hits until a rider dies,
## checks scoring / game over / hiscore saving, then a one-player run. Optional
## `--screenshot=<path>` saves a gameplay frame. Prints a summary and quits (exit code 1 on failures).

var _main: Main
var _tick := 0
var _phase := 0
var _phase_tick := 0
var _screenshot_path := ""
var _errors: Array[String] = []
var _min_wind := 0
var _max_wind := 0
var _hiscore2_before := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_main = get_parent() as Main
	print("AUTOTEST start")


func _check(cond: bool, message: String) -> void:
	if not cond:
		_errors.append(message)
		print("FAIL: ", message)


func _physics_process(_delta: float) -> void:
	_tick += 1
	_phase_tick += 1
	_min_wind = mini(_min_wind, Game.wind)
	_max_wind = maxi(_max_wind, Game.wind)
	match _phase:
		0:  # menu -> start two players
			if _phase_tick == 5:
				_check(_main.state == Main.State.MENU, "starts in menu")
				_hiscore2_before = Game.hiscores[2]
				_main.start_game(2)
				_check(_main.state == Main.State.PLAYING, "2p game started")
				_check(get_tree().get_nodes_in_group(&"players").size() == 2, "two riders")
				_next()
		1:  # steer both riders, wait for cannonballs and score
			Input.action_press(&"p1_right")
			Input.action_press(&"p2_left")
			if _phase_tick == 60:
				for r: Player in get_tree().get_nodes_in_group(&"players"):
					_check(absi(r.x_inc) > 0, "rider %d has speed" % r.player_number)
			if _phase_tick > 150:
				_check(Game.score >= 2, "score grows (score=%d)" % Game.score)
				_check(get_tree().get_nodes_in_group(&"cannonballs").size() > 0, "cannonballs exist")
				if _screenshot_path != "":
					var image := get_viewport().get_texture().get_image()
					if image:
						image.save_png(_screenshot_path)
						print("screenshot saved: ", _screenshot_path)
				Input.action_release(&"p1_right")
				Input.action_release(&"p2_left")
				_next()
		2:  # drop huge cannonballs on rider 1 until it dies (4 hits, 24 frame cooldown)
			var rider := _rider(1)
			if rider != null:
				if _phase_tick % 30 == 1:
					var ball := _main.battery.fire(rider.x, 0, 0, 100)
					ball.y = rider.y
					ball.y_inc = 0
					ball.position = Vector2(ball.x, ball.y)
				if _phase_tick > 400:
					_check(false, "rider 1 never died")
					_next()
			else:
				_check(_main.state == Main.State.GAME_OVER, "game over after first death")
				_check(_rider(2) != null, "other rider keeps flying")
				Game.score = _hiscore2_before + 5
				_next()
		3:  # next cannon shot shows the final score and saves the new hiscore
			if _phase_tick > 120:
				_check(Game.hiscores[2] == _hiscore2_before + 5, "2p hiscore saved (%d)" % Game.hiscores[2])
				_main.back_to_menu()
				_check(_main.state == Main.State.MENU, "back to menu")
				_next()
		4:  # one player run, ended with Esc
			if _phase_tick == 5:
				_main.start_game(1)
				_check(Game.score == 0, "score reset")
				_check(get_tree().get_nodes_in_group(&"players").size() == 1, "one rider")
			if _phase_tick > 5:
				Input.action_press(&"p1_left")
			if _phase_tick == 200:
				_check(Game.score >= 2, "1p score grows (%d)" % Game.score)
				_main.end_game()  # as if Esc were pressed
				_check(_main.state == Main.State.GAME_OVER, "esc ends run")
				Input.action_release(&"p1_left")
				_next()
		5:
			if _phase_tick > 60:
				print("AUTOTEST done: ticks=", _tick, " wind range=", _min_wind, "..", _max_wind,
					" hiscores=", Game.hiscores, " failures=", _errors.size())
				get_tree().quit(1 if _errors.size() > 0 else 0)


func _rider(number: int) -> Player:
	for r: Player in get_tree().get_nodes_in_group(&"players"):
		if r.player_number == number and not r.is_queued_for_deletion():
			return r
	return null


func _next() -> void:
	_phase += 1
	_phase_tick = 0


func _exit_tree() -> void:
	print("AUTOTEST exit: tick=", _tick, " phase=", _phase, " score=", Game.score)
