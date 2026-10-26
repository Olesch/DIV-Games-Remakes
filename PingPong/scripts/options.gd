extends Node2D
## Options screen before each match (new, owner's request 2026-10-26: the original hard-codes all of
## this and starts at once). The defaults in `Game` are the original's values.
## Keyboard: Up/Down select, Left/Right change, Enter/Space start (or run the selected action).
## Mouse: hovering selects a row, clicking left/right of a value changes it (wheel too), clicking an
## action runs it.

enum Row { BALLS, SPEED, WIN, ONE_BALL, LEFT_BAT, RIGHT_BAT, ORIGINAL, START }

const ROW_Y: Array[int] = [140, 170, 200, 230, 260, 290, 336, 366]
const ROW_HALF_HEIGHT := 14
const ROW_LEFT := 80
const ROW_RIGHT := 580
const NAME_X := 96
const VALUE_X := 480
const ARROW_OFFSET := 84
const SELECTED_COLOUR := Color8(0, 252, 0)   # the green of the field, bats and balls
const NORMAL_COLOUR := Color.WHITE
const DIM_COLOUR := Color(0.35, 0.35, 0.35)
const ROW_NAMES: Array[String] = [
	"Balls", "Ball speed", "Points to win", "Classic one-ball mode",
	"Left bat  (Q/A)", "Right bat (Up/Down)", "Original settings", "Start match",
]
const PIXEL_LABEL := preload("res://scenes/pixel_label.tscn")
const MATCH_SCENE := "res://scenes/main.tscn"

var _row: int = Row.START
var _names: Array[PixelLabel] = []
var _values: Array[PixelLabel] = []
var _arrows: Array[PixelLabel] = []   # two per option row: "<" then ">"
var _description: PixelLabel


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		_start_match.call_deferred()   # the autotest plays the match with the options as they are
		return
	_label("PingPong", Vector2(320, 62), 4, 4).set_colour(SELECTED_COLOUR)
	_label("Options", Vector2(320, 100), 4, 2)
	for row in Row.size():
		var is_action := row >= Row.ORIGINAL
		_names.append(_label("", Vector2(320 if is_action else NAME_X, ROW_Y[row]), 4 if is_action else 3, 2))
		if not is_action:
			_values.append(_label("", Vector2(VALUE_X, ROW_Y[row]), 4, 2))
			_arrows.append(_label("<", Vector2(VALUE_X - ARROW_OFFSET, ROW_Y[row]), 4, 2))
			_arrows.append(_label(">", Vector2(VALUE_X + ARROW_OFFSET, ROW_Y[row]), 4, 2))
	_description = _label("", Vector2(320, 404), 4, 1)
	_label("Up/Down select   Left/Right change   Enter start   Mouse: hover, click", Vector2(320, 428), 4, 1)
	_label("Player 1: Q / A    Player 2: Up / Down    Esc in the match: back to this screen",
		Vector2(320, 444), 4, 1)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_up", true):
		_row = posmod(_row - 1, Row.size())
	elif event.is_action_pressed(&"ui_down", true):
		_row = posmod(_row + 1, Row.size())
	elif event.is_action_pressed(&"ui_left", true):
		_change(-1)
	elif event.is_action_pressed(&"ui_right", true):
		_change(1)
	elif event.is_action_pressed(&"ui_accept"):
		if _row == Row.ORIGINAL:
			Game.reset_options()
		else:
			_start_match()
			return
	elif event is InputEventMouseMotion:
		var hovered := _row_at((event as InputEventMouseMotion).position)
		if hovered < 0 or hovered == _row:
			return
		_row = hovered
	elif event is InputEventMouseButton and event.is_pressed():
		if not _click(event as InputEventMouseButton):
			return
	else:
		return
	_refresh()
	get_viewport().set_input_as_handled()


## Returns true if the click hit a row.
func _click(event: InputEventMouseButton) -> bool:
	var clicked := _row_at(event.position)
	if clicked < 0:
		return false
	_row = clicked
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			if _row == Row.START:
				_start_match()
			elif _row == Row.ORIGINAL:
				Game.reset_options()
			else:
				_change(-1 if event.position.x < VALUE_X else 1)
		MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_WHEEL_DOWN:
			_change(-1)
		MOUSE_BUTTON_WHEEL_UP:
			_change(1)
	return true


