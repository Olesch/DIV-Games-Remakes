class_name Hud
extends CanvasLayer
## Scores in the four corners (DIV write_int of Pointsa..d), the energy bars (Energyline) and the
## "GET READY" text.

const HIDDEN := Vector2(-800, -800)  # parking spot of an unused energy bar

@onready var point_labels: Array[PixelLabel] = [$PointsA, $PointsB, $PointsC, $PointsD]
@onready var get_ready: PixelLabel = $GetReady

var _bars: Array[Sprite2D] = []


func _ready() -> void:
	for i in 4:
		var bar := Sprite2D.new()
		Gfx.apply(bar, Gfx.ENERGY_LINE)
		bar.position = HIDDEN
		add_child(bar)
		_bars.append(bar)
	Game.points_changed.connect(_update_points)
	_update_points()
	set_get_ready(false)


func set_get_ready(on: bool) -> void:
	get_ready.visible = on
	get_ready.set_value("GET READY")


func _update_points() -> void:
	for i in 4:
		point_labels[i].set_value(str(Game.points[i]))


func _physics_process(_delta: float) -> void:
	# Energyline: bar position = energy in percent; players A/C count from the right, B/D from the left
	var step := maxi(Game.max_energy / 100, 1)
	for i in 4:
		var ship: Ship = Game.ships[i]
		if not is_instance_valid(ship) or Game.ship_mode[i] == 0:
			_place_bar(_bars[i], HIDDEN)
			continue
		var level := ship.energy / step
		match i:
			0: _place_bar(_bars[i], Vector2(800 - level, 590))
			1: _place_bar(_bars[i], Vector2(level - 100, 10))
			2: _place_bar(_bars[i], Vector2(800 - level, 10))
			3: _place_bar(_bars[i], Vector2(level - 100, 590))


## A bar appearing (ship spawned) or vanishing (ship died) jumps instead of sliding across the screen.
func _place_bar(bar: Sprite2D, pos: Vector2) -> void:
	var jumped := (bar.position == HIDDEN) != (pos == HIDDEN)
	bar.position = pos
	if jumped:
		bar.reset_physics_interpolation()
