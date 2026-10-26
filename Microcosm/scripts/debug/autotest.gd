class_name AutoTest
extends Node
## Headless/automated smoke test, only active with `-- --autotest` on the command line.
## Buys everything, fires both cannons at meteors, flies the second ship, forces the harder
## meteor kinds, optionally saves a screenshot (`--screenshot=<path>`), prints a summary and quits.

var _elapsed := 0.0
var _shots_fired := 0
var _screenshot_path := ""
var _screenshot_done := false
var _atom_done := false
var _crosshair: Crosshair


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_crosshair = get_tree().get_first_node_in_group(&"crosshair") as Crosshair
	if _crosshair:
		_crosshair.follow_mouse = false
	Game.money = 30000
	Game.ramp = 3500
	Game.super_meteors = 3
	print("AUTOTEST start, difficulty=", Game.difficulty)
	_buy_sequence()


func _buy_sequence() -> void:
	# cannons, rockets, reload, breeding, potion limit, magnet, birds, potions, duks, second ship
	for i in 4:
		Game.try_buy(Defs.Item.LEFT_CANNON)
		Game.try_buy(Defs.Item.RIGHT_CANNON)
	for item in [Defs.Item.RELOAD, Defs.Item.RELOAD, Defs.Item.BIRD_BREEDING, Defs.Item.POTION_LIMIT,
			Defs.Item.ROCKET, Defs.Item.ROCKET, Defs.Item.ROCKET, Defs.Item.MAGNET, Defs.Item.SECOND_PLAYER]:
		print("buy ", Defs.Item.keys()[item], " -> ", Game.try_buy(item), "  money=", Game.money)
	for i in 6:
		Game.try_buy(Defs.Item.BIRD)
		Game.try_buy(Defs.Item.POTION)
		Game.try_buy(Defs.Item.DUK)
	Game.money = 30000
	# the three rocket upgrades eat all ammo capacity; give it back so the test can keep shooting
	Game.ammo_max = [6, 6]
	Game.ammo = [6, 6]
	Game.ammo_changed.emit()
	print("state: rocket=", Game.super_rocket, " ammo_max=", Game.ammo_max, " birds=", Game.birds_amount,
		" potions=", Game.potions_amount)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	# aim at the lowest meteor and fire alternately
	var meteors := get_tree().get_nodes_in_group(&"meteors")
	if _crosshair and not meteors.is_empty():
		var target: Meteor = meteors[0]
		for m: Meteor in meteors:
			if m.position.y > target.position.y:
				target = m
		_crosshair.position = target.position
	var phase := int(_elapsed * 6.0) % 2
	if "--nofire" in OS.get_cmdline_user_args():
		pass  # let meteors reach the ground and the Duks
	elif phase == 0:
		Input.action_press(&"fire_left")
		Input.action_release(&"fire_right")
	else:
		Input.action_release(&"fire_left")
		Input.action_press(&"fire_right")
	Input.action_press(&"p2_up")
	Input.action_press(&"p2_right")
	Input.action_press(&"p2_fire")
	Game.super_rocket = int(_elapsed / 3.0) % 4  # exercise every rocket type
	if _elapsed > 9.0 and not _atom_done:
		_atom_done = true
		print("atom buy -> ", Game.try_buy(Defs.Item.ATOM), " meteors before: ", meteors.size())

	if _screenshot_path != "" and not _screenshot_done and _elapsed > 4.0:
		_screenshot_done = true
		var image := get_viewport().get_texture().get_image()
		if image:
			image.save_png(_screenshot_path)
			print("screenshot saved: ", _screenshot_path)
	if _elapsed > 12.0:
		print("AUTOTEST done: meteors=", get_tree().get_nodes_in_group(&"meteors").size(),
			" duks=", get_tree().get_nodes_in_group(&"duks").size(),
			" shots=", get_tree().get_nodes_in_group(&"shots").size(),
			" money=", Game.money, " ammo=", Game.ammo, " ramp=", Game.ramp)
		get_tree().quit()
