class_name Runner
extends Node2D
## One sprinter (DIV process Maennchen). The sprite alternates between two graphics; every
## alternating key press (left, right, left, ...) adds speed, friction slows him down.
## Logic is per tick (physics runs at the DIV rate of 24 fps), so the integer arithmetic of the
## original is kept exactly.

signal won
signal fouled

const GOAL_X := 600           # DIV: x>=600 wins
const SPEED_STEP := 3         # DIV: Maennchen(..., speed = 3)
const GRAPH_IDLE := 1
const GRAPH_LEFT_STEP := 2    # shown after pressing the left key
const GRAPH_RIGHT_STEP := 3   # shown after pressing the right key
const GRAPH_WON := 4
const CP0 := Vector2(17, 40)  # control point of graphics 1-4 (assets/fpg/runner/meta.json)

## Input action prefix: "p1" (arrow keys) or "p2" (A / D).
@export var action_prefix: String = "p1"

var racing := false           # DIV: global Start == 1
var has_won := false
var is_foul := false          # DIV: Foul (false start)
var velocity := 0             # DIV: vel (int, whole pixels per tick * 2)
var next_is_left := true      # DIV: LR == 1 means the next valid press is the left key
var _left_down := false
var _right_down := false

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _label: PixelLabel = $FoulLabel


func _ready() -> void:
	_sprite.centered = false
	_sprite.offset = -CP0
	_show_graph(GRAPH_IDLE)
	_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(action_prefix + "_left"):
		_left_down = event.is_pressed()
	elif event.is_action(action_prefix + "_right"):
		_right_down = event.is_pressed()


func start_race() -> void:
	racing = true


func _physics_process(_delta: float) -> void:
	if has_won or (is_foul and racing):
		return  # DIV: LOOP FRAME; END
	if racing:
		if next_is_left:
			if _left_down and not _right_down:
				next_is_left = false
				_show_graph(GRAPH_LEFT_STEP)
				velocity += SPEED_STEP
		elif _right_down and not _left_down:
			next_is_left = true
			_show_graph(GRAPH_RIGHT_STEP)
			velocity += SPEED_STEP
	elif (_left_down or _right_down) and not is_foul:
		is_foul = true  # pressed a key before "LOS"
		_label.visible = true
		fouled.emit()
	@warning_ignore("integer_division")
	velocity -= velocity / 4
	velocity = maxi(velocity, 0)
	@warning_ignore("integer_division")
	position.x += velocity / 2
	if position.x >= GOAL_X:
		_show_graph(GRAPH_WON)
		has_won = true
		won.emit()


func _show_graph(code: int) -> void:
	_sprite.texture = load("res://assets/fpg/runner/%d.png" % code)
