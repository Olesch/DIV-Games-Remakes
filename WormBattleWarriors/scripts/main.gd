extends Node2D
## Game scene: board, cursor and HUD. `-- --autotest` runs the headless self test.


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(preload("res://scripts/debug/autotest.gd").new())
