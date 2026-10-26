class_name Sierpinski
## The recursive Sierpinski triangle (DIV: PROCESS Sirpienski). Each level connects the midpoints
## of the triangle's sides and recurses into the three corner triangles. All integer maths, like
## DIV, so the midpoints are truncated exactly as in the original.


## Draws the outline of the triangle, then `depth` levels of subdivision.
static func draw(canvas: PixelCanvas, p0: Vector2i, p1: Vector2i, p2: Vector2i, depth: int) -> void:
	_line(canvas, p0, p1)
	_line(canvas, p1, p2)
	_line(canvas, p2, p0)
	subdivide(canvas, p0, p1, p2, depth)


static func subdivide(canvas: PixelCanvas, p0: Vector2i, p1: Vector2i, p2: Vector2i, depth: int) -> void:
	if depth == 0:
		return
	# Mittelpunkte rechnen (midpoints, integer division)
	var m0 := (p0 + p1) / 2
	var m1 := (p1 + p2) / 2
	var m2 := (p2 + p0) / 2
	# Mittelpunkt verbinden (connect the midpoints)
	_line(canvas, m0, m1)
	_line(canvas, m1, m2)
	_line(canvas, m2, m0)
	subdivide(canvas, p0, m0, m2, depth - 1)
	subdivide(canvas, p1, m1, m0, depth - 1)
	subdivide(canvas, p2, m2, m1, depth - 1)


static func _line(canvas: PixelCanvas, a: Vector2i, b: Vector2i) -> void:
	canvas.draw_line_div(a.x, a.y, b.x, b.y)
