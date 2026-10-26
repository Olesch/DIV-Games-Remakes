class_name Meter
extends Node
## The arm-speed meter. DIV: process Movementometer. Alternating Left / Right presses (starting
## with Left) each add 5 to Game.movement; it decays every tick by 1 + movement/17; range 0..50.
## Only active once the wind-up has started.

const GAIN := 5
const MAX_MOVEMENT := 50

## true: next expected press is Right (DIV: Wkey == 1)
var _expect_right := false


func _unhandled_input(event: InputEvent) -> void:
	if Game.stage <= 0:
		return
	if event.is_action_pressed(&"pump_left") and not _expect_right:
		_expect_right = true
		Game.movement += GAIN
	elif event.is_action_pressed(&"pump_right") and _expect_right:
		_expect_right = false
		Game.movement += GAIN


func _physics_process(_delta: float) -> void:
	if Game.stage > 0:
		@warning_ignore("integer_division")
		Game.movement = clampi(Game.movement - (1 + Game.movement / 17), 0, MAX_MOVEMENT)
