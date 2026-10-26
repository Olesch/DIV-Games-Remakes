class_name ComputerPlayer
extends Node
## DIV PROCESS KI(player) ("DIE KI!"): the computer opponent. The PRG has it written but its call `KI(1)` is
## commented out; the setup page starts one for every side set to COMPUTER.
## What the original KI does (nothing more): every KI_WAIT frames it draws counter = rand(0, 20) and, if
## counter < 20 (20 of 21 cases), sends one warrior Unit(1, player). It never touches its element field and pays
## nothing for the warriors. (The ELSE branch `counter -= 20` has no effect: counter is redrawn every pass.)
## Counted in game frames = physics ticks (18/s), like the rest of the port.

const KI_WAIT := 24   # DIV: FOR (wait=24; wait>0; wait--) FRAME; END  -> 24 frames (1.33 s at 18 fps)

var player := 0
var world: World

var _ticks_left := 0


func _ready() -> void:
	# the DIV process runs its first loop pass as soon as it is created
	_decide()


func _physics_process(_delta: float) -> void:
	_ticks_left -= 1
	if _ticks_left <= 0:
		_decide()


func _decide() -> void:
	var counter := randi_range(0, 20)
	if counter < 20:
		world.spawn_unit(Defs.UnitArt.KRIEGER, player)
	_ticks_left = KI_WAIT
