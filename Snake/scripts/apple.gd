class_name Apple
extends Sprite2D
## DIV process apple: just a graphic (3) standing on a grid cell. Eaten by the worm head.

func _ready() -> void:
	add_to_group(&"apples")
