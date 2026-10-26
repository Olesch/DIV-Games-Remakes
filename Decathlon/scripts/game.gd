extends Node
## Autoload "Game": the GLOBAL section of DECATLON.PRG (Spacestufe, Movement, Weite, Hiscore)
## plus the hiscore file in user://.

signal stage_changed(value: int)
signal movement_changed(value: int)
signal distance_changed(value: int)
signal hiscore_changed(value: int)

## DIV: the game runs at the default 18 fps (no set_fps call). One tick = one DIV frame.
const TICKS_PER_SECOND := 18
const SAVE_PATH := "user://decatlon.dat"
## Value stored in the original DAT\DECATLON.DAT (one int32).
const DEFAULT_HISCORE := 1004

## Set to false by the autotest so it never touches the real hiscore file.
var persist := true

## Wind-up stage, 0 = waiting, 1 = upper arm swings, 2 = forearm swings, >=3 = release.
## DIV: Spacestufe
var stage: int = 0:
	set(value):
		stage = value
		stage_changed.emit(stage)

## Arm speed bonus from alternating Left/Right. DIV: Movement
var movement: int = 0:
	set(value):
		movement = value
		movement_changed.emit(movement)

## Throw distance in pixels. DIV: Weite
var distance: int = 0:
	set(value):
		distance = value
		distance_changed.emit(distance)

## DIV: Hiscore
var hiscore: int = DEFAULT_HISCORE


func _ready() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file != null and file.get_length() >= 4:
			hiscore = file.get_32()


## Starts a new attempt (the reset block at the end of the DIV main loop).
func reset_attempt() -> void:
	stage = 0
	movement = 0
	distance = 0


## Stores a new record, returns true if it was one.
func submit_distance(value: int) -> bool:
	distance = value
	if value <= hiscore:
		return false
	hiscore = value
	hiscore_changed.emit(hiscore)
	if persist:
		var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_32(hiscore)
	return true
