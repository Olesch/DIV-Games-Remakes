extends SceneTree
## Debug helper: title screen -> change difficulty -> start -> back to title (Esc).

var _frames := 0


func _initialize() -> void:
	change_scene_to_file("res://scenes/title.tscn")


func _press(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)


func _process(_delta: float) -> bool:
	_frames += 1
	match _frames:
		5:
			_press(&"difficulty_down")
		10:
			_press(&"difficulty_down")
		15:
			print("difficulty=", root.get_node("Game").difficulty)
			_press(&"start_game")
		40:
			print("scene=", current_scene.name, " cannon_cost=", root.get_node("Game").cannon_cost, " money=", root.get_node("Game").money)
			_press(&"back_to_title")
		60:
			print("scene=", current_scene.name)
			quit()
	return false
