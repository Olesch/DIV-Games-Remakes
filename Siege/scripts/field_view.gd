class_name FieldView
extends Node2D
## DIV PROCESS Draw_field: the element tiles are "put" on the background. This node shows the tiles as they
## were last drawn (Game.field can already be re-rolled while the cursor spins, like in the original).

## tiles[player][x][y] as drawn on screen (0 = nothing yet)
var tiles: Array = []


func _init() -> void:
	for p in 2:
		var cols: Array = []
		for fx in Game.FIELD_W:
			cols.append([0, 0, 0, 0, 0])
		tiles.append(cols)


func show_field(player: int) -> void:
	for fx in Game.FIELD_W:
		for fy in Game.FIELD_H:
			tiles[player][fx][fy] = Game.field[player][fx][fy]
	queue_redraw()


func _draw() -> void:
	for p in 2:
		for fx in Game.FIELD_W:
			for fy in Game.FIELD_H:
				var t: int = tiles[p][fx][fy]
				if t > 0:
					draw_texture(Gfx.tex(9 + t), Vector2(fx * 22 + p * 188, fy * 22))
