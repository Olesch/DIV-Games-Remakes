extends CanvasLayer
## DIV: the write_int() texts - life of both players (top corners) and living tanks per team.

@onready var _life: Array[PixelLabel] = [null, $Life1, $Life2]
@onready var _team: Array[PixelLabel] = [null, $Team1, $Team2]
@onready var _winner: PixelLabel = $Winner


func _ready() -> void:
	_winner.hide()
	Game.winner_declared.connect(_on_winner)


func _process(_delta: float) -> void:
	for i in [1, 2]:
		_life[i].set_value(str(Game.player_life[i]))
		_team[i].set_value(str(Game.team_count[i]))


func _on_winner(team: int) -> void:
	_winner.set_value("TEAM %d WINS - ESC FOR NEW MATCH" % team)
	_winner.show()
