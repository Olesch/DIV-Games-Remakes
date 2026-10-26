class_name Cluster
extends Sprite2D
## The growing aggregate. DIV: process MAPPA showing graphic 2 ("Mappa", a full-screen 1024x768
## graphic that only contains the seed ball in the centre); balls that touch it are drawn into it
## with map_put(file_id, 2, 1, x/10, y/10).
##
## Instead of pixel-exact sprite collision this keeps a "blocked" field: for every pixel position p,
## blocked[p] = 1 when a ball whose control point sits at p would overlap a stuck ball. Stamping a ball
## marks its self-overlap footprint (the 29x29 disc of offsets b2 - b1 over the ball's opaque pixels),
## so a moving ball needs a single lookup per 1-pixel step.

const MAPPA_TEXTURE: Texture2D = preload("res://assets/fpg/ball/2.png")
const BALL_TEXTURE: Texture2D = preload("res://assets/fpg/ball/1.png")
const BALL_CP0 := Vector2i(7, 7)  # graphic 1 has no control point -> centre of 15x15
const SEED_POS := Vector2i(511, 383)  # graphic 2 already contains ball 1 drawn at this position
const SCREEN := Vector2i(1024, 768)
const MARGIN := 128  # balls fly up to ~90 px outside the screen before they are removed

var stuck_count := 0  # stamps, including the seed

var _image: Image
var _texture: ImageTexture
var _ball_image: Image
var _dirty := false
var _field_w := SCREEN.x + 2 * MARGIN
var _field_h := SCREEN.y + 2 * MARGIN
var _blocked := PackedByteArray()
var _footprint := PackedInt32Array()  # overlap offsets as linear field offsets
var _overlap_table := PackedByteArray()  # same offsets as a (2r+1)^2 table for ball-ball tests
var _overlap_radius := 0


func _ready() -> void:
	centered = false  # graphic 2 is drawn centred at (512,384) = exactly the screen
	_ball_image = BALL_TEXTURE.get_image()
	_ball_image.convert(Image.FORMAT_RGBA8)
	_build_footprint()
	reset()


## Back to the start picture: only the seed ball.
func reset() -> void:
	_image = MAPPA_TEXTURE.get_image()
	_image.convert(Image.FORMAT_RGBA8)
	if _texture == null:
		_texture = ImageTexture.create_from_image(_image)
		texture = _texture
	else:
		_texture.update(_image)
	_blocked.resize(_field_w * _field_h)
	_blocked.fill(0)
	stuck_count = 0
	_mark_blocked(SEED_POS)
	stuck_count = 1
	_dirty = false


## True when a ball with its control point at pixel p touches the aggregate.
func is_blocked(p: Vector2i) -> bool:
	var fx := p.x + MARGIN
	var fy := p.y + MARGIN
	if fx < 0 or fy < 0 or fx >= _field_w or fy >= _field_h:
		return false
	return _blocked[fy * _field_w + fx] != 0


## True when two balls at pixel positions a and b overlap (pixel-exact, like DIV collision()).
func balls_overlap(a: Vector2i, b: Vector2i) -> bool:
	var d := b - a
	if absi(d.x) > _overlap_radius or absi(d.y) > _overlap_radius:
		return false
	var size := 2 * _overlap_radius + 1
	return _overlap_table[(d.y + _overlap_radius) * size + d.x + _overlap_radius] != 0


## map_put of graphic 1 into the aggregate at pixel p.
func stamp(p: Vector2i) -> void:
	_image.blend_rect(_ball_image, Rect2i(Vector2i.ZERO, _ball_image.get_size()), p - BALL_CP0)
	_mark_blocked(p)
	stuck_count += 1
	_dirty = true


func _process(_delta: float) -> void:
	if _dirty:
		_dirty = false
		_texture.update(_image)


func _mark_blocked(p: Vector2i) -> void:
	var fx := p.x + MARGIN
	var fy := p.y + MARGIN
	var r := _overlap_radius
	if fx - r >= 0 and fy - r >= 0 and fx + r < _field_w and fy + r < _field_h:
		var base := fy * _field_w + fx
		for off in _footprint:
			_blocked[base + off] = 1
		return
	# near the field border: per-cell bounds check
	var size := 2 * r + 1
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var x := fx + dx
			var y := fy + dy
			if x >= 0 and y >= 0 and x < _field_w and y < _field_h \
					and _overlap_table[(dy + r) * size + dx + r] != 0:
				_blocked[y * _field_w + x] = 1


func _build_footprint() -> void:
	var opaque: Array[Vector2i] = []
	for y in _ball_image.get_height():
		for x in _ball_image.get_width():
			if _ball_image.get_pixel(x, y).a > 0.0:
				opaque.append(Vector2i(x, y))
	_overlap_radius = maxi(_ball_image.get_width(), _ball_image.get_height()) - 1
	var size := 2 * _overlap_radius + 1
	_overlap_table.resize(size * size)
	_overlap_table.fill(0)
	for a in opaque:
		for b in opaque:
			var d := b - a
			_overlap_table[(d.y + _overlap_radius) * size + d.x + _overlap_radius] = 1
	_footprint.clear()
	for dy in range(-_overlap_radius, _overlap_radius + 1):
		for dx in range(-_overlap_radius, _overlap_radius + 1):
			if _overlap_table[(dy + _overlap_radius) * size + dx + _overlap_radius] != 0:
				_footprint.append(dy * _field_w + dx)
