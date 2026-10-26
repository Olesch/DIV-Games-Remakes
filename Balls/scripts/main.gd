extends Node2D
## Balls: balls fly in from the edges towards the centre and stick to whatever they touch,
## growing a diffusion-limited-aggregation-like tree. The original has no input at all;
## R (added for the port) clears the picture and starts again.

@onready var cluster: Cluster = $Cluster
@onready var balls: Node2D = $Balls
@onready var spawner: Spawner = $Spawner


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		var test := preload("res://scripts/debug/autotest.gd").new() as Node
		test.name = "AutoTest"
		add_child(test)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart"):
		restart()
		get_viewport().set_input_as_handled()


func restart() -> void:
	for ball in balls.get_children():
		ball.queue_free()
	cluster.reset()
	spawner.reset()
