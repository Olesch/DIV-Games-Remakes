class_name WindRegulator
extends Node
## Changes the wind smoothly (DIV: PROCESS WindRegulator): after 10 s of calm a new target
## wind in -25..25 is picked, and the wind then moves 1 step towards it every 12 frames.

const CALM_FRAMES := 240  # DIV: frames*10 (24 fps)
const STEP_FRAMES := 12   # DIV: FRAME(1200)

var target: int = 0         # DIV: Windnew
var _calm_counter: int = 0  # DIV: Windchange
var _stepping := false
var _wait := 0


func _ready() -> void:
	target = randi_range(-Game.MAX_WIND, Game.MAX_WIND)


func _physics_process(_delta: float) -> void:
	if _stepping:
		if _wait > 0:
			_wait -= 1
			return
		_step_towards_target()
		return
	_calm_counter += 1
	if _calm_counter > CALM_FRAMES:
		target = randi_range(-Game.MAX_WIND, Game.MAX_WIND)
		_calm_counter = 0
	if Game.wind != target:
		_stepping = true
		_step_towards_target()


func _step_towards_target() -> void:
	Game.wind += signi(target - Game.wind)
	if Game.wind == target:
		_stepping = false
	else:
		_wait = STEP_FRAMES - 1
