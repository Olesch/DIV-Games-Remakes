class_name PixelCanvas
extends Sprite2D
## The DIV background screen that put_pixel() draws on: an Image the size of the screen shown
## as a texture. Drawing calls only change the Image; the texture is refreshed once per frame.

## Palette colour 15 of the game palette (MANDBROT.MAP), the colour Oleg draws every line in.
const LINE_COLOR := Color8(255, 255, 255)

var image: Image
var _texture: ImageTexture
var _dirty := false


func _init() -> void:
	var view_size := Vector2i(
			ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height"))
	image = Image.create_empty(view_size.x, view_size.y, false, Image.FORMAT_RGBA8)
	_texture = ImageTexture.create_from_image(image)
	texture = _texture
	centered = false


func _process(_delta: float) -> void:
	if _dirty:
		_texture.update(image)
		_dirty = false


## DIV put_pixel(): pixels outside the screen are ignored.
func put_pixel(x: int, y: int, color: Color = LINE_COLOR) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	image.set_pixel(x, y, color)
	_dirty = true


## Oleg's own Bresenham line (DIV: PROCESS Draw_Line). Kept step for step so the drawn pixels
## match the original, including where the error counter starts (half the major axis).
func draw_line_div(x0: int, y0: int, x1: int, y1: int, color: Color = LINE_COLOR) -> void:
	var x := x0
	var y := y0
	var width := absi(x0 - x1)
	var height := absi(y0 - y1)  # DIV: heigh
	put_pixel(x, y, color)
	if width > height:
		# "Horizontal": x moves every step, y whenever the counter overflows
		var counter := width / 2
		while x != x1:
			x += -1 if x > x1 else 1
			counter += height
			if counter >= width:
				counter -= width
				y += -1 if y > y1 else 1
			put_pixel(x, y, color)
	elif height > 0:
		# "Vertikal"
		var counter := height / 2
		while y != y1:
			y += -1 if y > y1 else 1
			counter += width
			if counter >= height:
				counter -= height
				x += -1 if x > x1 else 1
			put_pixel(x, y, color)
	# A zero-length line would loop forever in the original (it never happens in this program);
	# here it is just the single pixel.
