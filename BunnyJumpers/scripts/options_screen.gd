class_name OptionsScreen
extends Node2D
## Options screen (new, owner's request 2026-10-26; the original started playing at once).
## Picks how many extra computer bunnies (the original's commented-out FROM loop) join the two
## player bunnies. 0 = the original game. Esc in the game comes back here.

const ROW_EXTRA := 0
const ROW_START := 1
const ROW_Y := [330.0, 390.0]

var _row := ROW_START
var _row_labels: Array[PixelLabel] = []
var _note: PixelLabel


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		_start_autotest_game.call_deferred()
		return
	PixelLabel.make(self, "BUNNYJUMPERS", Vector2(512, 150), 4, 6)
	for i in 2:
		var bunny := Sprite2D.new()
		bunny.texture = Game.BUNNY_TEXTURE
		bunny.scale = Vector2(3, 3)
		bunny.flip_h = i == 1
		bunny.position = Vector2(512 - 120 if i == 0 else 512 + 120, 240)
		add_child(bunny)
	for i in ROW_Y.size():
		_row_labels.append(PixelLabel.make(self, "", Vector2(512, ROW_Y[i]), 4, 3))
	_note = PixelLabel.make(self, "", Vector2(512, 440), 4, 2)
	PixelLabel.make(self, "UP/DOWN SELECT   LEFT/RIGHT CHANGE   ENTER PLAY", Vector2(512, 560), 4, 2)
	PixelLabel.make(self, "BUNNY 1: CURSOR KEYS   BUNNY 2: W A S D   UP / W = JUMP", Vector2(512, 590), 4, 2)
	PixelLabel.make(self, "ESC IN THE GAME: BACK TO THIS SCREEN", Vector2(512, 620), 4, 2)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_down"):
		_row = (_row + 1) % ROW_Y.size()
	elif event.is_action_pressed(&"ui_up"):
		_row = (_row + ROW_Y.size() - 1) % ROW_Y.size()
	elif event.is_action_pressed(&"ui_left", true):
		_change(-1)
	elif event.is_action_pressed(&"ui_right", true):
		_change(1)
	elif event.is_action_pressed(&"ui_accept"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		return
	_refresh()
	get_viewport().set_input_as_handled()


func _change(step: int) -> void:
	if _row == ROW_EXTRA:
		Game.extra_bunnies = clampi(Game.extra_bunnies + step, 0, Game.MAX_EXTRA_BUNNIES)


func _refresh() -> void:
	var texts := [
		"EXTRA BUNNIES:  %d" % Game.extra_bunnies,
		"PLAY",
	]
	for i in texts.size():
		_row_labels[i].set_value(("> %s <" % texts[i]) if i == _row else texts[i])
	if Game.extra_bunnies == 0:
		_note.set_value("0 = THE ORIGINAL GAME: TWO BUNNIES")
	else:
		_note.set_value("EXTRA BUNNIES START AT RANDOM PLACES AND HAVE NO CONTROLS")


## Debug: `-- --autotest [--extra=N]` skips this screen (see debug/autotest.gd).
func _start_autotest_game() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--extra="):
			Game.extra_bunnies = clampi(int(arg.substr("--extra=".length())), 0, Game.MAX_EXTRA_BUNNIES)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
