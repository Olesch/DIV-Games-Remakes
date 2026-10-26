class_name AtomCursor
extends Sprite2D
## DIV: PROCESS Cursor. Moves over the grid, places atoms, sets their bonds and uses bombs.
## Input arrives through _unhandled_input; a move is a Tween and blocks input while it runs.

signal molecule_checked

const START := Vector2(200, 130)
const CELL := 40.0
const FPS := 18.0                          # DIV frame rate (set_fps default)
const SLIDE_TIME := 4.0 / FPS          # DIV: 4 frames per cell
const MOLECULE_SHOW_TIME := 2.0 / FPS  # DIV: FRAME(200) before a finished molecule vanishes

var active := false
var _busy := false
var _xpos := 0
var _ypos := 0
var _tween: Tween
var _epoch := 0


func _ready() -> void:
	visible = false


func start() -> void:
	_epoch += 1
	position = START
	_xpos = 0
	_ypos = 0
	_busy = false
	active = true
	visible = true


func stop() -> void:
	_epoch += 1
	active = false
	_busy = false
	visible = false
	if _tween:
		_tween.kill()


func _unhandled_input(event: InputEvent) -> void:
	if not active or _busy or not event.is_pressed():
		return
	if Game.cursor_state == 0:
		_input_moving(event)
	else:
		_input_connecting(event)


func _input_moving(event: InputEvent) -> void:
	var board := Game.board
	# arrows repeat while held (echo)
	if event.is_action_pressed(&"up", true):
		if _ypos > 0:
			_ypos -= 1
			_slide(Vector2.UP)
	elif event.is_action_pressed(&"down", true):
		if _ypos < board.field:
			_ypos += 1
			_slide(Vector2.DOWN)
	elif event.is_action_pressed(&"left", true):
		if _xpos > 0:
			_xpos -= 1
			_slide(Vector2.LEFT)
	elif event.is_action_pressed(&"right", true):
		if _xpos < board.field:
			_xpos += 1
			_slide(Vector2.RIGHT)
	elif event.is_action_pressed(&"confirm"):
		var c := board.cell(_xpos, _ypos)
		if not c.exists:
			Game.cursor_state = 1
			c.exists = true
	elif event.is_action_pressed(&"bomb"):
		var c := board.cell(_xpos, _ypos)
		if Game.bombs > 0 and c.exists:
			Game.bombs -= 1
			c.clear()
	else:
		return
	get_viewport().set_input_as_handled()


func _input_connecting(event: InputEvent) -> void:
	var c := Game.board.cell(_xpos, _ypos)
	var conn := Game.connections
	if conn[0] <= 0:
		return
	if event.is_action_pressed(&"up") and not c.up:
		c.up = true
	elif event.is_action_pressed(&"down") and not c.down:
		c.down = true
	elif event.is_action_pressed(&"left") and not c.left:
		c.left = true
	elif event.is_action_pressed(&"right") and not c.right:
		c.right = true
	else:
		return
	get_viewport().set_input_as_handled()
	conn[0] -= 1
	if conn[0] == 0:
		_complete_atom()


func _slide(direction: Vector2) -> void:
	_busy = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", position + direction * CELL, SLIDE_TIME)
	_tween.finished.connect(func() -> void: _busy = false)


## All bonds are set: check the molecule, show it briefly, then remove it and score.
func _complete_atom() -> void:
	_busy = true
	Game.board.check(_xpos, _ypos)
	var epoch := _epoch
	await get_tree().create_timer(MOLECULE_SHOW_TIME).timeout
	if epoch != _epoch:
		return   # the round was ended meanwhile
	Game.resolve_kill()
	var conn := Game.connections
	for i in Game.con_info:
		conn[i] = conn[i + 1]
	conn[Game.con_info] = Game.random_connections()
	Game.cursor_state = 0
	_busy = false
	molecule_checked.emit()
