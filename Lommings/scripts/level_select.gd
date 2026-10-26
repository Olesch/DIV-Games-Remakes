class_name LevelSelect
extends Node2D
## Level select (new; the original always started at level 900 = AvailableLevels[0]).
## Arrows or the mouse choose, Enter / Space / left click plays. The game then continues through
## Defs.LEVEL_ORDER from the chosen level like the original; Esc in the game comes back here.

const ROWS_PER_COLUMN := 7
const COLUMN_X: Array[int] = [44, 184]   # left edge of each column (text is middle-left aligned)
const COLUMN_WIDTH := 112
const ROW_Y0 := 36                        # centre of the first row
const ROW_DY := 16                        # line height of the Lommings font
const PREVIEW_CENTRE := Vector2(160, 168)
const PREVIEW_SCALE := 0.25               # 640x190 level -> 160x47
const DIM := Color(0.55, 0.55, 0.55)

@onready var preview: Sprite2D = $Preview
@onready var info: PixelLabel = $Info
@onready var marker: PixelLabel = $Marker

var _rows: Array[PixelLabel] = []
var _selected := 0


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		Game.new_game.call_deferred(0)
		return
	_selected = Game.select_index
	for i in Defs.LEVEL_COUNT:
		var row := PixelLabel.new()
		row.align_code = 3
		row.anchor = Vector2(_row_rect(i).position.x, ROW_Y0 + ROW_DY * (i % ROWS_PER_COLUMN))
		add_child(row)
		_rows.append(row)
	preview.position = PREVIEW_CENTRE
	preview.scale = Vector2(PREVIEW_SCALE, PREVIEW_SCALE)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	var start := -1
	if event is InputEventMouseMotion:
		var hit := _row_at((event as InputEventMouse).position)
		if hit >= 0 and hit != _selected:
			_select(hit)
		return
	if event.is_action_pressed(&"click_left"):
		start = _row_at((event as InputEventMouse).position)
	elif event.is_action_pressed(&"ui_down", true):
		_select((_selected + 1) % Defs.LEVEL_COUNT)
	elif event.is_action_pressed(&"ui_up", true):
		_select((_selected + Defs.LEVEL_COUNT - 1) % Defs.LEVEL_COUNT)
	elif event.is_action_pressed(&"ui_right", true) or event.is_action_pressed(&"ui_left", true):
		var other := (_selected + ROWS_PER_COLUMN) % (ROWS_PER_COLUMN * 2)
		_select(mini(other, Defs.LEVEL_COUNT - 1))
	elif event.is_action_pressed(&"confirm"):
		start = _selected
	else:
		return
	get_viewport().set_input_as_handled()
	if start >= 0:
		Game.new_game(start)


func _select(index: int) -> void:
	_selected = index
	_refresh()


func _row_rect(index: int) -> Rect2:
	var column := index / ROWS_PER_COLUMN
	var y := ROW_Y0 + ROW_DY * (index % ROWS_PER_COLUMN) - ROW_DY / 2
	return Rect2(COLUMN_X[column] - 12, y, COLUMN_WIDTH, ROW_DY)


func _row_at(point: Vector2) -> int:
	for i in Defs.LEVEL_COUNT:
		if _row_rect(i).has_point(point):
			return i
	return -1


func _refresh() -> void:
	for i in _rows.size():
		var row_code: int = Defs.LEVEL_ORDER[i]
		_rows[i].set_value("%d  %s" % [row_code, Defs.LEVELS[row_code]["name"]])
		_rows[i].modulate = Color.WHITE if i == _selected else DIM
	marker.place(_rows[_selected].anchor - Vector2(4, 0))
	var code: int = Defs.LEVEL_ORDER[_selected]
	var params: Array = Defs.LEVELS[code]["params"]
	preview.texture = Gfx.tex(code)
	# the same numbers the panel shows: lemmings and "to save" are value + 1 (original quirk), time = value * 5
	info.set_value("Lommings %d   To save %d   Time %d" % [params[0] + 1, params[3] + 1, params[2] * 5])
