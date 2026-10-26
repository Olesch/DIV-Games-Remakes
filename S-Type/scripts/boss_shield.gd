class_name BossShield
extends Enemy
## DIV: Endenemy1shield - rotating ring (four arcs with gaps) around the boss that soaks up shots.
## At 0 life it flares up, disappears and regenerates (+5 life/frame) until above 500, then
## returns. Its size pulses between 95% and 120%.

enum State { NORMAL, BREAKING, DOWN, RETURNING }

var state := State.NORMAL
var angle := 0
var size_pct := 100.0
var growing := true     # DIV: sizing==0


func _ready() -> void:
	life = 1000
	collision_layer = Hit.LAYER_SHIELD
	Gfx.apply($Sprite, 402)
	_apply()


func _apply() -> void:
	rotation = Div.rot(angle)
	scale = Vector2.ONE * size_pct / 100.0


func _set_active(on: bool) -> void:
	visible = on
	for c in get_children():
		if c is CollisionPolygon2D:
			(c as CollisionPolygon2D).set_deferred(&"disabled", not on)


func _physics_process(_delta: float) -> void:
	match state:
		State.NORMAL:
			angle += 2500
			if life < 1:
				state = State.BREAKING
				modulate.a = 0.5
			if growing:
				size_pct += 1.0
			else:
				size_pct -= 1.0
			if size_pct > 120.0:
				growing = false
			if size_pct < 95.0:
				growing = true
		State.BREAKING:
			angle += 5000
			size_pct += 10.0
			if size_pct > 200.0:
				state = State.DOWN
				_set_active(false)
		State.DOWN:
			angle += 2500
			if life > 500:
				state = State.RETURNING
				size_pct = 200.0
				_set_active(true)
			else:
				life += 5
		State.RETURNING:
			angle += 5000
			size_pct -= 10.0
			if size_pct < 95.0:
				state = State.NORMAL
				modulate.a = 1.0
	_apply()