func _row_at(point: Vector2) -> int:
	if point.x < ROW_LEFT or point.x > ROW_RIGHT:
		return -1
	for row in Row.size():
		if absf(point.y - ROW_Y[row]) <= ROW_HALF_HEIGHT:
			return row
	return -1


func _change(direction: int) -> void:
	match _row:
		Row.BALLS:
			Game.ball_count = _stepped(Game.BALL_CHOICES, Game.ball_count, direction)
		Row.SPEED:
			Game.activity = _stepped(Game.ACTIVITY_CHOICES, Game.activity, direction)
		Row.WIN:
			Game.win_margin = _stepped(Game.WIN_MARGIN_CHOICES, Game.win_margin, direction)
		Row.ONE_BALL:
			Game.one_ball_mode = not Game.one_ball_mode
		Row.LEFT_BAT:
			Game.computer[0] = not Game.computer[0]
		Row.RIGHT_BAT:
			Game.computer[1] = not Game.computer[1]


## The neighbour of `value` in `choices`, clamped at both ends.
func _stepped(choices: Array[int], value: int, direction: int) -> int:
	var index := choices.find(value)
	return choices[clampi(index + direction, 0, choices.size() - 1)]


func _start_match() -> void:
	get_tree().change_scene_to_file(MATCH_SCENE)


func _refresh() -> void:
	var values: Array[String] = [
		("up to %d" if Game.one_ball_mode else "%d") % Game.ball_count,
		"%d" % Game.activity,
		"%d ahead" % Game.win_margin,
		"On" if Game.one_ball_mode else "Off",
		"Computer" if Game.computer[0] else "Human",
		"Computer" if Game.computer[1] else "Human",
	]
	var limits: Array = [
		[Game.BALL_CHOICES, Game.ball_count],
		[Game.ACTIVITY_CHOICES, Game.activity],
		[Game.WIN_MARGIN_CHOICES, Game.win_margin],
	]
	for row in Row.size():
		var colour := SELECTED_COLOUR if row == _row else NORMAL_COLOUR
		_show(_names[row], ROW_NAMES[row], colour)
		if row >= Row.ORIGINAL:
			continue
		_show(_values[row], values[row], colour)
		for side in 2:
			var arrow := _arrows[row * 2 + side]
			var at_limit := false
			if row < limits.size():
				var choices: Array[int] = limits[row][0]
				at_limit = choices.find(limits[row][1]) == (0 if side == 0 else choices.size() - 1)
			arrow.set_colour(DIM_COLOUR if at_limit else colour)
	_description.set_value(_describe())


func _describe() -> String:
	match _row:
		Row.BALLS:
			if Game.one_ball_mode:
				return "One-ball mode: the most balls in play at once. Original: 70."
			return "Balls released in pairs from the centre. Original: 70."
		Row.SPEED:
			return "Activity %d: balls and bats move %d px per frame. Original: 4 (16 px)." % [
				Game.activity, Game.step()]
		Row.WIN:
			return "A player wins when this many points ahead. Original: 500."
		Row.ONE_BALL:
			return "The original's unused mode: single balls appear at random, starting slowly."
		Row.LEFT_BAT, Row.RIGHT_BAT:
			return "Computer: the original's unused bat player chases the nearest ball coming at it."
		Row.ORIGINAL:
			return "All values are the original's." if Game.options_are_original() \
				else "Back to the values of the original game."
	return "Start the match with these settings. Enter after a win comes back here."


func _show(label: PixelLabel, value: String, colour: Color) -> void:
	label.set_colour(colour)
	label.set_value(value)


func _label(value: String, anchor: Vector2, align: int, pixel_scale: int) -> PixelLabel:
	var label := PIXEL_LABEL.instantiate() as PixelLabel
	label.align_code = align
	label.pixel_scale = pixel_scale
	add_child(label)
	label.place(anchor, value)
	return label
