class_name MeteorSpawner
extends Node
## DIV: PROCESS Meteorenlos() - drops a meteor from the top edge, waits a random time that
## shrinks as the difficulty ramp grows, repeat.

const METEOR_SCENE := preload("res://scenes/meteor.tscn")

@onready var _timer: Timer = $Timer


func _ready() -> void:
	_timer.one_shot = true
	_timer.timeout.connect(_spawn)
	_spawn()


func _spawn() -> void:
	var meteor := METEOR_SCENE.instantiate() as Meteor
	meteor.setup(
		Vector2(randi_range(0, 1024), 0),
		randi_range(-3, 3),
		randi_range(3, 6 - (Game.difficulty - 3)),
		randi_range(-25000, 25000),
		randi_range(0, Game.super_meteors) as Defs.MeteorKind)
	get_parent().add_child.call_deferred(meteor)
	_timer.start(Game.meteor_interval_seconds())
