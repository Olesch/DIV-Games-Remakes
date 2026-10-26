extends Sprite2D
## Start of SIEGE: the six help pages 80..85 (unit recipe lists). Enter or Space shows the next page.

const FIRST_PAGE := 80
const LAST_PAGE := 85

var _page := FIRST_PAGE


func _ready() -> void:
	centered = false   # the pages are 320x240 graphics shown at the screen centre
	_show()


func _show() -> void:
	texture = Gfx.tex(_page)


func _unhandled_input(event: InputEvent) -> void:
	# DIV shows the next page once the key has been pressed AND released again
	if event.is_action_released(&"confirm"):
		_page += 1
		if _page > LAST_PAGE:
			get_tree().change_scene_to_file("res://scenes/world.tscn")
		else:
			_show()
