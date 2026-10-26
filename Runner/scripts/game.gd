extends Node2D
## Race flow (DIV main code + Timecounter): "AUF DIE PLAETZE" -> "FERTIG" -> "LOS" -> running
## (the original texts had "..." but Runner.fnt has no dot glyph).
## The physics tick rate is the DIV frame rate (24), so phase lengths are given in ticks.

enum Phase { READY, SET, GO, RACING }

const READY_TICKS := 48  # DIV: FRAME(4800)
const SET_TICKS := 36    # DIV: FRAME(3600)
const GO_TICKS := 36     # DIV: FRAME(3600) while "LOS" is shown
const TICKS_PER_SECOND := 24

var phase := Phase.READY
var ticks_left := READY_TICKS
var seconds := 0   # DIV: Time
var ticks := 0     # DIV: Time24 (a "second" lasts 25 ticks in the original: counts to 24 and wraps at >24)
var finished := false

@onready var _runners: Array[Runner] = [$RunnerRight, $RunnerLeft]
@onready var _title: PixelLabel = $Title
@onready var _name_right: PixelLabel = $NameRight
@onready var _name_left: PixelLabel = $NameLeft
@onready var _time_label: PixelLabel = $Clock/Seconds
@onready var _ticks_label: PixelLabel = $Clock/Ticks
@onready var _clock: Node2D = $Clock


func _ready() -> void:
	_clock.visible = false
	_title.set_value("AUF DIE PLAETZE")
	for runner in _runners:
		runner.won.connect(_on_runner_won)
	if "--autotest" in OS.get_cmdline_user_args():
		var test := preload("res://scripts/debug/autotest.gd").new()
		add_child(test)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart") and phase == Phase.RACING:
		get_tree().reload_current_scene()


func _physics_process(_delta: float) -> void:
	if phase >= Phase.GO:
		_tick_clock()  # DIV: Timecounter starts together with Start=1
	if phase == Phase.RACING:
		return
	ticks_left -= 1
	if ticks_left > 0:
		return
	match phase:
		Phase.READY:
			phase = Phase.SET
			ticks_left = SET_TICKS
			_title.set_value("FERTIG")
		Phase.SET:
			phase = Phase.GO
			ticks_left = GO_TICKS
			_name_right.visible = false
			_name_left.visible = false
			_title.set_value("LOS")
			for runner in _runners:
				runner.start_race()
		Phase.GO:
			phase = Phase.RACING
			_title.set_value("")
			_clock.visible = true


## DIV Timecounter: runs from the start signal, stops when somebody has won.
func _tick_clock() -> void:
	if finished:
		return
	ticks += 1
	if ticks > TICKS_PER_SECOND:
		ticks -= TICKS_PER_SECOND
		seconds += 1
	_time_label.set_value(str(seconds))
	_ticks_label.set_value(str(ticks))


func _on_runner_won() -> void:
	finished = true
	_title.set_value("GEWONNEN")
