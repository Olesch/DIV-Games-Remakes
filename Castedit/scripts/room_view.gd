class_name RoomView
extends Node2D
## Shows the current room: the floor layer as 20x20 tiles blitted into one 800x600 image and the
## object layer as marker sprites. DIV: PROCESS Background (graph 100, z=10) + PROCESS Levelzeichner,
## which draws the tiles into graph 100 with map_put and starts a Potion/Enemy process per object
## (in the editor they only stand there until the room is redrawn).
##
## The image is never cleared, like graph 100: a cell whose floor value has no picture keeps what was
## drawn there before (the previous room, or the tile that was there before an unknown value was painted).

signal redrawn

var _image: Image
var _texture: ImageTexture
var _tile_images: Dictionary = {}

@onready var _canvas: Sprite2D = $Canvas
@onready var _markers: Node2D = $Markers


func _ready() -> void:
	_image = Image.create(Game.SCREEN_W, Game.SCREEN_H, false, Image.FORMAT_RGBA8)  # graph 100 is empty
	_texture = ImageTexture.create_from_image(_image)
	_canvas.texture = _texture
	_canvas.centered = false


func marker_count() -> int:
	return _markers.get_child_count()


## DIV: erease=1 for one frame - every Potion/Enemy process of the room ends.
func clear_markers() -> void:
	for m in _markers.get_children():
		m.queue_free()


## DIV: erease pulse followed by Levelzeichner() - redraws the whole room from the map data.
func redraw() -> void:
	clear_markers()
	for gy in Game.ROWS:
		for gx in Game.COLS:
			var value := Game.cell(Game.Layer.FLOOR, gx, gy)
			var picture := Tiles.floor_picture(value)
			if value == 0:
				Game.set_cell(Game.Layer.FLOOR, gx, gy, 22)   # empty cells become walls (in memory)
			if picture != 0:
				_put_tile(picture, gx, gy)
			if gx == Game.COLS - 1 and gy == Game.ROWS - 1:
				_put_tile(113, gx, gy)   # DIV: the bottom-right corner always gets wall variant 113

			var obj := Game.cell(Game.Layer.OBJECTS, gx, gy)
			if Tiles.OBJECT_GRAPHS.has(obj):
				_add_marker(Tiles.OBJECT_GRAPHS[obj], gx * Game.TILE + 10, gy * Game.TILE + 10)
	_texture.update(_image)
	redrawn.emit()


func _put_tile(code: int, gx: int, gy: int) -> void:
	if not _tile_images.has(code):
		var img := Gfx.tex(code).get_image()
		img.convert(Image.FORMAT_RGBA8)
		_tile_images[code] = img
	var tile: Image = _tile_images[code]
	_image.blend_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), Vector2i(gx, gy) * Game.TILE)


func _add_marker(code: int, px: int, py: int) -> void:
	var s := Sprite2D.new()
	Gfx.apply(s, code)
	s.position = Vector2(px, py)
	_markers.add_child(s)
