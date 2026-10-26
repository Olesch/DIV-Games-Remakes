extends CanvasLayer
## Score (top-left), level (top-right, next to the "Level" word graphic), hiscore (bottom-right).
## DIV: Write_int(1,...) x3 and PROCESS Leveltext.

@onready var _score: PixelLabel = $ScoreLabel
@onready var _level: PixelLabel = $LevelLabel
@onready var _hiscore: PixelLabel = $HiScoreLabel


func _ready() -> void:
	Game.score_changed.connect(func() -> void: _score.set_value(Game.score))
	Game.level_changed.connect(func() -> void: _level.set_value(Game.level))
	Game.hiscore_changed.connect(func() -> void: _hiscore.set_value(Game.hiscore))
	_score.set_value(Game.score)
	_level.set_value(Game.level)
	_hiscore.set_value(Game.hiscore)
