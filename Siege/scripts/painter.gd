@warning_ignore_start("integer_division")
class_name Painter
extends Node2D
## DIV PROCESS Painter: redraws the landscape every frame (sky + hills, 3 birds, 6 drifting clouds, both
## castles) on the background. Purely decorative, drawn below every unit.

const SKY_Y := 110
const CASTLE_LEFT := Vector2i(29, 221)
const CASTLE_RIGHT := Vector2i(290, 221)

class Bird:
	var x := 0
	var y := 0
	var graph := 0
	var dir := 0
	var shown := false

class Cloud:
	var x := 0     # in half pixels (DIV drew it at x/2)
	var y := 0
	var graph := 0
	var shown := false

var _birds: Array[Bird] = []
var _clouds: Array[Cloud] = []
var _wind_dir := 0
var _wind_timer := 0


func _ready() -> void:
	for i in 3:
		_birds.append(Bird.new())
	for i in 6:
		var c := Cloud.new()
		c.x = 64 * i * 2
		c.y = randi_range(122, 170)
		c.graph = 58
		_clouds.append(c)


## One game frame (state only; drawing happens in _draw).
func _physics_process(_delta: float) -> void:
	# birds
	for b in _birds:
		b.shown = false
		if b.x > 340 or b.x < -20 or b.y < 122:
			if randi_range(0, 70) == 0:
				b.dir = 2 * randi_range(0, 1) - 1
				b.x = 160 - 170 * b.dir
				b.y = randi_range(122, 200)
				b.graph = 50
		else:
			b.graph += 1
			if b.graph > 57 or b.graph < 50:
				b.graph = 50
			b.x += b.dir * (2 + randi_range(0, 1))
			b.shown = true
	# clouds
	for c in _clouds:
		c.shown = false
		if c.x > 360 * 2 or c.x < -40 * 2 or c.y < 122:
			if randi_range(0, 40) == 0:
				if _wind_dir > 0:
					c.x = -30 * 2
					c.y = randi_range(122, 170)
					c.graph = 58
				if _wind_dir < 0:
					c.x = 350 * 2
					c.y = randi_range(122, 170)
					c.graph = 58
				if _wind_dir == 0:
					c.x = 0
					c.y = 0
					c.graph = 0
		else:
			c.x += _wind_dir * (1 + randi_range(-2, 2) / 2)
			c.shown = true
	# wind direction
	_wind_timer += 1
	if _wind_timer > 130:
		_wind_timer = 0
		_wind_dir = clampi(_wind_dir + randi_range(-1, 1), -1, 1)
	queue_redraw()


func _draw() -> void:
	draw_texture(Gfx.tex(40), Vector2(0, SKY_Y))
	for b in _birds:
		if b.shown:
			_draw_graph(b.graph, Vector2(b.x, b.y), b.dir < 0)
	for c in _clouds:
		if c.shown and c.graph > 0:
			_draw_graph(c.graph, Vector2(c.x / 2, c.y), false)
	_draw_graph(41, Vector2(CASTLE_LEFT), false)
	_draw_graph(41, Vector2(CASTLE_RIGHT), true)


func _draw_graph(code: int, pos: Vector2, mirror: bool) -> void:
	var tex := Gfx.tex(code)
	var cp := Gfx.cp0(code)
	if mirror:
		draw_set_transform(pos, 0.0, Vector2(-1, 1))
		draw_texture(tex, -cp)
	else:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_texture(tex, pos - cp)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
