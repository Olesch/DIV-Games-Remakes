class_name Atom
extends Node
## DIV: PROCESS Atom() - the atom bomb: one huge explosion in the middle of the screen, and
## for four frames every meteor on screen is hit (the original makes each meteor spawn a
## rocket on itself every frame while AtomBombe is set).

const PULSES := 4

var _pulses_left := PULSES

@onready var _timer: Timer = $Timer


func _ready() -> void:
	Explosion.spawn(get_parent(), Defs.SCREEN_SIZE / 2.0, 1200)
	_timer.timeout.connect(_on_pulse)
	_timer.start(1.0 / Defs.FPS)


func _on_pulse() -> void:
	Game.atom_blast.emit()
	_pulses_left -= 1
	if _pulses_left <= 0:
		Game.atom_active = false
		queue_free()
