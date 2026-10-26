class_name Explosion
extends Node2D
## DIV: Explode(x,y,size,times) - 10-frame animation (graphs 300..309, one frame each),
## scaled to `size` percent. At graph 305 it spawns a smaller one nearby (times-1).

var size_pct := 100
var times := 0
var graph := 300


static func spawn(pos: Vector2, size_percent: int, repeats: int) -> void:
	var e := Scenes.EXPLOSION.instantiate() as Explosion
	e.position = pos
	e.size_pct = size_percent
	e.times = repeats
	Game.add_entity(e)


func _ready() -> void:
	z_index = 10  # DIV z=-10
	scale = Vector2.ONE * maxf(size_pct, 0) / 100.0
	Gfx.apply($Sprite, graph)


func _physics_process(_delta: float) -> void:
	if graph == 305 and times > 0:
		var r := size_pct * 0.7  # DIV rand(-size*70, size*70) in 1/100 px
		var off := Vector2(randf_range(-r, r), randf_range(-r, r))
		Explosion.spawn(position + off, size_pct - 5, times - 1)
	if graph == 309:
		queue_free()
		return
	graph += 1
	Gfx.apply($Sprite, graph)
