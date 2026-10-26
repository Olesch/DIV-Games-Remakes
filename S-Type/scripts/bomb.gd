class_name Bomb
extends Enemy
## DIV: Bomb(x,y,xspeed,yspeed,time,expsize,life) - drifting mine with a countdown (graphs 212..218
## count down); it can be shot. When the timer runs out, or another explosion touches it, it
## detonates into a Blast of `exp_size` percent.

var xspeed := 100
var yspeed := 0
var time_left := 150        # DIV: time*25 frames
var exp_size := 550


static func spawn(x: int, y: int, xs: int, ys: int, seconds_units: int, expsize: int, hit_points: int) -> void:
	var b := Scenes.BOMB.instantiate() as Bomb
	b.position = Vector2(x, y) / 100.0
	b.xspeed = xs
	b.yspeed = ys
	b.time_left = seconds_units * 25
	b.exp_size = expsize
	b.life = hit_points
	Game.add_entity(b)


func _ready() -> void:
	add_to_group(&"bombs")
	Gfx.apply($Sprite, 210)
	Gfx.fit_shape($Shape, 210, 2.0)


func _physics_process(_delta: float) -> void:
	position.x -= xspeed / 100.0
	position.y += yspeed / 100.0
	Hit.kill_touching_ships($Shape)
	if life < 1:
		Explosion.spawn(position, 150, 1)
		queue_free()
		return
	time_left -= 1
	Gfx.apply($Sprite, 218 - time_left / 25)
	if time_left < 2 or Blast.touching(global_position, 14.0):
		Blast.detonate(position, exp_size)
		queue_free()
