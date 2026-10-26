extends Sprite2D
## Crosshair that follows the mouse (DIV: Cursor). The OS pointer is hidden.


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta: float) -> void:
	position = get_global_mouse_position()
