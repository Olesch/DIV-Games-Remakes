extends Node2D
## Playfield: background, two bats, ball spawner and the "Wins" banner.

const WIN_TEXT := {
	1: " < Wins   ",   # DIV: pointsb-500>pointsa (left player wins)
	2: "   Wins > ",    # DIV: pointsa-500>pointsb (right player wins)
}
const BANNER_ROWS := [240, 230, 250, 220, 260]   # DIV writes the text five times at these y values
const PIXEL_LABEL := preload("res://scenes/pixel_label.tscn")
const OPTIONS_SCENE := "res://scenes/options.tscn"


func _ready() -> void:
	Game.reset()
	Game.winner_declared.connect(_show_winner)
	$Bat1.computer = Game.computer[0]
	$Bat2.computer = Game.computer[1]
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(preload("res://scripts/debug/autotest.gd").new())


func _show_winner(player: int) -> void:
	for y: int in BANNER_ROWS:
		var label := PIXEL_LABEL.instantiate() as PixelLabel
		$Banner.add_child(label)
		label.place(Vector2(320, y), WIN_TEXT[player])


func _unhandled_input(event: InputEvent) -> void:
	# New (the original just kept running): Enter/Space after a win, or Esc at any time, goes back to
	# the options screen, where Enter starts the next match.
	if (Game.winner != 0 and event.is_action_pressed(&"restart")) or event.is_action_pressed(&"ui_cancel"):
		get_tree().change_scene_to_file(OPTIONS_SCENE)
