extends Node2D
## Setup screen before every match (new, owner's decision 2026-10-26; the original started the
## match at once with hard-coded values). Each player edits the column of their own team:
## player 1 with the arrow keys (team 1), player 2 with W/A/S/D (team 2). Up/Down select a line,
## Left/Right change the value. Enter / Space / Q start the match, or toggle / reset on the
## REINFORCEMENTS / ORIGINAL VALUES line. Esc starts as well, so Esc Esc in a match is the old
## quick restart. Mouse: left/right half of a value = less/more, right button = less, wheel.

const MATCH_SCENE := "res://scenes/main.tscn"
const LABEL_X := 40.0
const COLUMN_X: Array[float] = [0.0, 500.0, 680.0]  # centre of the team 1 / team 2 value column
const SHARED_X := 590.0                              # centre of the one-value lines
const HEADER_Y := 105.0
const FIRST_ROW_Y := 150.0
const ROW_HEIGHT := 31.0
const CELL_HALF_WIDTH := 85.0

## Lines below the per-team values (Options.SPECS first).
enum Shared { REINFORCEMENTS, ORIGINAL, START }

var _cursor: Array[int] = [0, 0, 0]  # selected line of player 1 / 2 (index 0 unused)
var _value_labels: Array = []         # per SPECS line: [null, team 1 label, team 2 label]
var _shared_labels: Array[PixelLabel] = []
var _status: PixelLabel
var _starting := false


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		_start_match.call_deferred()  # the autotest drives the match itself with the original values
		return
	_cursor[1] = Options.SPECS.size() + Shared.START
	_cursor[2] = Options.SPECS.size() + Shared.START
	PixelLabel.make(self, "THURSDAY PANZERS", Vector2(400, 40), 4)
	for team in [1, 2]:
		var tank := Sprite2D.new()
		tank.texture = load("res://assets/fpg/thurpanz/%d.png" % (99 + team))
		tank.position = Vector2(COLUMN_X[team] - 62.0, HEADER_Y)
		tank.rotation = -PI / 2.0  # facing up, like the DIV angle 90000
		add_child(tank)
		PixelLabel.make(self, "TEAM %d" % team, Vector2(COLUMN_X[team] + 18.0, HEADER_Y), 4)
	for i in Options.SPECS.size():
		var spec: Dictionary = Options.SPECS[i]
		PixelLabel.make(self, spec["label"], Vector2(LABEL_X, _row_y(i)), 3)
		_value_labels.append([null, PixelLabel.make(self, "", Vector2(COLUMN_X[1], _row_y(i)), 4),
				PixelLabel.make(self, "", Vector2(COLUMN_X[2], _row_y(i)), 4)])
	PixelLabel.make(self, "REINFORCEMENTS", Vector2(LABEL_X, _row_y(_shared_row(Shared.REINFORCEMENTS))), 3)
	_shared_labels.append(PixelLabel.make(self, "", Vector2(SHARED_X, _row_y(_shared_row(Shared.REINFORCEMENTS))), 4))
	_shared_labels.append(PixelLabel.make(self, "", Vector2(400, _row_y(_shared_row(Shared.ORIGINAL))), 4))
	_shared_labels.append(PixelLabel.make(self, "", Vector2(400, _row_y(_shared_row(Shared.START))), 4))
	_status = PixelLabel.make(self, "", Vector2(400, 478), 4, PixelLabel.FontKind.SYSTEM)
	var help := [
		"PLAYER 1: ARROW KEYS = TEAM 1 COLUMN      PLAYER 2: W / S SELECT, A / D CHANGE = TEAM 2 COLUMN",
		"ENTER, SPACE OR Q: START THE MATCH (ON REINFORCEMENTS / ORIGINAL VALUES: TOGGLE / RESET)",
		"MOUSE: CLICK THE LEFT / RIGHT HALF OF A VALUE = LESS / MORE, RIGHT BUTTON = LESS, WHEEL",
		"REINFORCEMENTS: EVERY SECOND ONE NEW COMPUTER TANK PER TEAM (LIFE 75, DAMAGE 5, SPEED 25)",
		"IN THE MATCH: PLAYER 1 ARROWS + ENTER, PLAYER 2 W A S D + Q, ESC BACK TO THIS SCREEN",
	]
	for i in help.size():
		PixelLabel.make(self, help[i], Vector2(400, 510 + i * 16), 4, PixelLabel.FontKind.SYSTEM)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			_on_click(event as InputEventMouseButton)
		return
	if event is InputEventMouseMotion:
		_on_hover((event as InputEventMouseMotion).position)
		return
	if event.is_action_pressed(&"restart"):
		_start_match()
	elif event.is_action_pressed(&"p1_fire") or event.is_action_pressed(&"ui_accept"):
		_activate(_cursor[1])
	elif event.is_action_pressed(&"p2_fire"):
		_activate(_cursor[2])
	else:
		for player in [1, 2]:
			var prefix := "p%d_" % player
			if event.is_action_pressed(prefix + "up", true):
				_cursor[player] = posmod(_cursor[player] - 1, _row_count())
			elif event.is_action_pressed(prefix + "down", true):
				_cursor[player] = posmod(_cursor[player] + 1, _row_count())
			elif event.is_action_pressed(prefix + "left", true):
				_change(_cursor[player], player, -1)
			elif event.is_action_pressed(prefix + "right", true):
				_change(_cursor[player], player, 1)
			else:
				continue
			break
	_refresh()
	get_viewport().set_input_as_handled()


