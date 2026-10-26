extends SceneTree
## Debug helper: renders the main scene for a moment and saves a PNG.
## godot --path . --script res://scripts/debug/capture.gd -- out.png [seconds] [--options]

var _frames := 0
var _out := ""
var _wait := 120
var _main: Node


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	_out = args[0]
	if args.size() > 1 and args[1].is_valid_float():
		_wait = int(float(args[1]) * 60.0)
	_main = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(_main)


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == 2 and "--options" in OS.get_cmdline_user_args():
		_main.options_panel().visible = true
	if _frames == _wait:
		root.get_viewport().get_texture().get_image().save_png(_out)
		quit()
	return false
