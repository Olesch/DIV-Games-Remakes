class_name Worm
extends Node2D
## DIV processes worm_head + worm_segment. The head is invisible (size=0); the segments are the places
## the head visited 1..worm_length-1 steps ago, so the body is just a trail of cells drawn in _draw().
## One step() per game tick (20 per second, like set_fps(20)).

signal crashed

const SEGMENT_TEXTURE := preload("res://assets/fpg/tutor4/2.png")  # graph 2, control point (0,0)

var head: Vector2i
var direction := Vector2i(Game.STEP, 0)
var active := false
var _trail: Array[Vector2i] = []   # _trail[0] = head position one step ago


func _ready() -> void:
	add_to_group(&"worm")
	reset()


func reset() -> void:
	head = Game.START_CELL
	direction = Vector2i(Game.STEP, 0)
	# every segment starts on top of the head (they copy father.x/y when created)
	_trail.clear()
	_trail.resize(Game.MAX_SEGMENTS)
	_trail.fill(head)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not active or event.is_echo() or not event.is_pressed():
		return
	var s := Game.STEP
	if event.is_action(&"move_up_right"):
		steer(Vector2i(s, -s))
	elif event.is_action(&"move_up_left"):
		steer(Vector2i(-s, -s))
	elif event.is_action(&"move_down_left"):
		steer(Vector2i(-s, s))
	elif event.is_action(&"move_down_right"):
		steer(Vector2i(s, s))
	elif event.is_action(&"move_right"):
		steer(Vector2i(s, 0))
	elif event.is_action(&"move_left"):
		steer(Vector2i(-s, 0))
	elif event.is_action(&"move_down"):
		steer(Vector2i(0, s))
	elif event.is_action(&"move_up"):
		steer(Vector2i(0, -s))


## DIV ix,iy: the head keeps moving in this direction every step.
func steer(new_direction: Vector2i) -> void:
	direction = new_direction


## One game frame of the head: eat an apple on the current cell, move, then test wall and own body.
func step() -> void:
	for apple: Apple in get_tree().get_nodes_in_group(&"apples"):
		if Vector2i(apple.position) == head:
			apple.remove_from_group(&"apples")
			apple.queue_free()
			Game.eat_apple()
			break
	_trail.push_front(head)
	_trail.resize(Game.MAX_SEGMENTS)
	head += direction
	queue_redraw()
	if Game.is_wall(head) or _hits_body():
		crashed.emit()


## Would moving the head onto this cell kill the worm? (used by the autotest bot)
func is_deadly(cell: Vector2i) -> bool:
	return Game.is_wall(cell) or _trail.slice(0, visible_segments()).has(cell)


func visible_segments() -> int:
	return clampi(Game.worm_length - 1, 0, Game.MAX_SEGMENTS)  # DIV: priority < worm_length


func _hits_body() -> bool:
	for i in visible_segments():
		if _trail[i] == head:
			return true
	return false


func _draw() -> void:
	for i in visible_segments():
		draw_texture(SEGMENT_TEXTURE, Vector2(_trail[i]))
