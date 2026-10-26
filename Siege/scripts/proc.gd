class_name Proc
extends Sprite2D
## Base of everything that was a DIV PROCESS with a graphic (units, shots, animations, cursors ...).
## DIV semantics kept here: integer x/y (position of control point 0), graph, angle (1/1000 deg, counter
## clockwise), size (%), flags (bit 1 = mirrored), z (lower = in front). The game logic runs once per DIV
## frame = one physics tick (18/s); a new process runs its first frame immediately when it is created
## (like calling a PROCESS in DIV).

var world: World
var x := 0
var y := 0
var graph := 0
var angle := 0
var size := 100
var flags := 0
var z := 0
var alive := true

var _seq: Array = []
var _seq_index := -1
var _born_tick := -1


func _init() -> void:
	centered = false


## Code a DIV process runs before its first FRAME; called by World right after the node entered the tree.
func begin() -> void:
	pass


func _enter_tree() -> void:
	_born_tick = Engine.get_physics_frames()


## Game logic runs once per physics tick (the project runs at the game's 18 ticks per second).
func _physics_process(_delta: float) -> void:
	if not alive or Engine.get_physics_frames() == _born_tick:
		return   # a process created during a tick already ran its first frame
	_frame()
	if alive:
		sync_view()


func _frame() -> void:
	pass


func sync_view() -> void:
	if graph > 0:
		var tex := Gfx.tex(graph)
		if tex != texture:
			texture = tex
			offset = -Gfx.cp0(graph)
	visible = graph > 0 and size > 0
	position = Vector2(x, y)
	rotation = -deg_to_rad(angle / 1000.0)
	var s := size / 100.0
	scale = Vector2(-s if (flags & 1) != 0 else s, s)
	z_index = -z


func finish() -> void:
	alive = false
	visible = false
	queue_free()


## Sequence of [Callable, frames] steps; the callable runs when the step is entered, the step then lasts
## `frames` game frames (DIV: statements followed by FRAME(frames*100)) and is timed with a SceneTreeTimer.
## The node frees itself after the last step.
func play(steps: Array) -> void:
	_seq = steps
	_seq_index = -1
	_seq_advance()


func _seq_advance() -> void:
	if not alive:
		return
	_seq_index += 1
	if _seq_index >= _seq.size():
		finish()
		return
	var step: Array = _seq[_seq_index]
	(step[0] as Callable).call()
	var timer := get_tree().create_timer(float(step[1]) / Game.fps, true, true)
	timer.timeout.connect(_on_step_timeout)


func _on_step_timeout() -> void:
	_seq_advance()
	if alive:
		sync_view()
