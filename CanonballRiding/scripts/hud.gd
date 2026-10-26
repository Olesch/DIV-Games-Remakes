class_name Hud
extends CanvasLayer
## All on-screen text (DIV write / write_int / delete_text(all_text)).

@onready var _menu_labels: Array[Node] = [
	$Title, $Credit, $OnePlayer, $TwoPlayers, $Hi1Caption, $Hi2Caption, $Hi1Value, $Hi2Value]
@onready var _score: PixelLabel = $Score
@onready var _final_score: PixelLabel = $FinalScore
@onready var _hi1: PixelLabel = $Hi1Value
@onready var _hi2: PixelLabel = $Hi2Value


func _ready() -> void:
	Game.score_changed.connect(_on_score_changed)
	Game.hiscores_changed.connect(_refresh_hiscores)
	_refresh_hiscores()


func show_menu() -> void:
	for label: Node in _menu_labels:
		label.visible = true
	_score.visible = false
	_final_score.visible = false


## Title texts replaced by the live score at the top centre.
func show_game() -> void:
	for label: Node in _menu_labels:
		label.visible = false
	_on_score_changed(Game.score)
	_score.visible = true
	_final_score.visible = false


## After the game: the score moves to the middle of the screen.
func show_game_over() -> void:
	_score.visible = false
	_final_score.set_value(str(Game.score))
	_final_score.visible = true


func _on_score_changed(value: int) -> void:
	_score.set_value(str(value))


func _refresh_hiscores() -> void:
	_hi1.set_value(str(Game.hiscores[1]))
	_hi2.set_value(str(Game.hiscores[2]))
