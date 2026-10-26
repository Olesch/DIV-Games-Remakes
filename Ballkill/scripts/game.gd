extends Node
## Autoload "Game": global state of Ballkill (DIV GLOBAL: Level, Ballcount, Score, HiScore).

signal score_changed
signal level_changed
signal hiscore_changed

const SAVE_PATH := "user://ballkill.dat"  # DIV: Sav\Ballkill.dat (one int32)

var level: int = 0
var ball_count: int = 0  # DIV: Ballcount - balls currently alive
var score: int = 0
var hiscore: int = 0


func _ready() -> void:
	load_hiscore()


func new_game() -> void:
	level = 0
	ball_count = 0
	score = 0
	score_changed.emit()
	level_changed.emit()


func add_score(points: int) -> void:
	score += points
	score_changed.emit()


func next_level() -> void:
	level += 1
	level_changed.emit()


## Called when a ball escaped: remember the best score (DIV: save("Sav\Ballkill.dat", ...)).
func submit_score() -> void:
	if score > hiscore:
		hiscore = score
		hiscore_changed.emit()
		save_hiscore()


func load_hiscore() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			hiscore = file.get_32()
			hiscore_changed.emit()


func save_hiscore() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(hiscore)
