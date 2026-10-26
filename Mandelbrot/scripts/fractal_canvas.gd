class_name FractalCanvas
extends Sprite2D
## The DIV background screen that MANDBROT.PRG paints with put_pixel(), plus the view
## (DIV GLOBALs zoom / xshi / yshi) and the progressive renderer (DIV processes Draw + Rechne).
##
## The picture is kept as palette indices; a draw request is a "job" that walks the same
## points in the same order as the original Draw() loops and is spread over frames:
## at most 30001 points per DIV frame (18 fps), and never more than FRAME_BUDGET_USEC of
## CPU per Godot frame, so the web build stays responsive.

signal draw_finished

const WIDTH := 1024   # DIV: set_mode(m1024x768)
const HEIGHT := 768
const HALF_W := WIDTH / 2
const HALF_H := HEIGHT / 2
const MAX_ITERATIONS := 30          # DIV Rechne: IF(counter>=30) break
const COLOR_STEP := 8               # DIV Rechne: return(counter*8)
const OVERLAY_COLOR := 1            # over.map is one flat picture of colour index 1
const POINTS_PER_DIV_FRAME := 30001 # DIV Draw: IF(counter>30000) FRAME
const DIV_FPS := 18                 # no set_fps in the PRG -> DIV default
const FRAME_BUDGET_USEC := 8000
const PALETTE_JSON := "res://assets/pal/mandbrot/palette.json"  # DIV: load_pal("Mandbrot.pal")

const INT32_MIN := -2147483648
const UINT32_MASK := 0xFFFFFFFF

## View, all 32-bit DIV integers. Fixed point: a screen pixel is 1/zoom units.
var zoom := 100
var shift_x := 0  # DIV: xshi
var shift_y := 0  # DIV: yshi

var _palette := PackedInt32Array()   # index -> packed RGBA8 (little endian)
var _indices := PackedByteArray()    # what the screen shows, as palette indices
var _pixels := PackedInt32Array()    # same, as RGBA8 for the texture
var _image: Image
var _texture: ImageTexture
var _dirty := false

# current draw job (DIV: stop=1 while Draw runs)
var _drawing := false
var _step := 1
var _block := false   # stepp >= 2: paint a 3x3 block around every point
var _x := 0
var _x_end := 0
var _y := 0
var _y_start := 0
var _y_end := 0
var _point_credit := 0.0


func _ready() -> void:
	centered = false
	_load_palette()
	_indices.resize(WIDTH * HEIGHT)  # index 0 = the background colour (white in Mandbrot.pal)
	_pixels.resize(WIDTH * HEIGHT)
	_pixels.fill(_palette[0])
	_image = Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8, _pixels.to_byte_array())
	_texture = ImageTexture.create_from_image(_image)
	texture = _texture


func _process(delta: float) -> void:
	if _drawing:
		_point_credit = minf(_point_credit + POINTS_PER_DIV_FRAME * DIV_FPS * delta, POINTS_PER_DIV_FRAME)
		_render_slice()
	if _dirty:
		_dirty = false
		_image.set_data(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8, _pixels.to_byte_array())
		_texture.update(_image)


# ------------------------------------------------------------------ view changes

func is_drawing() -> bool:
	return _drawing


func pan(dx: int, dy: int) -> void:
	shift_x = wrap32(shift_x + dx)
	shift_y = wrap32(shift_y + dy)


## DIV: zoom+=zoom/2; xshi+=xshi/2; yshi+=yshi/2 (keeps the screen centre in place).
func zoom_in() -> void:
	_set_zoom(wrap32(zoom + zoom / 2))
	shift_x = wrap32(shift_x + shift_x / 2)
	shift_y = wrap32(shift_y + shift_y / 2)


## DIV: zoom-=zoom/3; xshi-=xshi/3; yshi-=yshi/3
func zoom_out() -> void:
	_set_zoom(wrap32(zoom - zoom / 3))
	shift_x = wrap32(shift_x - shift_x / 3)
	shift_y = wrap32(shift_y - shift_y / 3)


func _set_zoom(value: int) -> void:
	# DIV would stop with a division-by-zero error; the wrapped value can only hit 0 by a
	# freak coincidence after the zoom has overflowed, so just keep the old value then.
	if value != 0:
		zoom = value


# ------------------------------------------------------------------ drawing

## DIV: Draw(x, y, stepp, divisor). Ignored while another draw runs (the "stop" flag).
## divisor shrinks the drawn area to the centre 1/divisor of the screen, stepp >= 2 draws
## every stepp-th point as a 3x3 block (a quick, gappy preview over the old picture).
func request_draw(step: int, divisor: int) -> bool:
	if _drawing:
		return false
	_drawing = true
	_step = step
	_block = step >= 2
	if divisor == 1 and step == 1:
		_x = -HALF_W
		_x_end = HALF_W
		_y_start = -HALF_H
		_y_end = HALF_H
	else:
		_x = -HALF_W / divisor
		_x_end = HALF_W / divisor
		_y_start = -HALF_H / divisor
		_y_end = HALF_H / divisor
	_y = _y_start
	_point_credit = POINTS_PER_DIV_FRAME  # Draw runs its first batch in the frame it is called
	return true


