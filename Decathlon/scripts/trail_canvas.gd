class_name TrailCanvas
extends Sprite2D
## The background screen that DIV's put_pixel() draws on (the flight path of the hammer).
## Colours are palette indices, resolved through the converted game palette.

const PALETTE_PATH := "res://assets/fpg/decatlon/palette.json"
const SIZE := Vector2i(800, 600)

var _image: Image
var _palette: Array[Color] = []
var _dirty := false


func _ready() -> void:
	centered = false
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PALETTE_PATH))
	for rgb: Array in data["palette_rgb8"]:
		_palette.append(Color8(int(rgb[0]), int(rgb[1]), int(rgb[2])))
	_image = Image.create(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(_image)


## DIV: put_pixel(x, y, color) - off-screen pixels are ignored.
func put_pixel(x: int, y: int, color_index: int) -> void:
	if x < 0 or y < 0 or x >= SIZE.x or y >= SIZE.y:
		return
	_image.set_pixel(x, y, _palette[color_index])
	_dirty = true


## DIV: clear_screen()
func clear() -> void:
	_image.fill(Color(0, 0, 0, 0))
	_dirty = true


func _process(_delta: float) -> void:
	if _dirty:
		(texture as ImageTexture).update(_image)
		_dirty = false
