class_name BossLaser
extends Node2D
## DIV: Endenemy1laser(x,y,angle) - 800 px beam attached to the boss: 16 frames of warm-up
## (50% transparent, harmless), 80 frames of killing beam drifting 0.1 degree per frame,
## 16 frames of fade-out.

var angle := 0
var dir := 0
var phase := 0          # 0 warm-up, 1 active, 2 cool-down
var counter := 0


func _ready() -> void:
	dir = Div.rand(0, 1)
	Gfx.apply($Sprite, 403)
	var r := RectangleShape2D.new()
	r.size = Vector2(798, 11)
	$Shape.shape = r
	$Shape.position = Vector2(-400, 0)
	modulate.a = 0.5
	rotation = Div.rot(angle)


func _physics_process(_delta: float) -> void:
	match phase:
		0:
			counter += 1
			if counter > 15:
				phase = 1
				counter = 0
				modulate.a = 1.0
		1:
			angle += dir * 200 - 100
			rotation = Div.rot(angle)
			Hit.kill_touching_ships($Shape)
			counter += 1
			if counter >= 80:
				phase = 2
				counter = 0
				modulate.a = 0.5
		2:
			counter += 1
			if counter > 15:
				queue_free()
