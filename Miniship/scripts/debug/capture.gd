extends SceneTree
## Debug helper: runs a PC-vs-PC match windowed and saves a PNG.
## godot --path . --script res://scripts/debug/capture.gd -- <out.png> [seconds] [menu]

var _frames := 0
var _out := ""
var _wait := 10000
var _world: Node


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	_out = args[0]
	if args.size() > 1:
		_wait = int(float(args[1]) * 1000.0)
	var game := root.get_node("Game")
	if args.size() > 2 and args[2] == "menu":
		root.add_child((load("res://scenes/menu.tscn") as PackedScene).instantiate())
		return
	for i in 4:
		game.ship_mode[i] = [2, 3, 5, 4][i]
	game.asteroids = 5
	game.particles = 2
	game.play_type = 2 if args.size() > 2 and args[2] == "flag" else 0
	seed(7)
	_world = (load("res://scenes/world.tscn") as PackedScene).instantiate()
	root.add_child(_world)


func _process(_delta: float) -> bool:
	var ready_to_shoot: bool = _world == null or (_world.phase == 2 and root.get_node("Game").alive_ships().size() >= 3 and root.get_node("Game").effects.particle_count() > 40)
	if Time.get_ticks_msec() >= _wait and ready_to_shoot:
		root.get_viewport().get_texture().get_image().save_png(_out)
		quit()
	return false
