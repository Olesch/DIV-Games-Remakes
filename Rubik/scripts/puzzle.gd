class_name Puzzle
extends RefCounted
## The 3x3 board (DIV: global table Pos[8] / newPos[8]) and its 12 cursor moves.
##
## Cells are numbered 0..8 row by row. The cursor sits on the border around the board:
##    1  2  3
##  12*  *  *4
##  11*  *  *5
##  10*  *  *6
##    9  8  7
## Cursor 1-3 / 7-9 rotate a column of three cells, 4-6 / 10-12 a row. Each move is a cyclic shift:
## the value in cycle[0] goes to cycle[1], cycle[1] to cycle[2], cycle[2] to cycle[0].

const CURSOR_COUNT := 12

## Indexed by cursor (1..12); index 0 unused. Transcribed from the original Move() process.
const CYCLES: Array[Array] = [
	[],
	[0, 3, 6], [1, 4, 7], [2, 5, 8],      # 1-3: columns, shifted down
	[0, 2, 1], [3, 5, 4], [6, 8, 7],      # 4-6: rows, shifted left
	[8, 5, 2], [7, 4, 1], [6, 3, 0],      # 7-9: columns, shifted up
	[6, 7, 8], [3, 4, 5], [0, 1, 2],      # 10-12: rows, shifted right
]

signal changed

var cells: PackedInt32Array = PackedInt32Array([1, 2, 3, 4, 5, 6, 7, 8, 9])


func apply_move(cursor: int) -> void:
	var c: Array = CYCLES[cursor]
	var a: int = c[0]
	var b: int = c[1]
	var d: int = c[2]
	var last := cells[d]
	cells[d] = cells[b]
	cells[b] = cells[a]
	cells[a] = last
	changed.emit()


func is_solved() -> bool:
	for i in 9:
		if cells[i] != i + 1:
			return false
	return true


## DIV 'M' key: pick a random cursor position and make one move there; returns that cursor.
func shuffle_step() -> int:
	var cursor := randi_range(1, CURSOR_COUNT)
	apply_move(cursor)
	return cursor
