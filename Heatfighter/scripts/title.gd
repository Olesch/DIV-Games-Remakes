class_name Title
extends Node2D
## Setup screen (new; the original had no menu - its main code hard-wired player 1 = human,
## player 2 = computer, both "Chain"). Choose human/computer and a fighter for each side.

const ROW_CONTROL_1 := 0
const ROW_FIGHTER_1 := 1
const ROW_CONTROL_2 := 2
const ROW_FIGHTER_2 := 3
const ROW_START := 4
const ROW_Y := [200.0, 230.0, 270.0, 300.0, 350.0]
const CHARACTERS := [Defs.Character.TEMPLATE, Defs.Character.CHAIN, Defs.Character.EIGEN]

var _row := ROW_START
var _row_labels: Array[PixelLabel] = []
var _previews: Array[Sprite2D] = []


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		_start_autotest_match.call_deferred()
		return
	PixelLabel.make(self, "HEATFIGHTER", Vector2(320, 60), 4, 5)
	PixelLabel.make(self, "COOLFIGHTER IN 2D", Vector2(320, 110), 4, 2)
	for i in ROW_Y.size():
		_row_labels.append(PixelLabel.make(self, "", Vector2(320, ROW_Y[i]), 4, 2))
	PixelLabel.make(self, "UP/DOWN SELECT   LEFT/RIGHT CHANGE   ENTER FIGHT", Vector2(320, 392), 4)
	PixelLabel.make(self, "PLAYER 1:  X V = LEFT RIGHT   D = JUMP   C = DUCK   1 = LIGHT   2 = STRONG",
		Vector2(320, 420), 4)
	PixelLabel.make(self, "PLAYER 2:  CURSOR KEYS   9 / , = LIGHT   0 / . = STRONG", Vector2(320, 436), 4)
	PixelLabel.make(self, "SPECIALS: DOWN THEN BACK + LIGHT (TEMPLATE/CHAIN),  DOWN-FORWARD / BACK-DOWN-FORWARD (EIGEN)",
		Vector2(320, 456), 4)
	for i in 2:
		var preview := Sprite2D.new()
		preview.position = Vector2(110 if i == 0 else 530, 270)
		add_child(preview)
		_previews.append(preview)
	_refresh()
	for preview in _previews:
		preview.reset_physics_interpolation()  # _refresh() set the 2x scale: show it at once


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_down"):
		_row = (_row + 1) % ROW_Y.size()
	elif event.is_action_pressed(&"ui_up"):
		_row = (_row + ROW_Y.size() - 1) % ROW_Y.size()
	elif event.is_action_pressed(&"ui_left"):
		_change(-1)
	elif event.is_action_pressed(&"ui_right"):
		_change(1)
	elif event.is_action_pressed(&"ui_accept"):
		get_tree().change_scene_to_file("res://scenes/arena.tscn")
	else:
		return
	_refresh()
	get_viewport().set_input_as_handled()


func _change(step: int) -> void:
	match _row:
		ROW_CONTROL_1:
			Game.is_cpu[0] = not Game.is_cpu[0]
		ROW_CONTROL_2:
			Game.is_cpu[1] = not Game.is_cpu[1]
		ROW_FIGHTER_1, ROW_FIGHTER_2:
			var player := 0 if _row == ROW_FIGHTER_1 else 1
			var index := CHARACTERS.find(Game.characters[player])
			Game.characters[player] = CHARACTERS[(index + step + CHARACTERS.size()) % CHARACTERS.size()]


func _refresh() -> void:
	var texts := [
		"PLAYER 1:  %s" % ("COMPUTER" if Game.is_cpu[0] else "HUMAN"),
		"FIGHTER 1:  %s" % Defs.CHARACTER_NAMES[Game.characters[0]],
		"PLAYER 2:  %s" % ("COMPUTER" if Game.is_cpu[1] else "HUMAN"),
		"FIGHTER 2:  %s" % Defs.CHARACTER_NAMES[Game.characters[1]],
		"START FIGHT",
	]
	for i in texts.size():
		_row_labels[i].set_value(("> %s <" % texts[i]) if i == _row else texts[i])
	var same: bool = Game.characters[0] == Game.characters[1]
	for i in 2:
		var set_name: String = Gfx.CHARACTER_SETS[Game.characters[i]]
		_previews[i].texture = Gfx.texture(set_name, 1, i == 1 and same)
		_previews[i].scale = Vector2(2, 2)
		_previews[i].flip_h = i == 1


## Debug: `-- --autotest [--chars=2,3] [--scripted]` skips the menu (see debug/autotest.gd).
func _start_autotest_match() -> void:
	var args := OS.get_cmdline_user_args()
	Game.is_cpu = [not ("--scripted" in args), true]
	for arg in args:
		if arg.begins_with("--chars="):
			var parts := arg.substr("--chars=".length()).split(",")
			Game.characters = [int(parts[0]), int(parts[1])]
	get_tree().change_scene_to_file("res://scenes/arena.tscn")
