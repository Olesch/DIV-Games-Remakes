class_name Crosshair
extends Sprite2D
## DIV: PROCESS Fadenkreuz() - the mouse pointer graphic. The OS cursor is hidden while playing.

## Set to false by tests that place the crosshair by hand.
var follow_mouse := true


func _ready() -> void:
	add_to_group(&"crosshair")
	Gfx.apply(self, 19)
	position = get_global_mouse_position()


func _process(_delta: float) -> void:
	if follow_mouse:
		position = get_global_mouse_position().round()
