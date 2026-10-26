class_name AutoTest
extends Node
## Automated smoke test, active with `-- --autotest` (optionally `--screenshot=<path>`).
## Player 1 drives forward and fires, player 2 turns and fires; prints a summary and quits.

var _elapsed := 0.0
var _screenshot_path := ""
var _screenshot_done := false
var _shots_seen := 0
var _staged := false
var _killed := false
var _start_counts: Array[int] = []


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_start_counts = Game.team_count.duplicate()
	print("AUTOTEST start, tanks per team: ", _start_counts)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	Input.action_press(&"p1_fire")
	Input.action_press(&"p2_fire")
	if not _staged and _elapsed > 1.0:
		_staged = true  # put the two player tanks face to face so shots must hit
		var a := Game.player_tank[1] as Tank
		var b := Game.player_tank[2] as Tank
		a.position = Vector2(700, 600)
		a.angle = 0
		b.position = Vector2(800, 600)
		b.angle = 180000
		print("staged duel")
	if not _staged:
		if int(_elapsed) % 2 == 0:
			Input.action_press(&"p2_left")
			Input.action_release(&"p1_right")
			Input.action_press(&"p1_left")
		else:
			Input.action_release(&"p2_left")
			Input.action_release(&"p1_left")
			Input.action_press(&"p1_right")
	_shots_seen = maxi(_shots_seen, _count_shots())
	if _screenshot_path != "" and not _screenshot_done and _elapsed > 6.0:
		_screenshot_done = true
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)
	if _elapsed > 8.0 and not _killed:
		_killed = true
		var old := Game.player_tank[2]
		(old as Tank).life = -1
		print("killed p2 tank, p1 life=", Game.player_life[1])
	if _elapsed > 12.0:
		print("AUTOTEST done: p2 tank alive=", is_instance_valid(Game.player_tank[2]), " teams=", Game.team_count, " p1 life=", Game.player_life[1], " p2 life=",
				Game.player_life[2], " max simultaneous shots=", _shots_seen, " winner=", Game.winner)
		get_tree().quit()


func _count_shots() -> int:
	var n := 0
	for child in get_parent().get_node("LeftContainer/LeftView/World").get_children():
		if child is Shot:
			n += 1
	return n
