class_name UnitLocator
extends Node2D
## DIV PROCESS Unit_Locator: graph 29 (320x44, drawn at y=66 over the two bottom field rows) into which
## Search_Units "map_put"s the outline of every recipe that is currently complete.

const TOP := 66

## marks[player] = Array of [graph code, x offset in the 320 px wide graph]
var marks: Array = [[], []]


func clear_player(player: int) -> void:
	marks[player] = []
	queue_redraw()


func add_mark(player: int, graph_code: int, mark_x: int) -> void:
	marks[player].append([graph_code, mark_x])
	queue_redraw()


func _draw() -> void:
	for p in 2:
		for m: Array in marks[p]:
			draw_texture(Gfx.tex(m[0]), Vector2(m[1], TOP))
