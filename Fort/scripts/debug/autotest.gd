extends Node
## Headless smoke test, only active with `-- --autotest`. Shoots at random enemies for a few
## seconds, lets the rest reach the fort, optionally saves a screenshot (`--screenshot=<path>`)
## and prints a summary. Writes nothing to user://.

const DURATION := 10.0

var _elapsed := 0.0
var _fire_clock := 0.0
var _shots := 0
var _screenshot_path := ""
var _screenshot_done := false


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	print("AUTOTEST start")


func _physics_process(delta: float) -> void:
	_elapsed += delta
	_fire_clock += delta
	var fort := get_tree().get_first_node_in_group(&"fort") as Fort
	var enemies := get_tree().get_nodes_in_group(&"enemies")
	# fire at a random enemy every 0.3 s during the first 7 s (then let the rest hit the fort)
	if _elapsed < 7.0 and _fire_clock > 0.3 and fort and not enemies.is_empty():
		_fire_clock = 0.0
		var target: Node2D = enemies.pick_random()
		fort.fire_at(target.position)
		_shots += 1
	if _screenshot_path != "" and not _screenshot_done and _elapsed > 4.0:
		_screenshot_done = true
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)
	if _elapsed > DURATION:
		print("AUTOTEST done: shots_fired=", _shots, " enemies_killed=", Game.enemies_shot,
				" fort_damage=", Game.damage, " enemies_alive=", enemies.size(),
				" bullets_alive=", get_tree().get_nodes_in_group(&"shots").size())
		if Game.enemies_shot == 0 or Game.damage == 0:
			push_error("AUTOTEST FAILED: expected both kills and fort damage")
		set_physics_process(false)
		if not OS.has_feature("web"):
			get_tree().quit()
