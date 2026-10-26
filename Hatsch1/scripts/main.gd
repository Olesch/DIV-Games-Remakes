extends Node2D
## The arena (DIV main code): background, three ships, life counters in the corners.
## Enter restarts the round (new; the original had no end or restart).

@onready var _hud_a: PixelLabel = $Hud/LifeA
@onready var _hud_b: PixelLabel = $Hud/LifeB
@onready var _hud_c: PixelLabel = $Hud/LifeC


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())
	($ShipA as Ship).life_changed.connect(func(v: int) -> void: _hud_a.set_value(str(v)))
	($ShipB as Ship).life_changed.connect(func(v: int) -> void: _hud_b.set_value(str(v)))
	($ShipC as Ship).life_changed.connect(func(v: int) -> void: _hud_c.set_value(str(v)))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart"):
		get_tree().reload_current_scene()
