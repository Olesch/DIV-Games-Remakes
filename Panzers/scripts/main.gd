extends Node2D
## The main code of PANZERS.PRG: grass background and two tanks.
## New (owner's decision 2026-10-26): unless the options chose the sandbox, the round ends when
## at most one tank is left, with a winner message. Enter = new round, Esc = options screen.

const OPTIONS_SCENE := "res://scenes/options.tscn"

var round_over: bool = false
var _tanks: Array[Tank] = []

@onready var _hud: Hud = $Hud


func _ready() -> void:
	var bg := $Background as Sprite2D
	bg.material = Camo.material_for(bg.texture)  # DIV: Graszeichner(4) + put_screen(0,4)
	for node in get_children():
		if node is Tank:
			_tanks.append(node)
	_hud.visible = not Game.is_sandbox()
	for i in _tanks.size():
		_tanks[i].destroyed.connect(_on_tank_destroyed)
		_hud.show_life(i, _tanks[i].life)
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _process(_delta: float) -> void:
	if not Game.is_sandbox():
		for i in _tanks.size():
			_hud.show_life(i, _tanks[i].life)


func tanks() -> Array[Tank]:
	return _tanks


func winner_text() -> String:
	return _hud.winner_text()


func _on_tank_destroyed() -> void:
	if round_over:
		return
	var living := _tanks.filter(func(t: Tank) -> bool: return t.alive)
	if living.size() > 1:
		return
	# A shell may finish off the other tank in the same frame: decide at the end of the frame.
	_end_round.call_deferred()


func _end_round() -> void:
	if round_over:
		return
	round_over = true
	var living := _tanks.filter(func(t: Tank) -> bool: return t.alive)
	if living.is_empty():
		_hud.show_winner("DRAW")
	else:
		_hud.show_winner("PLAYER %d WINS" % (_tanks.find(living[0]) + 1))


func _unhandled_input(event: InputEvent) -> void:
	# New: Esc goes back to the options screen (the original needed Ctrl+Esc to quit);
	# Enter after the round end starts a new one with the same options.
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(OPTIONS_SCENE)
	elif round_over and event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()
