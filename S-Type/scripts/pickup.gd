class_name Pickup
extends Area2D
## Money / extra life / shield / companion drifting left (DIV: Money, LivePlus, Shieldplus,
## Compainplus). Collected by touching a ship.

enum Kind { MONEY, LIFE, SHIELD, COMPANION }

const SPEED := 3.0  # DIV x-=300 (1/100 px) per frame

var kind: Kind = Kind.MONEY
var _wait := 0


static func spawn(k: Kind, pos: Vector2) -> void:
	var p := Scenes.PICKUP.instantiate() as Pickup
	p.kind = k
	p.position = pos
	Game.add_entity(p)


func _ready() -> void:
	z_index = 1  # DIV z=-1
	var code := 7
	match kind:
		Kind.LIFE: code = 8
		Kind.SHIELD: code = 10
		Kind.COMPANION: code = 31
	Gfx.apply($Sprite, code)
	Gfx.fit_shape($Shape, code, 3.0)


func _physics_process(_delta: float) -> void:
	position.x -= SPEED
	var ships := Hit.ships_touching($Shape)
	var collected := not ships.is_empty()
	if collected:
		var ship := ships[0]
		var ps := Game.players[ship.index]
		match kind:
			Kind.MONEY:
				ps.powers += 1
			Kind.LIFE:
				if Game.shared_lives == 0:
					ps.lives += 1
				else:
					Game.players[0].lives += 1
			Kind.SHIELD:
				ps.shield += 1
			Kind.COMPANION:
				if ps.compains < 4:
					ps.compains += 1
				else:
					collected = false  # full: the pod drifts on
		if collected:
			queue_free()
			return
	if position.x < -2.0:
		queue_free()
		return
	if kind == Kind.LIFE:
		# DIV: graph alternates every 7.5 px of travel
		var xi := int(position.x * 100.0)
		Gfx.apply($Sprite, 8 if posmod(xi, 1500) < 750 else 9)
	elif kind == Kind.SHIELD:
		_wait = (_wait + 1) % 20
		modulate.a = 0.5 if _wait > 10 else 1.0
