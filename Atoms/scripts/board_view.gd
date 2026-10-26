class_name BoardView
extends Node2D
## The board graphic. DIV paints it into graphic 1 with map_put (Repaint) and shows it as the
## Background process; here it is drawn live from the board state, same layer order.

const DIR := "res://assets/fpg/atoms/"
const ORIGIN := Vector2(180, 110)   # DIV: PLX, PLY
const CELL := 40                    # pitch of the cells in pixels

var _tex := {}


func _tex_of(code: int) -> Texture2D:
	if not _tex.has(code):
		_tex[code] = load("%s%d.png" % [DIR, code])
	return _tex[code]


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	var board := Game.board
	draw_texture(_tex_of(3), Vector2.ZERO)                     # "Loeschen" (opaque black)
	draw_texture(_tex_of(114 - board.field), Vector2.ZERO)     # Hintergrund for this grid size
	for x in board.field + 1:
		for y in board.field + 1:
			var c := board.cell(x, y)
			var p := ORIGIN + Vector2(x, y) * CELL     # control point 0 of 102..106 is (0,0)
			if c.exists:
				draw_texture(_tex_of(102), p)
			if c.left:
				draw_texture(_tex_of(103), p)
			if c.up:
				draw_texture(_tex_of(104), p)
			if c.right:
				draw_texture(_tex_of(105), p)
			if c.down:
				draw_texture(_tex_of(106), p)
