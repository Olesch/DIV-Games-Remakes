class_name Ghost
extends Node2D
## Short-lived afterimage (DIV: BoingLaserSpec, Bombkaboomspec): a graphic that stays for a few
## ticks. `points` allows several copies in one node (the laser leaves 6 per tick).

var graph := 104
var points := PackedVector2Array([Vector2.ZERO])
var scale_pct := 100.0
var ticks_left := 3
var rot := 0.0
var ghost_alpha := 1.0
var _tex: Texture2D


static func create(graph_code: int, pts: PackedVector2Array, scale_percent: float, rotation_rad: float,
		ticks: int, alpha: float) -> void:
	var g := Scenes.GHOST.instantiate() as Ghost
	g.graph = graph_code
	g.points = pts
	g.scale_pct = scale_percent
	g.rot = rotation_rad
	g.ticks_left = ticks
	g.ghost_alpha = alpha
	Game.add_entity(g)


func _ready() -> void:
	_tex = Gfx.tex(graph)
	modulate.a = ghost_alpha
	queue_redraw()


func _draw() -> void:
	# points are in world space; this node sits at the origin
	var off := -Gfx.cp0(graph)
	for p in points:
		draw_set_transform(p, rot, Vector2.ONE * scale_pct / 100.0)
		draw_texture(_tex, off)


func _physics_process(_delta: float) -> void:
	ticks_left -= 1
	if ticks_left <= 0:
		queue_free()
