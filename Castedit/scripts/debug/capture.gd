extends SceneTree
## Debug helper: renders a scene for a moment and saves a PNG.
## godot --path . --script res://scripts/debug/capture.gd -- res://scenes/title.tscn out.png [seconds]

var _frames := 0
var _out := ""
var _wait := 30


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var scene := load(args[0]) as PackedScene
	_out = args[1]
	if args.size() > 2:
		_wait = int(float(args[2]) * 60.0)
	root.add_child(scene.instantiate())


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == _wait:
		root.get_viewport().get_texture().get_image().save_png(_out)
		quit()
	return false
