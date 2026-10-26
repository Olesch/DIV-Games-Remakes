extends Node2D
## Level list (new; the original had the level number hard-coded). Up/Down choose, Enter starts.

var rows: Array[PixelLabel] = []
var _selected := 0


func _ready() -> void:
	_selected = Game.selected_level
	var list := $List
	for i in Game.LEVELS.size():
		var row := PixelLabel.new()
		row.position = Vector2(60, 80 + i * 16)
		list.add_child(row)
		rows.append(row)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_down", true):
		_selected = (_selected + 1) % Game.LEVELS.size()
		_refresh()
	elif event.is_action_pressed(&"ui_up", true):
		_selected = (_selected + Game.LEVELS.size() - 1) % Game.LEVELS.size()
		_refresh()
	elif event.is_action_pressed(&"ui_accept"):
		Game.start_level(_selected)


func _refresh() -> void:
	for i in rows.size():
		var info: Dictionary = Game.LEVELS[i]
		var best := Game.hi_time(info["code"])
		var best_text := "-" if best == 0 else str(best)
		var name_text := (info["name"] as String).rpad(9)
		rows[i].set_value("%s %s best: %s" % [">" if i == _selected else " ", name_text, best_text])
