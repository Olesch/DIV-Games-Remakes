class_name Cursor
extends Sprite2D
## The map cursor and unit selection (DIV: process CURSOR). Arrow keys move the cursor (a held key repeats
## after 5 frames, then every frame), Enter selects an own unit, then arrows act with it, Backspace releases it.

const DIR := "res://assets/fpg/undworld/"
const TILE := 10
const REPEAT_DELAY := 5.0 / Game.FPS   # DIV: AntiFast > 4
const REPEAT_RATE := 1.0 / Game.FPS

const DIRECTIONS := {
	&"move_up": Vector2i.UP, &"move_down": Vector2i.DOWN,
	&"move_left": Vector2i.LEFT, &"move_right": Vector2i.RIGHT,
}

var _textures: Dictionary = {}
var _held_action: StringName = &""
var _repeat_timer: Timer


func _ready() -> void:
	centered = false
	z_index = 10
	_repeat_timer = Timer.new()
	_repeat_timer.one_shot = true
	_repeat_timer.timeout.connect(_on_repeat)
	add_child(_repeat_timer)
	Game.cursor_moved.connect(_sync)
	Game.selection_changed.connect(_sync)
	Game.turn_changed.connect(_sync)
	_sync()


func _sync() -> void:
	# DIV graphs: 10/12 = cursor of player 1/2, 11/13 = "chosen"
	var g := 10 + Game.player_turn * 2 + (1 if Game.selected else 0)
	if not _textures.has(g):
		_textures[g] = load("%s%d.png" % [DIR, g])
	texture = _textures[g]
	position = Vector2(Game.cursor_cell * TILE)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey or event is InputEventAction):
		return
	if Game.finished:
		if event.is_action_pressed(&"confirm") and not event.is_echo():
			Game.new_game()
		return
	for action: StringName in DIRECTIONS:
		if event.is_action_pressed(action) and not event.is_echo():
			_held_action = action
			_step(action)
			_repeat_timer.start(REPEAT_DELAY)
			return
		if event.is_action_released(action) and action == _held_action:
			_held_action = &""
			_repeat_timer.stop()
			return
	if event.is_echo():
		return
	if event.is_action_pressed(&"confirm") and not Game.selected:
		Game.select_at_cursor()
	elif event.is_action_pressed(&"cancel"):
		Game.deselect()
	elif event.is_action_pressed(&"end_turn") and not Game.selected:
		Game.end_turn()


func _on_repeat() -> void:
	# repeat only moves the free cursor, a selected unit acts once per key press
	if _held_action != &"" and not Game.selected and not Game.finished:
		_step(_held_action)
		_repeat_timer.start(REPEAT_RATE)


func _step(action: StringName) -> void:
	var target: Vector2i = Game.cursor_cell + DIRECTIONS[action]
	if Game.selected:
		Game.move_cursor(Game.act(Game.cursor_cell, target))
	elif Game.in_bounds(target):
		Game.move_cursor(target)
