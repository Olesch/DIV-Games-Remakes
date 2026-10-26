class_name Bat
extends Area2D
## A player's bat (DIV process Bat(Player, Ki)). Moves 4*Activity px per tick while its keys are held,
## or, as a computer bat (Ki=2), towards a ball. Logic runs once per physics tick (24/s = set_fps).

const Y_MIN := 40               # DIV: only moves while y>40 / y<440
const Y_MAX := 440

@export_range(1, 2) var player: int = 1
## DIV Ki=2. The original has this code but creates both bats with Ki=1 (option, owner's request).
@export var computer := false


func _ready() -> void:
	# DIV: player 1 at x=4, player 2 at x=636, both y=240
	position = Vector2(4 if player == 1 else 636, 240)


func _physics_process(_delta: float) -> void:
	if computer:
		_follow_ball()
		return
	var prefix := "p%d_" % player
	if Input.is_action_pressed(prefix + "up") and position.y > Y_MIN:
		position.y -= Game.step()
	if Input.is_action_pressed(prefix + "down") and position.y < Y_MAX:
		position.y += Game.step()


## DIV `IF(ki==2)` block. It watched the two balls Balla and Ballb (from the commented-out two-ball start):
## of those flying towards this bat (xinc>0 for the right bat, <0 for the left), it followed the one nearer
## to the bat in x. Here the same choice is made among all balls.
func _follow_ball() -> void:
	var toward := 1 if player == 2 else -1
	var target: Ball = null
	for ball: Ball in get_tree().get_nodes_in_group(&"balls"):
		if signi(ball.velocity.x) != toward:
			continue
		if target == null or (ball.position.x - target.position.x) * toward > 0:
			target = ball
	if target == null:
		return
	# Two separate tests like the original: the second sees the y the first may have changed, so a bat
	# less than one step away from the ball steps away and back and stays put.
	if position.y > target.position.y and position.y > Y_MIN:
		position.y -= Game.step()
	if position.y < target.position.y and position.y < Y_MAX:
		position.y += Game.step()
