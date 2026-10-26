class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest` on the command line (the menu then
## starts a 4-player game by itself). Buys every weapon, holds fire, flies the ships, jumps to both
## bosses, optionally saves a screenshot (`--screenshot=<path>`), prints a summary and quits.
## Run: godot --headless --fixed-fps 400 --path . -- --autotest

var _ticks := 0
var _shot_path := ""
var _shot_done := false
var _phase := 0
var _lives_before := 0
var _snakes_before := 0


func _count_snakes() -> int:
	return Game.world.entities.get_children().filter(func(c: Node) -> bool: return c is Snake).size()


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_shot_path = arg.substr("--screenshot=".length())
	print("AUTOTEST start, players=", Game.player_count)
	for i in Game.player_count:
		for a in ["fire", "right"]:
			Input.action_press(StringName("p%d_%s" % [i + 1, a]))


func _physics_process(_delta: float) -> void:
	_ticks += 1
	# give everybody money, then "press" buy on a rotating slot so every weapon gets bought
	if _ticks % 20 == 0:
		for i in Game.player_count:
			var ps := Game.players[i]
			ps.powers = 1 + (_ticks / 20 + i) % 9
			var ev := InputEventAction.new()
			ev.action = StringName("p%d_buy" % [i + 1])
			ev.pressed = true
			Input.parse_input_event(ev)
			if (_ticks / 20) % 3 == 0:
				var w := InputEventAction.new()
				w.action = StringName("p%d_weapon" % [i + 1])
				w.pressed = true
				Input.parse_input_event(w)
	if _ticks % 60 == 0:
		for i in Game.player_count:
			Input.action_release(StringName("p%d_up" % [i + 1]))
			Input.action_release(StringName("p%d_down" % [i + 1]))
			Input.action_release(StringName("p%d_right" % [i + 1]))
			Input.action_press(StringName("p%d_%s" % [i + 1, "up" if (_ticks / 60) % 2 == 0 else "down"]))
			Input.action_press(StringName("p%d_left" % [i + 1]) if (_ticks / 60) % 3 == 0 else StringName("p%d_right" % [i + 1]))
	# cheats: hold O for 3 ticks, then A+L+E+X for 20 ticks (= 3 waves of two snakes)
	if _ticks == 300:
		_lives_before = Game.players[0].lives
		Input.action_press(&"cheat_max")
	if _ticks == 303:
		Input.action_release(&"cheat_max")
		var ship := Game.ship_of(0)
		print("cheat O: lives +", Game.players[0].lives - _lives_before, " speed=", ship.ship_speed if ship else -1,
			" pods=", Game.players[0].compains, " shield=", Game.players[0].shield)
		_snakes_before = _count_snakes()
		for a in [&"cheat_a", &"cheat_l", &"cheat_e", &"cheat_x"]:
			Input.action_press(a)
	if _ticks == 323:
		for a in [&"cheat_a", &"cheat_l", &"cheat_e", &"cheat_x"]:
			Input.action_release(a)
		print("cheat ALEX: +", _count_snakes() - _snakes_before, " snake segments (expect 36)")
	if _ticks == 600:
		Game.world.level.jump_to("L2")
	if _ticks == 1200:
		Game.world.level.jump_to("L1_boss")
	if _ticks == 2400:
		Game.world.level.jump_to("L2_boss")
	if _shot_path != "" and not _shot_done and _ticks > 700:
		_shot_done = true
		get_viewport().get_texture().get_image().save_png(_shot_path)
		print("screenshot saved: ", _shot_path)
	if _ticks % 400 == 0:
		print("t=", _ticks, " ents=", Game.world.entities.get_child_count(), " lives=",
			Game.players.map(func(p: PlayerState) -> int: return p.lives), " psh=", Game.psh)
	if _ticks % 400 == 0:
		var counts := {}
		for c in Game.world.entities.get_children():
			var n: String = c.get_script().get_global_name() if c.get_script() else c.get_class()
			counts[n] = counts.get(n, 0) + 1
		print("  ", counts)
	if _ticks > 3600:
		print("AUTOTEST done")
		get_tree().quit()
