class_name Blast
extends Node2D
## DIV: BombKaboom(x,y,expsize) - expanding red ring (graph 219, 20% per frame, 50% transparent)
## that kills ships, hurts enemies (1 life per frame) and sets off other bombs. The graphic is a
## thin ring, so only the ring band counts (radius 47..55 px at 100%).

const RING_OUTER := 55.0
const RING_INNER := 47.0

var exp_size := 550
var size_pct := 1.0


static func detonate(pos: Vector2, expsize: int) -> void:
	var b := Scenes.BLAST.instantiate() as Blast
	b.position = pos
	b.exp_size = expsize
	Game.add_entity(b)


## True if a disc (centre, radius) touches the ring band of any blast.
static func touching(centre: Vector2, radius: float) -> bool:
	for n in Game.get_tree().get_nodes_in_group(&"blasts"):
		var b := n as Blast
		if b == null:
			continue
		var d := centre.distance_to(b.position)
		var outer := RING_OUTER * b.size_pct / 100.0
		var inner := RING_INNER * b.size_pct / 100.0
		if d - radius <= outer and d + radius >= inner:
			return true
	return false


func _ready() -> void:
	add_to_group(&"blasts")
	Gfx.apply($Sprite, 219)
	modulate.a = 0.5
	_apply()


func _apply() -> void:
	scale = Vector2.ONE * size_pct / 100.0


func _physics_process(_delta: float) -> void:
	size_pct += 20.0
	_apply()
	for s in Game.players:
		if s.ship != null and is_instance_valid(s.ship):
			var d := position.distance_to(s.ship.position)
			var outer := RING_OUTER * size_pct / 100.0
			var inner := RING_INNER * size_pct / 100.0
			if d - 12.0 <= outer and d + 12.0 >= inner:
				s.killed = true
	if size_pct > exp_size:
		queue_free()
		return
	# DIV: Bombkaboomspec - a fading copy that stays 2 frames
	Ghost.create(219, PackedVector2Array([position]), size_pct, 0.0, 2, 0.5)
