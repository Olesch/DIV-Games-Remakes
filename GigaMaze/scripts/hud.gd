extends CanvasLayer
## Status bar (DIV process Leiste + Write_int): score, ammo and life of the four players.

@onready var _bar: Sprite2D = $Bar


func _ready() -> void:
	_bar.texture = Game.tex(20)
	for p in Game.PLAYERS:
		var stats := Game.stats[p]
		var score := _make_label(Vector2(19 + p * 160, 448), 3)
		var ammo := _make_label(Vector2(130 + p * 160, 449), 3)
		var life := _make_label(Vector2(40 + p * 160, 467), 5)
		var refresh := func() -> void:
			score.set_value(str(stats.score))
			ammo.set_value(str(stats.ammo))
			life.set_value(str(stats.life))
		stats.changed.connect(refresh)
		refresh.call()


func _make_label(at: Vector2, align: int) -> PixelLabel:
	var label := PixelLabel.new()
	label.anchor = at
	label.align_code = align
	add_child(label)
	return label
