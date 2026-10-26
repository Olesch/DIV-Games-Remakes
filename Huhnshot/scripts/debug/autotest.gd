class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest`. Aims at live birds and
## targets, reloads, forces bonuses and the end of the round, prints a summary and quits.
## Optional `--screenshot=<path>` saves a gameplay frame.

var _elapsed := 0.0
var _screenshot_path := ""
var _screenshot_done := false
var _cursor: Cursor
var _forced_end := false
var _mg_checked := false
var _bonus_forced := false


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_cursor = get_tree().get_first_node_in_group(&"cursor") as Cursor
	print("AUTOTEST start")


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _cursor == null:
		_cursor = get_parent().get_node("CursorLayer/Cursor") as Cursor
	if Game.over:
		_finish()
		return
	if _elapsed > 25.0 and not _forced_end:
		_forced_end = true
		Game.time = -1
	var target := _pick_target()
	if target != Vector2.INF:
		Game.scroll_x0 = clampi(int(target.x) - 400, 0, Game.MAX_SCROLL)
		var screen := Vector2(clampf(target.x - Game.scroll_x0, 10.0, 790.0), clampf(target.y, 10.0, 590.0))
		_cursor.override_pos = screen
		if Game.ammo <= 0:
			_cursor.reload()
		elif int(_elapsed * 24.0) % 3 == 0:
			_cursor.shoot()
	if _elapsed > 6.0 and not _bonus_forced:
		_bonus_forced = true
		_hit_everything()
	if _elapsed > 12.0 and not _mg_checked:
		_mg_checked = true
		Game.bonus_master = 1
		print("bonus_master forced; flowers=", Game.flowers, " hills=", Game.hills, " castle=", Game.castle)
	if _screenshot_path != "" and not _screenshot_done and _elapsed > 3.0:
		_screenshot_done = true
		get_viewport().get_texture().get_image().save_png(_screenshot_path)
		print("screenshot saved: ", _screenshot_path)


func _pick_target() -> Vector2:
	# shoot special targets first once the birds are plentiful, otherwise birds
	if int(_elapsed) % 4 == 3:
		for item: SpecialItem in get_tree().get_nodes_in_group(&"specials"):
			return item.position
	for bird: Bird in get_tree().get_nodes_in_group(&"birds"):
		return bird.world_position()
	return Vector2.INF


func _finish() -> void:
	print("AUTOTEST done: score=", Game.score, " final=", Game.final_score, " shots=", Game.shots,
		" hits=", Game.hits, " birds_killed=", Game.birds_killed, " accuracy=", Game.accuracy,
		" max_ammo=", Game.max_ammo, " flowers=", Game.flowers, " time=", Game.time,
		" birds=", get_tree().get_nodes_in_group(&"birds").size())
	get_tree().quit()


## Directly destroys every static target to exercise the flower / hill / castle bonus paths.
func _hit_everything() -> void:
	for item: SpecialItem in get_tree().get_nodes_in_group(&"specials"):
		for i in 30:
			if is_instance_valid(item) and not item.is_queued_for_deletion():
				item.hit()
	Game.dead_bird_bonus = 1
	Game.combo_bonus = -1
	Game.time_bonus = -1
	print("targets destroyed: flowers=", Game.flowers, " hills=", Game.hills, " castle=", Game.castle)
