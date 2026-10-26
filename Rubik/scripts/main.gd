extends Node2D
## Rubik: the whole game on one screen. Cursor on the 12 border positions, Enter rotates the
## three numbers next to it, M scrambles. When the order 1..9 is restored the background starts
## to show moving dots.

const CURSOR_POS: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(300, 200), Vector2i(320, 200), Vector2i(340, 200),
	Vector2i(360, 220), Vector2i(360, 240), Vector2i(360, 260),
	Vector2i(340, 280), Vector2i(320, 280), Vector2i(300, 280),
	Vector2i(280, 260), Vector2i(280, 240), Vector2i(280, 220),
]

var puzzle := Puzzle.new()
var cursor := 1

var _field: PixelField
var _numbers: Array[PixelLabel] = []
var _star: PixelLabel


func _ready() -> void:
	_setup_input()
	_field = PixelField.new()
	add_child(_field)
	_build_board()
	puzzle.changed.connect(_refresh)
	cursor = randi_range(1, Puzzle.CURSOR_COUNT)   # DIV: cursor=rand(1,12); Move();
	puzzle.apply_move(cursor)
	_refresh()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _build_board() -> void:
	for y in [210, 230, 250, 270]:
		PixelLabel.make(self, "----------", 320, y, 4)
	for x in [290, 310, 330, 350]:
		for y in range(212, 271, 5):
			PixelLabel.make(self, "|", x, y, 4)
	for i in 9:
		_numbers.append(PixelLabel.make(self, "", 300 + (i % 3) * 20, 220 + (i / 3) * 20, 4))
	_star = PixelLabel.make(self, "*", 300, 200, 4)
	PixelLabel.make(self, "M           - Mischen", 20, 440, 6)
	PixelLabel.make(self, "Enter       - Zahlen bewegen", 20, 450, 6)
	PixelLabel.make(self, "Pfeiltasten - Cursor bewegen", 20, 460, 6)


func _refresh() -> void:
	for i in 9:
		_numbers[i].set_value(str(puzzle.cells[i]))
	_star.anchor = Vector2(CURSOR_POS[cursor])
	_star.set_value("*")
	_field.active = puzzle.is_solved()


func move_cursor(step: int) -> void:
	# wraps 12 -> 1 and 1 -> 12
	cursor = posmod(cursor - 1 + step, Puzzle.CURSOR_COUNT) + 1
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	# `true` = also react to key repeat (the original acted every frame while a key was held)
	if event.is_action_pressed(&"cursor_right", true):
		move_cursor(1)
	elif event.is_action_pressed(&"cursor_left", true):
		move_cursor(-1)
	elif event.is_action_pressed(&"rotate", true):
		puzzle.apply_move(cursor)
	elif event.is_action_pressed(&"scramble", true):
		cursor = puzzle.shuffle_step()
		_refresh()
	elif event.is_action_pressed(&"ui_cancel") and not OS.has_feature("web"):
		get_tree().quit()   # new: the original could only be quit with Ctrl+Esc


func _setup_input() -> void:
	_bind(&"cursor_right", [KEY_RIGHT, KEY_KP_6])     # DIV _right
	_bind(&"cursor_left", [KEY_LEFT, KEY_KP_4])       # DIV _left
	_bind(&"rotate", [KEY_ENTER, KEY_KP_ENTER])       # DIV _enter
	_bind(&"scramble", [KEY_M])                       # DIV _m


func _bind(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k: Key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
