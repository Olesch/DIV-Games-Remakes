class_name Ant
extends Node
## One ant (DIV: PROCESS Ant). Invisible like the original; it only changes the picture.
## Each physics tick (= one DIV frame at the default 18 fps) it takes Settings.steps_per_frame steps.

## Position on the picture (DIV: x, y of the Ant process, used as map coordinates).
var cell := Vector2i(512, 384)
## DIV: Dir, 0 up, 1 right, 2 down, 3 left.
var direction: int = 0

@onready var _canvas: AntCanvas = get_parent().get_parent() as AntCanvas


func _physics_process(_delta: float) -> void:
	_canvas.run_ant(self, Settings.steps_per_frame)
