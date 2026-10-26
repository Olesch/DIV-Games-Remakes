class_name PixelField
extends Node2D
## The animated dot background shown while the puzzle is solved (DIV: Pix[Dots] and the
## put_pixel loop in repaint()). 91 dots; each DIV frame every dot plots 4 pixels while walking
## 3 steps, fading its palette colour now and then, and respawns near the screen centre once its
## colour index is a multiple of 16. Runs at the original 18 steps per second.

const DOTS := 91                 # DIV: Dots=90, loops run 0..Dots
const STEP_TIME := 1.0 / 18.0    # set_fps(18)
const PALETTE_PATH := "res://assets/pal/div/palette.json"

var active := false:
	set(value):
		active = value
		if not value:
			_pixels.clear()
		queue_redraw()

var _dots: Array[Dot] = []
var _palette: Array[Color] = []
var _pixels: Array[Vector3i] = []   # (x, y, colour index) plotted in the latest step
var _accum := 0.0


class Dot:
	var x := 0
	var y := 0
	var col := 0
	var dx := 0
	var dy := 0


func _ready() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PALETTE_PATH))
	for rgb: Array in data["palette_rgb8"]:
		_palette.append(Color8(rgb[0], rgb[1], rgb[2]))
	for i in DOTS:
		var d := Dot.new()
		d.x = randi_range(0, 640)
		d.y = randi_range(0, 480)
		d.col = randi_range(0, 255)
		d.dx = randi_range(-1, 1)
		d.dy = randi_range(-1, 1)
		_dots.append(d)


func _process(delta: float) -> void:
	if not active:
		return
	_accum += delta
	while _accum >= STEP_TIME:
		_accum -= STEP_TIME
		step()


## One DIV frame of the animation.
func step() -> void:
	_pixels.clear()
	for d in _dots:
		_pixels.append(Vector3i(d.x, d.y, d.col))
		for i in 3:
			d.x = (d.x + d.dx) % 641   # C-style remainder like DIV: negative values stay off-screen
			d.y = (d.y + d.dy) % 481
			if randi_range(0, 7) == 0:
				d.col = (d.col - 1) % 256
			_pixels.append(Vector3i(d.x, d.y, d.col))
		if d.col % 16 == 0:
			# sum of eight dice: bell shaped around the screen centre (320, 240)
			d.x = 0
			d.y = 0
			for i in 8:
				d.x += randi_range(0, 80)
				d.y += randi_range(0, 60)
			d.dx = randi_range(-1, 1)
			d.dy = randi_range(-1, 1)
	queue_redraw()


func _draw() -> void:
	for p in _pixels:
		if p.x < 0 or p.y < 0 or p.x >= 640 or p.y >= 480:
			continue
		draw_rect(Rect2(p.x, p.y, 1, 1), _palette[p.z & 255])
