extends Sprite2D
## DIV: mouse.graph=3 - the pin ("Nagel") is the mouse pointer; hot spot = control point 0 = (0,0).


func _ready() -> void:
	position = get_global_mouse_position().round()


func _process(_delta: float) -> void:
	position = get_global_mouse_position().round()
