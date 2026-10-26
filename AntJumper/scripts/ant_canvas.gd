class_name AntCanvas
extends Sprite2D
## The picture the ants walk on: graphic 1 of Ant.fpg, which the DIV main process shows
## (graph=1, x/y/size) and the ants edit with map_get_pixel / map_put_pixel.
## Pixels are kept as palette indices (that is what the rule reads); a palette shader draws them,
## index 0 transparent like every DIV sprite.

const PICTURE_DIR := "res://assets/fpg/ant/"
const PICTURE_CODE := 1
## Share of pixels set on the "random dots" canvas.
const DOT_DENSITY := 0.05

var width: int = 1024
var height: int = 768
var cells := PackedByteArray()
var rule: AntRule = AntRule.original_fixed()
var wrap_edges := false
## Steps done by all ants since the last reset.
var total_steps: int = 0

var _picture := PackedByteArray()
var _image: Image
var _texture: ImageTexture
var _dirty := false


func _ready() -> void:
	_load_picture()
	cells = _picture.duplicate()
	_image = Image.create_from_data(width, height, false, Image.FORMAT_R8, cells)
	_texture = ImageTexture.create_from_image(_image)
	texture = _texture


func _process(_delta: float) -> void:
	if _dirty:
		_dirty = false
		_image.set_data(width, height, false, Image.FORMAT_R8, cells)
		_texture.update(_image)


## Starts over on a fresh canvas.
func reset(new_rule: AntRule, start: Settings.StartCanvas) -> void:
	rule = new_rule
	total_steps = 0
	cells = _picture.duplicate()
	if start == Settings.StartCanvas.RANDOM_DOTS:
		var dots := rule.trigger_colours()
		if not dots.is_empty():
			for i in cells.size():
				if randf() < DOT_DENSITY:
					cells[i] = dots[randi() % dots.size()]
	_dirty = true


func colour_at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= width or y >= height:
		return 0
	return cells[y * width + x]


func count_colour(colour: int) -> int:
	return cells.count(colour)


## Moves one ant `steps` times (DIV: the Ant process loop between two FRAMEs):
## step forward, read the pixel's state, turn, paint the next state's colour.
## The loop lives here so it can change `cells` in place.
func run_ant(ant: Ant, steps: int) -> void:
	var x := ant.cell.x
	var y := ant.cell.y
	var dir := ant.direction
	var turns := rule.turns
	var paint := rule.paint
	var state_of := rule.state_of_colour
	var outside_state := state_of[0]  # off the picture the ant reads colour 0 and paints nothing
	var w := width
	var h := height
	for i in steps:
		match dir:  # DIV Dir: 0 up, 1 right, 2 down, 3 left
			0: y -= 1
			1: x += 1
			2: y += 1
			_: x -= 1
		if wrap_edges:
			x = posmod(x, w)
			y = posmod(y, h)
		if x >= 0 and y >= 0 and x < w and y < h:
			var index := y * w + x
			var state := state_of[cells[index]]
			dir = (dir + turns[state]) & 3
			cells[index] = paint[state]
		else:
			dir = (dir + turns[outside_state]) & 3
	ant.cell = Vector2i(x, y)
	ant.direction = dir
	total_steps += steps
	_dirty = true


func _load_picture() -> void:
	var meta: Variant = JSON.parse_string(FileAccess.get_file_as_string(PICTURE_DIR + "meta.json"))
	var all := FileAccess.get_file_as_bytes(PICTURE_DIR + "indices.bin")
	if meta is Dictionary:
		for g: Dictionary in meta["graphics"]:
			if int(g["code"]) == PICTURE_CODE:
				width = int(g["width"])
				height = int(g["height"])
				var offset := int(g["offset"])
				_picture = all.slice(offset, offset + width * height)
	if _picture.size() != width * height:
		push_error("AntCanvas: could not load graphic %d of Ant.fpg" % PICTURE_CODE)
		_picture = PackedByteArray()
		_picture.resize(width * height)
