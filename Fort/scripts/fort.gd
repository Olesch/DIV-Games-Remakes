class_name Fort
extends Area2D
## The fort in the middle of the screen (DIV: Festung). Counts damage when an enemy touches it
## (the enemy is destroyed) and fires a shot towards the mouse on click.

const SHOT_SCENE := preload("res://scenes/shot.tscn")


func _ready() -> void:
	position = Game.FORT_POS
	# The fort graphic is an ellipse of 100 x 80 px
	var points := PackedVector2Array()
	for i in 24:
		var a := TAU * i / 24.0
		points.append(Vector2(cos(a) * 50.0, sin(a) * 40.0))
	var shape := ConvexPolygonShape2D.new()
	shape.points = points
	($CollisionShape2D as CollisionShape2D).shape = shape


func _physics_process(_delta: float) -> void:
	for area in get_overlapping_areas():
		if area is Enemy:
			Game.add_damage()
			area.queue_free()  # DIV: signal(hit, s_kill)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"fire"):
		fire_at(get_global_mouse_position())


## DIV: Schuss(get_angle(FESTUNG_ID)+pi) from the cursor - i.e. from the fort towards `target`.
func fire_at(target: Vector2) -> void:
	var shot: Shot = SHOT_SCENE.instantiate()
	shot.position = position
	shot.direction = (target - position).normalized() if target != position else Vector2.RIGHT
	get_parent().add_child(shot)
