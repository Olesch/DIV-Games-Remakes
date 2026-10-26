class_name Spawner
extends Node
## Releases balls from the screen edges. DIV: the main program's LOOP.
##   x = rand(1,4): 1 top edge, 2 bottom edge, 3 left edge, 4 right edge - but side 4 releases
##   FOUR balls 4 frames apart (FRAME(400) between them), so the right edge gets 4x as many.
##   Then FRAME(600): wait 6 frames.
## Counted in physics ticks (100 per second = the original's set_fps(100,0)).

enum Side { TOP = 1, BOTTOM = 2, LEFT = 3, RIGHT = 4 }

const BALL_SCENE: PackedScene = preload("res://scenes/ball.tscn")
const CYCLE_WAIT := 6  # DIV: FRAME(600)
const BURST_WAIT := 4  # DIV: FRAME(400)
const BURST_EXTRA := 3  # three more right-edge balls after the first one
const WIDTH_TENTHS := 10240
const HEIGHT_TENTHS := 7680

@export var cluster: Cluster
@export var ball_parent: Node2D

var spawned := 0
var escaped := 0

var _ticks_left := 1
var _burst_left := 0


func reset() -> void:
	_ticks_left = 1
	_burst_left = 0
	spawned = 0
	escaped = 0


func _physics_process(_delta: float) -> void:
	_ticks_left -= 1
	if _ticks_left > 0:
		return
	if _burst_left > 0:
		_burst_left -= 1
		_spawn(Side.RIGHT)
		_ticks_left = BURST_WAIT if _burst_left > 0 else CYCLE_WAIT
		return
	var side := randi_range(1, 4)
	_spawn(side)
	if side == Side.RIGHT:
		_burst_left = BURST_EXTRA
		_ticks_left = BURST_WAIT
	else:
		_ticks_left = CYCLE_WAIT


func _spawn(side: int) -> void:
	var start: Vector2i
	match side:
		Side.TOP:
			start = Vector2i(randi_range(0, WIDTH_TENTHS), 0)
		Side.BOTTOM:
			start = Vector2i(randi_range(0, WIDTH_TENTHS), HEIGHT_TENTHS)
		Side.LEFT:
			start = Vector2i(0, randi_range(0, HEIGHT_TENTHS))
		Side.RIGHT:
			start = Vector2i(WIDTH_TENTHS, randi_range(0, HEIGHT_TENTHS))
	var ball := BALL_SCENE.instantiate() as Ball
	ball.setup(start, cluster)
	ball.escaped.connect(func() -> void: escaped += 1)
	ball_parent.add_child(ball)
	spawned += 1
	ball.fly()  # a new DIV process runs up to its first FRAME at once
