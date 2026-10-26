extends Node
## Root of the game: world (tile map, hero), water background, HUD, night fader.
## `-- --autotest [--screenshot=file.png]` attaches the debug autotest.


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		var test := preload("res://scripts/debug/autotest.gd").new()
		add_child(test)
