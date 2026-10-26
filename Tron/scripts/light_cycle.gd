class_name LightCycle
extends Node2D
## One light cycle (DIV process Tron).  Every 60 Hz tick it advances `STEPS_PER_TICK`
## pixels, paints its trail into the arena and dies on any non-empty pixel.

signal crashed(cycle: LightCycle)

## DIV Dir values: 1 left, 2 down, 3 right, 4 up.  Turning left = Dir+1, right = Dir-1.
enum Heading { LEFT = 1, DOWN = 2, RIGHT = 3, UP = 4 }

const STEPS_PER_TICK := 11      # DIV: speed=10 -> the inner loop runs 11 times per frame (60 fps = 660 px/s)
const FIRST_TICK_STEPS := 101   # DIV: speedwait=100 at start -> a long first frame

@export var player_name := "Player"
@export var left_action: StringName = &"p1_left"    # DIV: left key parameter
@export var right_action: StringName = &"p1_right"  # DIV: right key parameter
@export var trail_index := 22                       # DIV: color parameter (palette index)
@export var start_heading: Heading = Heading.DOWN   # DIV: dir parameter
@export var start_cell := Vector2i(100, 100)

var alive := true
var heading: Heading
var cell: Vector2i
var _steps_this_tick := FIRST_TICK_STEPS
var _pending_turn := 0   # +1 left, -1 right, consumed on the next step (DIV: key + dclick)

@onready var _arena: Arena = get_parent() as Arena


func _ready() -> void:
	add_to_group(&"cycles")
	heading = start_heading
	cell = start_cell
	position = Vector2(cell)


func _unhandled_input(event: InputEvent) -> void:
	if not alive or event.is_echo():
		return
	# One turn per key press (DIV: dclick blocks until both keys are released again).
	if event.is_action_pressed(left_action):
		_pending_turn += 1
	elif event.is_action_pressed(right_action):
		_pending_turn -= 1


func _physics_process(_delta: float) -> void:
	if not alive:
		return
	for i in _steps_this_tick:
		if not _step():
			return
	_steps_this_tick = STEPS_PER_TICK
	position = Vector2(cell)


## One pixel of movement.  Returns false when the cycle crashed.
func _step() -> bool:
	if _pending_turn != 0:
		heading = (wrapi(int(heading) + signi(_pending_turn) - 1, 0, 4) + 1) as Heading
		_pending_turn = 0
	match heading:
		Heading.LEFT: cell.x -= 1
		Heading.DOWN: cell.y += 1
		Heading.RIGHT: cell.x += 1
		Heading.UP: cell.y -= 1
	if _arena.pixel_at(cell.x, cell.y) != 0:
		_crash()
		return false
	# Screen wrap exactly as written in the original (x=1024 / y=768 are off-map for one step).
	if cell.x < 0: cell.x = 1023
	if cell.y < 0: cell.y = 767
	if cell.x > 1024: cell.x = 1
	if cell.y > 768: cell.y = 1
	_arena.put_pixel(cell.x, cell.y, trail_index)
	return true


func _crash() -> void:
	alive = false
	hide()  # DIV: RETURN ends the process, its sprite disappears; the trail stays
	crashed.emit(self)
