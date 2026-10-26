class_name EnemyShot
extends Area2D
## DIV: Snakeshot / Endenemy1shot - enemy bullet, 2 sub-steps of 4.5 px per frame, kills the
## ship it touches. graph 103 = small enemies, 405 = boss.

var angle := 0
var graph := 103
var _spawn_tick := 0


static func fire(pos: Vector2, shot_angle: int, graph_code: int) -> void:
	var s := Scenes.ENEMY_SHOT.instantiate() as EnemyShot
	s.position = pos
	s.angle = shot_angle
	s.graph = graph_code
	Game.add_entity(s)


func _ready() -> void:
	_spawn_tick = Game.ticks
	Gfx.apply($Sprite, graph)
	rotation = Div.rot(angle)
	var c := CircleShape2D.new()
	c.radius = 3.0
	$Shape.shape = c
	_step()


func _physics_process(_delta: float) -> void:
	if Game.ticks == _spawn_tick:
		return
	_step()


func _step() -> void:
	for i in 2:
		position += Div.vec(angle, 4.5)
		var ships := Hit.ships_touching($Shape)
		if not ships.is_empty():
			Game.players[ships[0].index].killed = true
			queue_free()
			return
	if position.x > 800.0 or position.x < 0.0 or position.y > 600.0 or position.y < 0.0:
		queue_free()
