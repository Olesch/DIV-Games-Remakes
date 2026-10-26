class_name Arena
extends Node2D
## The play field: DIV graphic 1 (1024x768) is both the picture and the "hardness map".
## Trails are drawn into it with map_put_pixel and any non-zero pixel kills a cycle
## (DIV: map_get_pixel(0,1,x,y) != 0).  Here an index array + an Image-backed texture.

const SIZE := Vector2i(1024, 768)
const MAP_DIR := "res://assets/fpg/oltron/"
const MAP_PNG := MAP_DIR + "1.png"
const MAP_INDICES := MAP_DIR + "indices.bin"   # graphic 1 starts at offset 0
## Palette index -> colour (from the game palette: 22 = red, 54 = blue).
const PALETTE := {22: Color8(255, 0, 0), 54: Color8(0, 0, 255), 129: Color8(0, 0, 0)}

var _indices: PackedByteArray
var _image: Image
var _texture: ImageTexture
var _dirty := false
var _alive: Array[LightCycle] = []
var _round_over := false

@onready var _background: Sprite2D = $Background
@onready var _message: Label = $Hud/Message
@onready var _hint: Label = $Hud/Hint


func _ready() -> void:
	_indices = FileAccess.get_file_as_bytes(MAP_INDICES).slice(0, SIZE.x * SIZE.y)
	# The .bin is not a Godot resource: exports only contain it through the preset's include_filter.
	assert(_indices.size() == SIZE.x * SIZE.y, "missing " + MAP_INDICES + " (export include_filter?)")
	_image = (load(MAP_PNG) as Texture2D).get_image()
	_image.convert(Image.FORMAT_RGBA8)
	_texture = ImageTexture.create_from_image(_image)
	_background.texture = _texture
	for node in get_tree().get_nodes_in_group(&"cycles"):
		var cycle := node as LightCycle
		_alive.append(cycle)
		cycle.crashed.connect(_on_cycle_crashed)
	if OS.get_cmdline_user_args().has("--autotest"):
		var test := AutoTest.new()
		test.name = "AutoTest"
		add_child(test)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart") and not event.is_echo():
		get_tree().reload_current_scene()
	elif event.is_action_pressed(&"quit") and not event.is_echo() and not OS.has_feature("web"):
		get_tree().quit()  # quitting would only freeze the page in a browser


func _process(_delta: float) -> void:
	if _dirty:
		_texture.update(_image)
		_dirty = false


## DIV map_get_pixel; outside the graphic the result is 0 (free).
func pixel_at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= SIZE.x or y >= SIZE.y:
		return 0
	return _indices[y * SIZE.x + x]


## DIV map_put_pixel; outside the graphic nothing happens.
func put_pixel(x: int, y: int, index: int) -> void:
	if x < 0 or y < 0 or x >= SIZE.x or y >= SIZE.y:
		return
	_indices[y * SIZE.x + x] = index
	_image.set_pixel(x, y, PALETTE.get(index, Color.WHITE))
	_dirty = true


func count_pixels(index: int) -> int:
	var n := 0
	for v in _indices:
		if v == index:
			n += 1
	return n


func _on_cycle_crashed(cycle: LightCycle) -> void:
	_alive.erase(cycle)
	if _round_over:
		return
	# New (original: nothing happens, the survivor just keeps driving): announce the result.
	if _alive.size() == 1:
		_round_over = true
		_message.text = "%s wins!" % _alive[0].player_name
		_message.show()
		_hint.show()
	elif _alive.is_empty():
		_round_over = true
		_message.text = "Draw!"
		_message.show()
		_hint.show()
