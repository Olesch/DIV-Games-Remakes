extends CanvasLayer
## Numbers on screen. DIV: write_int(0, ...) of Movement, Weite and Hiscore.

@onready var movement_label: PixelLabel = $MovementLabel
@onready var distance_label: PixelLabel = $DistanceLabel
@onready var hiscore_label: PixelLabel = $HiscoreLabel


func _ready() -> void:
	Game.movement_changed.connect(func(v: int) -> void: movement_label.set_value(str(v)))
	Game.distance_changed.connect(func(v: int) -> void: distance_label.set_value(str(v)))
	Game.hiscore_changed.connect(func(v: int) -> void: hiscore_label.set_value(str(v)))
	movement_label.set_value(str(Game.movement))
	distance_label.set_value(str(Game.distance))
	hiscore_label.set_value(str(Game.hiscore))