func _row_count() -> int:
	return Options.SPECS.size() + Shared.size()


func _shared_row(line: Shared) -> int:
	return Options.SPECS.size() + line


func _row_y(row: int) -> float:
	return FIRST_ROW_Y + row * ROW_HEIGHT


## Line under a screen position, or -1.
func _row_at(pos: Vector2) -> int:
	var row := roundi((pos.y - FIRST_ROW_Y) / ROW_HEIGHT)
	return row if row >= 0 and row < _row_count() else -1


## Team column under a screen position (1 / 2), or 0.
func _column_at(pos: Vector2) -> int:
	for team in [1, 2]:
		if absf(pos.x - COLUMN_X[team]) <= CELL_HALF_WIDTH:
			return team
	return 0


func _change(row: int, team: int, direction: int) -> void:
	if row < Options.SPECS.size():
		Options.step_value(Options.SPECS[row]["key"], team, direction)
	elif row == _shared_row(Shared.REINFORCEMENTS):
		Options.reinforcements = not Options.reinforcements


func _activate(row: int) -> void:
	if row == _shared_row(Shared.REINFORCEMENTS):
		Options.reinforcements = not Options.reinforcements
	elif row == _shared_row(Shared.ORIGINAL):
		Options.reset_to_original()
	else:
		_start_match()


func _on_hover(pos: Vector2) -> void:
	var row := _row_at(pos)
	var team := _column_at(pos)
	if row >= 0 and row < Options.SPECS.size() and team > 0 and _cursor[team] != row:
		_cursor[team] = row
		_refresh()


func _on_click(event: InputEventMouseButton) -> void:
	var row := _row_at(event.position)
	if row < 0:
		return
	var direction := 0
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			direction = 1
		MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_WHEEL_DOWN:
			direction = -1
		MOUSE_BUTTON_WHEEL_UP:
			direction = 1
		_:
			return
	if row < Options.SPECS.size():
		var team := _column_at(event.position)
		if team == 0:
			return
		if event.button_index == MOUSE_BUTTON_LEFT and event.position.x < COLUMN_X[team]:
			direction = -1  # left half of the value = less
		_cursor[team] = row
		_change(row, team, direction)
	elif event.button_index == MOUSE_BUTTON_LEFT or row == _shared_row(Shared.REINFORCEMENTS):
		_cursor[1] = row
		_activate(row)
	_refresh()
	get_viewport().set_input_as_handled()


func _refresh() -> void:
	if _starting:
		return
	for i in Options.SPECS.size():
		var key: StringName = Options.SPECS[i]["key"]
		for team in [1, 2]:
			var text := str(Options.get_value(key, team))
			(_value_labels[i][team] as PixelLabel).set_value(("< %s >" % text) if _cursor[team] == i else text)
	var shared_texts: Array[String] = ["ON" if Options.reinforcements else "OFF", "ORIGINAL VALUES", "START MATCH"]
	for line in Shared.size():
		var row := _shared_row(line as Shared)
		var selected := _cursor[1] == row or _cursor[2] == row
		var text := shared_texts[line]
		if line == Shared.REINFORCEMENTS:
			_shared_labels[line].set_value(("< %s >" % text) if selected else text)
		else:
			_shared_labels[line].set_value(("> %s <" % text) if selected else text)
	_status.set_value("ORIGINAL SETTINGS OF THE DIV GAME" if Options.is_original() else "CHANGED FROM THE ORIGINAL")


func _start_match() -> void:
	if _starting:
		return
	_starting = true
	Game.reset()
	# deferred: changing the scene removes this node at once, but the input handler still needs it
	get_tree().change_scene_to_file.call_deferred(MATCH_SCENE)
