class_name AtomBoard
extends RefCounted
## The molecule grid (DIV: GLOBAL STRUCT AtX[7] / AtY[7]) plus the Check / Kill processes.
## `field` is the index of the last row/column (DIV "Field", grid size = field + 1, max 8x8).
## `mode` 0 = easy (the border counts as a bond partner), 1 = hard (a bond into the border is open).

const MAX_SIZE := 8

class Cell:
	var exists := false
	var up := false      # DIV: dirup
	var down := false    # DIV: dirdo
	var left := false    # DIV: dirle
	var right := false   # DIV: dirri
	var checked := false

	func clear() -> void:
		exists = false
		up = false
		down = false
		left = false
		right = false
		checked = false

var field := 0
var mode := 0
## DIV: NoAtom - set by check() when the examined group has an open bond.
var no_atom := false
var _cells: Array[Cell] = []


func _init() -> void:
	for i in MAX_SIZE * MAX_SIZE:
		_cells.append(Cell.new())


func cell(x: int, y: int) -> Cell:
	return _cells[x * MAX_SIZE + y]


func clear_all() -> void:
	for c in _cells:
		c.clear()


func atom_count() -> int:
	var n := 0
	for x in field + 1:
		for y in field + 1:
			if cell(x, y).exists:
				n += 1
	return n


## DIV: PROCESS Check(x, y) - flood fill over the bonded atoms, flags open bonds in `no_atom`.
func check(x: int, y: int) -> void:
	var c := cell(x, y)
	c.checked = true

	# Atom auf Verbindungen pruefen.
	if y > 0:
		if c.up and not cell(x, y - 1).down:
			no_atom = true
	elif mode == 1 and c.up:
		no_atom = true

	if y < field:
		if c.down and not cell(x, y + 1).up:
			no_atom = true
	elif mode == 1 and c.down:
		no_atom = true

	if x > 0:
		if c.left and not cell(x - 1, y).right:
			no_atom = true
	elif mode == 1 and c.left:
		no_atom = true

	if x < field:
		if c.right and not cell(x + 1, y).left:
			no_atom = true
	elif mode == 1 and c.right:
		no_atom = true

	# An alle ungeprueften, die nebenanliegen, Pruefungen schicken
	if y > 0 and c.up and not cell(x, y - 1).checked:
		check(x, y - 1)
	if y < field and c.down and not cell(x, y + 1).checked:
		check(x, y + 1)
	if x > 0 and c.left and not cell(x - 1, y).checked:
		check(x - 1, y)
	if x < field and c.right and not cell(x + 1, y).checked:
		check(x + 1, y)


## DIV: PROCESS KILL - removes the checked atoms if the group was complete.
## Returns the number of atoms removed (DIV "Counts"); scoring is done by the caller.
func kill() -> int:
	var counts := 0
	for x in field + 1:
		for y in field + 1:
			var c := cell(x, y)
			if c.checked:
				if no_atom:
					c.checked = false
				else:
					counts += 1
					c.clear()
	no_atom = false
	return counts
