class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest` (optionally `--screenshot=<path>`).
## Drives the real input path (InputEventAction) and checks the main rules, then prints PASS/FAIL and quits.

var main: Node2D
var _t := 0.0
var _step := 0
var _fails := 0
var _screenshot := ""
var _saved := false
var _ships: Array[Ship]


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot = arg.substr("--screenshot=".length())
	_ships = main.get_ships()
	print("AUTOTEST start")


func _press(action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		_fails += 1


func _physics_process(delta: float) -> void:
	_t += delta
	var s0 := _ships[0]
	var s1 := _ships[1]
	match _step:
		0:   # idle ships stay put; P0 heads right, runs into the wall of the start room
			if _t < 0.2:
				return
			_check(s0.cell == Game.level.get_point(1) and s1.cell == Game.level.get_point(2), "ships start on control points 1,2")
			_check(Game.stats[1].weapon == 1 and Game.stats[3].weapon == 1 and Game.stats[0].weapon == 0,
				"P2/P4 spawn on top of a green laser item and pick it up")
			_press("p0_right")
			_step = 1
			_t = 0.0
		1:
			if _t > 2.4:
				var before := s0.cell
				_check(before.x > 300 and before.y == 361, "P0 flew right from the spawn point: %s" % before)
				_check(Game.level.get_index(s0.cell.x + 8, s0.cell.y) != 1, "P0 stopped at a wall (x=%d)" % s0.cell.x)
				_step = 2
				_t = 0.0
		2:   # shoot P1 with a bullet from point-blank range
			s0.teleport(Vector2i(300, 250))
			s1.teleport(Vector2i(340, 250))
			s0.dir = Ship.Dir.RIGHT
			Game.stats[0].weapon = 0
			Game.stats[0].ammo = 99
			_step = 3
		3:
			var life := Game.stats[1].life
			var score := Game.stats[0].score
			_press("p0_fire")
			_step = 4
			_t = 0.0
			set_meta("life", life)
			set_meta("score", score)
			set_meta("ammo", Game.stats[0].ammo)
		4:
			if _t > 0.5:
				_check(Game.stats[1].life == int(get_meta("life")) - 5, "bullet: P1 life 100 -> %d" % Game.stats[1].life)
				_check(Game.stats[0].score == int(get_meta("score")) + 10, "bullet: P0 score +10 -> %d" % Game.stats[0].score)
				_check(Game.stats[0].ammo == int(get_meta("ammo")) - 1, "ammo -1")
				_step = 5
		5:   # ships block each other
			s0.teleport(Vector2i(300, 250))
			s0.dir = Ship.Dir.RIGHT
			s1.teleport(Vector2i(330, 250))
			s1.dir = Ship.Dir.NONE
			_t = 0.0
			_step = 6
		6:
			if _t > 1.0:
				_check(s0.cell.x == 316 and s1.cell.x == 330, "P0 blocked by P1 at distance 14 (x=%d)" % s0.cell.x)
				_step = 7
		7:   # weapon pickup (point 14) by P2
			var p := Game.level.get_point(14)
			_ships[2].teleport(p)
			_t = 0.0
			_step = 8
		8:
			if _t > 0.3:
				var st := Game.stats[2]
				_check(st.weapon == 1 and st.ammo == 10, "P2 picked up green laser: weapon %d ammo %d" % [st.weapon, st.ammo])
				_check(get_tree().get_nodes_in_group("x").is_empty(), "no stray nodes")
				# laser shot, then shoot P3 (laser does 10)
				s0.teleport(Vector2i(300, 250))
				s0.dir = Ship.Dir.NONE
				s1.teleport(Vector2i(500, 250))
				_ships[2].teleport(Vector2i(300, 200))
				_ships[2].dir = Ship.Dir.DOWN
				_ships[3].teleport(Vector2i(300, 230))
				_set_p3_life()
				_press("p2_fire")
				_t = 0.0
				_step = 9
		9:
			if _t > 0.5:
				var l3 := Game.stats[3].life
				_check(l3 == 90, "laser: P3 life -> %d" % l3)
				_check(Game.stats[2].score == 20, "laser: P2 score 20 -> %d" % Game.stats[2].score)
				_step = 10
		10:   # diamond
			var c := main.get_node("Crystal") as Crystal
			var sc := Game.stats[1].score
			set_meta("sc1", sc)
			s1.teleport(Vector2i(c.position))
			_t = 0.0
			_step = 11
		11:
			if _t > 0.3:
				_check(Game.stats[1].score == int(get_meta("sc1")) + 200, "diamond +200 for P1")
				_step = 12
		12:   # leave the maze through the top gap: P0 flies up at x=300
			s0.teleport(Vector2i(300, 40))
			s0.dir = Ship.Dir.UP
			s1.teleport(Vector2i(100, 100))
			_ships[2].teleport(Vector2i(100, 300))
			_ships[3].teleport(Vector2i(560, 300))
			_t = 0.0
			_step = 13
		13:
			if _t > 0.6:
				print("INFO  P0 after top-gap flight: ", s0.cell)
				_step = 14
				_t = 0.0
		14:   # fire all ammo with weapon 3 (no projectile) to check ammo reset
			Game.stats[0].weapon = 3
			Game.stats[0].ammo = 1
			s0.dir = Ship.Dir.RIGHT
			_press("p0_fire")
			_step = 15
		15:
			_check(Game.stats[0].weapon == 0 and Game.stats[0].ammo == 99, "empty special weapon falls back to bullet / 99")
			_step = 16
			_t = 0.0
		16:
			if _screenshot != "" and not _saved:
				s0.teleport(Vector2i(124, 361))
				s0.dir = Ship.Dir.NONE
				s1.teleport(Vector2i(178, 89))
				_ships[2].teleport(Vector2i(434, 300))
				_ships[3].teleport(Vector2i(491, 117))
				for n in [13, 14]:
					var item := (load("res://scenes/pickup.tscn") as PackedScene).instantiate() as Pickup
					item.setup(n, Game.level.get_point(n))
					main.get_node("Items").add_child(item)
				_saved = true
				_t = 0.0
			elif _t > 0.5:
				if _screenshot != "":
					get_viewport().get_texture().get_image().save_png(_screenshot)
					print("screenshot saved: ", _screenshot)
				print("AUTOTEST done: ", "ALL PASS" if _fails == 0 else "%d FAILED" % _fails)
				get_tree().quit()


func _set_p3_life() -> void:
	Game.stats[3].life = 100
	Game.stats[2].score = 0