## DIV: put(0, over, 512, 384) - over.map covers the whole screen with colour 1.
func stamp_overlay() -> void:
	_indices.fill(OVERLAY_COLOR)
	_pixels.fill(_palette[OVERLAY_COLOR])
	_dirty = true


func color_index_at(px: int, py: int) -> int:
	return _indices[py * WIDTH + px]


func palette_color(index: int) -> Color:
	var c := _palette[index]
	return Color8(c & 0xFF, (c >> 8) & 0xFF, (c >> 16) & 0xFF)


## DIV process Rechne(rc, ic): iterations until |z| >= 2 (max 30), in fixed point with
## 1.0 = zoom, in 32-bit integer arithmetic. Returns the palette index (iterations * 8).
func point_color(rc: int, ic: int) -> int:
	if _is_overflow_free():
		return _iterate(rc, ic, zoom) * COLOR_STEP
	return _iterate_wrapped(wrap32(rc), wrap32(ic), zoom) * COLOR_STEP


func _render_slice() -> void:
	var start := Time.get_ticks_usec()
	var exact := _is_overflow_free()  # the view can change between frames (DIV read the globals live)
	var z := zoom
	var sx := shift_x
	var sy := shift_y
	var done := 0
	while _point_credit >= 1.0:
		var count := _iterate(_x + sx, _y + sy, z) if exact \
				else _iterate_wrapped(wrap32(_x + sx), wrap32(_y + sy), z)
		_plot(_x + HALF_W, _y + HALF_H, count * COLOR_STEP)
		_point_credit -= 1.0
		_y += _step
		if _y >= _y_end:
			_y = _y_start
			_x += _step
			if _x >= _x_end:
				_finish()
				return
		done += 1
		if (done & 255) == 0 and Time.get_ticks_usec() - start > FRAME_BUDGET_USEC:
			return


func _finish() -> void:
	_drawing = false
	_point_credit = 0.0
	draw_finished.emit()


func _plot(px: int, py: int, index: int) -> void:
	if not _block:
		_set_pixel(px, py, index)
		return
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			_set_pixel(px + dx, py + dy, index)


func _set_pixel(px: int, py: int, index: int) -> void:
	if px < 0 or py < 0 or px >= WIDTH or py >= HEIGHT:
		return  # put_pixel outside the screen does nothing
	var i := py * WIDTH + px
	_indices[i] = index
	_pixels[i] = _palette[index]
	_dirty = true


## True when no intermediate value of the iteration can leave the 32-bit range for any point
## on screen: inside the loop |a|,|b| < 2*zoom, so every value stays below 2*(4*zoom+R)^2.
## Then plain 64-bit GDScript ints give exactly DIV's results and the fast loop is used.
func _is_overflow_free() -> bool:
	var reach := maxi(absi(shift_x) + HALF_W, absi(shift_y) + HALF_H)
	return zoom > 0 and 4 * zoom + reach < 32768


func _iterate(rc: int, ic: int, z: int) -> int:
	var limit := 4 * z * z
	var a := 0
	var b := 0
	var count := 0
	while a * a + b * b < limit:
		var a_new := (a * a - b * b) / z + rc
		b = 2 * a * b / z + ic
		a = a_new
		count += 1
		if count >= MAX_ITERATIONS:
			break
	return count


## Same loop with every operation wrapped to 32 bits like DIV, for deep zooms and far shifts
## (where the original produces its overflow artefacts).
func _iterate_wrapped(rc: int, ic: int, z: int) -> int:
	var limit := wrap32(wrap32(4 * z) * z)
	var a := 0
	var b := 0
	var count := 0
	while wrap32(wrap32(a * a) + wrap32(b * b)) < limit:
		var a_new := wrap32(_div32(wrap32(wrap32(a * a) - wrap32(b * b)), z) + rc)
		b = wrap32(_div32(wrap32(wrap32(2 * a) * b), z) + ic)
		a = a_new
		count += 1
		if count >= MAX_ITERATIONS:
			break
	return count


static func wrap32(v: int) -> int:
	return ((v - INT32_MIN) & UINT32_MASK) + INT32_MIN


static func _div32(n: int, d: int) -> int:
	return wrap32(n / d)  # truncates toward zero like C; only MIN_INT / -1 needs the wrap


func _load_palette() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PALETTE_JSON))
	var rgb: Array = data["palette_rgb8"]
	_palette.resize(256)
	for i in 256:
		var c: Array = rgb[i]
		_palette[i] = wrap32(int(c[0]) | int(c[1]) << 8 | int(c[2]) << 16 | 0xFF << 24)
