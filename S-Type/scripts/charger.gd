class_name Charger
extends Node2D
## Charging particle that flies into `target` and shrinks (DIV: Endenemy1laserspec for the boss,
## Boingloadspec for the boing gun). Starts `50*size/100` px away in direction `angle`.

var target: Node2D
var graph := 406
var angle := 0
var size_pct := 100.0
var moving := 0.0


static func spawn(target_node: Node2D, graph_code: int, size_percent: int) -> void:
	var c := Scenes.CHARGER.instantiate() as Charger
	c.target = target_node
	c.graph = graph_code
	c.size_pct = size_percent
	c.position = target_node.global_position
	c.angle = Div.rand(-180000, 180000) if graph_code == 105 else 180000 + Div.rand(-30000, 30000)
	c.position += Div.vec(c.angle, 0.5 * size_percent)
	Game.add_entity(c)


func _ready() -> void:
	Gfx.apply($Sprite, graph)
	modulate.a = 0.5  # DIV flags=4
	z_index = 0
	scale = Vector2.ONE * size_pct / 100.0


func _physics_process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		queue_free()
		return
	moving += 25.0
	size_pct -= 3.0
	var to_target := target.global_position - global_position
	if to_target.length() < 10.0:
		size_pct -= 9.0
	else:
		position += to_target.normalized() * (moving / 100.0)
	scale = Vector2.ONE * maxf(size_pct, 0.0) / 100.0
	if size_pct < 5.0:
		queue_free()
