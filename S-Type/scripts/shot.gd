class_name Shot
extends Area2D
## Straight player bullets (DIV: Normalshot, Redshot, Gatlingshot, Rearshot). Each tick the bullet
## moves in `substeps` small steps and tests for a hit after each one, exactly like the original.

enum Kind { NORMAL, RED, GATLING, REAR, FLAK }

var kind: Kind = Kind.NORMAL
var angle := 0                # DIV angle
var strength := 10
var graph := 100
var substeps := 2
var step_len := 7.5           # px per sub-step (DIV advance(750) in 1/100 px)
var explode_size := 10
var size_pct := 100
var _spawn_tick := 0


static func create(k: Kind, pos: Vector2, shot_angle: int) -> Shot:
	var s := Scenes.SHOT.instantiate() as Shot
	s.kind = k
	s.position = pos
	s.angle = shot_angle
	Game.add_entity(s)
	return s


func _ready() -> void:
	_spawn_tick = Game.ticks
	_setup()
	Gfx.apply($Sprite, graph)
	scale = Vector2.ONE * size_pct / 100.0
	rotation = Div.rot(angle)
	var c := CircleShape2D.new()
	c.radius = 1.5 if kind == Kind.GATLING else 3.0
	$Shape.shape = c
	_step()  # DIV: a new process runs immediately, up to its first FRAME


func _setup() -> void:
	match kind:
		Kind.NORMAL:   # Normalshot
			graph = 100
		Kind.RED:      # Redshot
			graph = 101
		Kind.GATLING:  # Gatlingshot
			graph = 102
			substeps = 3
			step_len = 6.0
			strength = 5
			explode_size = 5
		Kind.REAR:     # Rearshot art 0
			graph = 103
			strength = 3 + Game.passive_loss * 2
		Kind.FLAK:     # Rearshot art 1
			graph = 103
			strength = 9 + Game.passive_loss * 6
			size_pct = 130


func _physics_process(_delta: float) -> void:
	if Game.ticks == _spawn_tick:
		return
	_step()


func _step() -> void:
	for i in substeps:
		position += Div.vec(angle, step_len)
		var hit := Hit.first_enemy($Shape)
		if hit != null:
			_on_hit(hit)
			return
	if _outside():
		queue_free()


func _on_hit(hit: Enemy) -> void:
	Explosion.spawn(position, explode_size, 0)
	hit.take_damage(strength)
	queue_free()


func _outside() -> bool:
	return position.x > 800.0 or position.x < 0.0 or position.y > 600.0 or position.y < 0.0
