extends SceneTree
## Debug: walks through the six splash pages with Enter/Space and checks that the battlefield starts.
##   godot --headless --path . --script res://scripts/debug/title_flow.gd

var _frame := 0
var _pages_seen: Array[int] = []


func _initialize() -> void:
	change_scene_to_file("res://scenes/splash.tscn")


func _physics_process(_delta: float) -> bool:
	_frame += 1
	var scene := current_scene
	if scene == null:
		return false
	if scene.name == "Splash":
		var page := scene.get("_page") as int
		if _frame % 6 == 1:
			_send(true)
		elif _frame % 6 == 3:
			_send(false)
			if _pages_seen.is_empty() or _pages_seen[-1] != page:
				_pages_seen.append(page)
	elif scene.name == "World" and _frame % 6 == 5:
		print("splash pages seen: ", _pages_seen, " -> world started at frame ", _frame)
		quit(0 if _pages_seen.size() == 6 else 1)
	if _frame > 600:
		print("TIMEOUT pages=", _pages_seen)
		quit(1)
	return false


func _send(pressed: bool) -> void:
	var ev := InputEventAction.new()
	ev.action = &"confirm"
	ev.pressed = pressed
	Input.parse_input_event(ev)
