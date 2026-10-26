class_name Ball
extends Node2D
## The big ball (DIV: Ball + Walls). It is pulled towards the guide ball like on a rubber band, bounces off
## wall pixels, is attracted by holes, repelled by hills, and the level ends when it touches a death or
## win pixel. Everything runs once per physics tick (40/s = the original's set_fps(40)); positions and
## velocities are integers in 1/100 pixel exactly as in the original (resolution=100).

signal finished(won: bool)
signal recalled  # R was used: the world adds the time penalty

const MAX_SPEED := 99
const RECALL_COOLDOWN := -100   # DIV: NoEr=-100 after pressing R

var level: LevelMap
var guide: GuideBall
var pos := Vector2i.ZERO   # DIV: x, y
var vel := Vector2i.ZERO   # DIV: Ball_x / Ball_y
var recall_cooldown := 0   # DIV: NoEr
var friction_count := 0    # DIV: Reibcount
var is_finished := false
var _recall_requested := false


func setup(start: Vector2i, level_map: LevelMap, guide_ball: GuideBall) -> void:
	pos = start * 100
	position = Vector2(start)
	level = level_map
	guide = guide_ball
	reset_physics_interpolation()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"recall_ball", false, true):
		_recall_requested = true


func _physics_process(_delta: float) -> void:
	if is_finished:
		return
	# R: put the guide ball onto the big ball again (costs 24 frames, then a cooldown)
	if (_recall_requested or Input.is_action_pressed(&"recall_ball")) and recall_cooldown > 0:
		guide.teleport_to(pos)
		recall_cooldown = RECALL_COOLDOWN
		recalled.emit()
	_recall_requested = false
	recall_cooldown += 1

	vel += (guide.pos - pos) / level.gravity
	vel = vel.clampi(-MAX_SPEED, MAX_SPEED)

	for i in level.speedmul:
		pos += vel
		_touch_terrain(pos.x / 100, pos.y / 100)

	if level.friction != 0:
		friction_count += 1
		if friction_count >= level.friction:
			vel -= vel.sign()  # every non-zero component moves one step towards 0
			friction_count = 0
	position = Vector2(pos) / 100.0


## DIV: process Walls(x,y). Samples the terrain around the ball (px,py = pixel position at the time
## of the call; bounce corrections move the ball but the remaining samples still use px,py).
func _touch_terrain(px: int, py: int) -> void:
	var centre := level.get_index(px, py)
	if centre == LevelMap.DEATH:
		_finish(false)
	if centre == LevelMap.WIN:
		_finish(true)

	# walls: bounce when moving into them
	if level.get_index(px + 4, py) == LevelMap.WALL and vel.x > 0:
		vel.x = -vel.x
		pos.x += vel.x
	if level.get_index(px - 4, py) == LevelMap.WALL and vel.x < 0:
		vel.x = -vel.x
		pos.x += vel.x
	if level.get_index(px, py + 4) == LevelMap.WALL and vel.y > 0:
		vel.y = -vel.y
		pos.y += vel.y
	if level.get_index(px, py - 4) == LevelMap.WALL and vel.y < 0:
		vel.y = -vel.y
		pos.y += vel.y

	# holes pull the ball in (yellow)
	if level.get_index(px + 8, py) == LevelMap.HOLE:
		vel.x += level.yellow_strength
	if level.get_index(px - 8, py) == LevelMap.HOLE:
		vel.x -= level.yellow_strength
	if level.get_index(px, py + 8) == LevelMap.HOLE:
		vel.y += level.yellow_strength
	if level.get_index(px, py - 8) == LevelMap.HOLE:
		vel.y -= level.yellow_strength

	# hills push the ball away (purple)
	if level.get_index(px + 8, py) == LevelMap.HILL:
		vel.x -= level.purple_strength
	if level.get_index(px - 8, py) == LevelMap.HILL:
		vel.x += level.purple_strength
	if level.get_index(px, py + 8) == LevelMap.HILL:
		vel.y -= level.purple_strength
	if level.get_index(px, py - 8) == LevelMap.HILL:
		vel.y += level.purple_strength

	vel = vel.clampi(-MAX_SPEED, MAX_SPEED)


func _finish(won: bool) -> void:
	if is_finished:
		return
	is_finished = true
	finished.emit(won)
