extends Node
## Automated smoke test, only active with `-- --autotest` on the command line.
## Fast-forwards the simulation (raises the physics tick rate; the ball logic is per tick) for SIM_SECONDS of game time, checks that balls were
## released, stuck and escaped, optionally saves a screenshot after SCREENSHOT_SECONDS (`--screenshot=<path>`, never user://),
## presses R and checks that the picture was reset, then quits (desktop only).

const SIM_SECONDS := 150.0
const SCREENSHOT_SECONDS := 45.0
const TICKS_PER_SECOND := 100

var _screenshot_path := ""
var _screenshot_done := false
var _start_tick := 0
var _restarted := false
var _restart_tick := 0
var _failures: Array[String] = []

@onready var _main: Node = get_parent()


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	Engine.max_physics_steps_per_frame = 100
	Engine.physics_ticks_per_second = TICKS_PER_SECOND * 15
	_start_tick = Engine.get_physics_frames()
	print("AUTOTEST start")


func _physics_process(_delta: float) -> void:
	var ticks := Engine.get_physics_frames() - _start_tick
	var cluster: Cluster = _main.cluster
	var spawner: Spawner = _main.spawner
	if not _restarted:
		if ticks % 2000 == 0:
			print("  t=%5.1fs spawned=%d stuck=%d escaped=%d flying=%d" % [ticks / float(TICKS_PER_SECOND),
				spawner.spawned, cluster.stuck_count, spawner.escaped,
				get_tree().get_nodes_in_group(&"flying_balls").size()])
		if _screenshot_path != "" and not _screenshot_done and ticks >= SCREENSHOT_SECONDS * TICKS_PER_SECOND:
			_screenshot_done = true  # last rendered frame
			var image := get_viewport().get_texture().get_image()
			if image and image.save_png(_screenshot_path) == OK:
				print("screenshot saved: ", _screenshot_path)
		if ticks < SIM_SECONDS * TICKS_PER_SECOND:
			return
		var flying := get_tree().get_nodes_in_group(&"flying_balls").size()
		print("AUTOTEST after %.0fs: spawned=%d stuck=%d escaped=%d flying=%d" % [SIM_SECONDS,
			spawner.spawned, cluster.stuck_count, spawner.escaped, flying])
		_check(spawner.spawned > 1000, "too few balls spawned")
		_check(cluster.stuck_count > 500, "too few balls stuck")
		_check(spawner.escaped > 0, "no ball escaped (direction quantisation should make early balls miss)")
		_check(flying < 30, "flying balls pile up")
		_check(cluster.stuck_count - 1 + spawner.escaped + flying == spawner.spawned, "ball bookkeeping mismatch")
		Engine.physics_ticks_per_second = TICKS_PER_SECOND
		_restarted = true
		var press := InputEventAction.new()
		press.action = &"restart"
		press.pressed = true
		Input.parse_input_event(press)
		_restart_tick = Engine.get_physics_frames()
		return
	if Engine.get_physics_frames() - _restart_tick == 2:
		var cluster_after: Cluster = _main.cluster
		_check(cluster_after.stuck_count < 10, "restart did not clear the aggregate (stuck=%d)" % cluster_after.stuck_count)
		_check(spawner.spawned <= 2, "restart did not reset the spawner")
		print("AUTOTEST after restart: stuck=%d spawned=%d" % [cluster_after.stuck_count, spawner.spawned])
		if _failures.is_empty():
			print("AUTOTEST PASSED")
		else:
			print("AUTOTEST FAILED: ", _failures)
		if not OS.has_feature("web"):
			get_tree().quit(0 if _failures.is_empty() else 1)


func _check(ok: bool, message: String) -> void:
	if not ok:
		_failures.append(message)
		push_error("AUTOTEST: " + message)
