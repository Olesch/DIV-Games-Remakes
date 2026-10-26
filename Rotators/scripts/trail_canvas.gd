class_name TrailCanvas
extends Sprite2D
## The background screen the rotators draw on (DIV: put_pixel on the background).
## An Image the size of the screen; the texture is refreshed once per rendered frame.

const SCREEN := Vector2i(1024, 768)  # DIV: set_mode(m1024x768)
const WHITE := Color8(255, 255, 255)  # DIV palette colour 15

var dots_drawn: int = 0

var _image: Image
var _texture: ImageTexture
var _dirty := false


func _ready() -> void:
	centered = false
	_image = Image.create_empty(SCREEN.x, SCREEN.y, false, Image.FORMAT_RGBA8)
	_texture = ImageTexture.create_from_image(_image)
	texture = _texture


func _process(_delta: float) -> void:
	if _dirty:
		_texture.update(_image)
		_dirty = false


func clear() -> void:
	_image.fill(Color(0, 0, 0, 0))
	dots_drawn = 0
	_dirty = true


## DIV: put_pixel(pa_x, pa_y, 15). `arm` is the rotator's place in the chain (for the colour options).
func plot(point: Vector2i, arm: int) -> void:
	if point.x < 0 or point.y < 0 or point.x >= SCREEN.x or point.y >= SCREEN.y:
		return
	_image.set_pixelv(point, _colour_for(arm))
	dots_drawn += 1
	_dirty = true


func _colour_for(arm: int) -> Color:
	var count := float(Options.rotator_count())
	match int(Options.get_value(&"trail_colour")):
		Options.TrailColour.RAINBOW:
			return Color.from_hsv(fmod(arm / count, 1.0), 0.75, 1.0)
		Options.TrailColour.GREYS:
			# DIV palette grey ramp 4..15, darker towards the centre of the chain
			var level := 4 + roundi(11.0 * arm / maxf(count - 1.0, 1.0))
			return Color8(level * 17, level * 17, level * 17)
	return WHITE
