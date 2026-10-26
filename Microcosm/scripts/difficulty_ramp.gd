class_name DifficultyRamp
extends Node
## DIV: PROCESS Schwerer() - slowly raises Game.ramp (meteors come faster) and, every time it
## passes 4000, drops it back and unlocks the next meteor kind.

@onready var _timer: Timer = $Timer


func _ready() -> void:
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	_tick()


func _tick() -> void:
	Game.ramp += 1
	# DIV: FRAME(200), plus one more frame for each of the thresholds 1200 / 2400 / 3600 passed.
	var frames := 2
	for threshold in [1200, 2400, 3600]:
		if Game.ramp > threshold:
			frames += 1
	_timer.start(frames / Defs.FPS)


func _on_timeout() -> void:
	if Game.ramp > 4000:
		Game.ramp = 1200 + Game.super_meteors * 400
		Game.super_meteors = mini(Game.super_meteors + 1, 3)
	_tick()
