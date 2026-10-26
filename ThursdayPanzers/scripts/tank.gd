class_name Tank
extends Area2D
## DIV: PROCESS Panzer(x,y,life,power,velo,player,team). One logic step per physics tick (24 Hz),
## exactly like one DIV frame; speeds are kept in DIV units (move = 1/100 px per frame,
## angle = thousandths of a degree, counter-clockwise).

const SHOT_SCENE := preload("res://scenes/shot.tscn")
const MIN_POS := Vector2(30, 30)      # DIV: x<3000 / y<3000 (1/100 px)
const MAX_POS := Vector2(1570, 1170)  # DIV: x>157000 / y>117000
const PUSH_DISTANCE := 30.0           # DIV: get_dist<3000 -> tanks overlap
const PUSH_STEP := 5.0                # DIV: get_distx(.., 500)
const RELOAD_TICKS := 24              # DIV: shotwait=24
const AIM_TOLERANCE := 20000          # DIV: +-20 degrees
const AI_KEEP_DISTANCE := 150.0       # DIV: get_dist(nearest)>15000

var life: int = 100
var power: int = 5
var velo: int = 30
var player: int = 0      # 0 = computer, 1 / 2 = human player
var team: int = 1
var angle: int = 0
var move: int = 0
var backstab: int = 0    # DIV: Backstab - while >= 0 the AI tank reverses after a hit from behind
var shotwait: int = 0

@onready var _sprite: Sprite2D = $Sprite2D


func setup(pos: Vector2, start_life: int, shot_power: int, speed: int, human: int, tank_team: int) -> void:
	position = pos
	life = start_life
	power = shot_power
	velo = speed
	player = human
	team = tank_team


func _ready() -> void:
	add_to_group(&"tanks")
	_sprite.texture = load("res://assets/fpg/thurpanz/%d.png" % (99 + team))  # 100 = team 1, 101 = team 2
	Game.team_count[team] += 1
	if player > 0:
		Game.player_tank[player] = self
		Game.player_life[player] = life
	reset_physics_interpolation()


func _physics_process(_delta: float) -> void:
	if player > 0:
		_player_control()
	else:
		_ai_control()
	shotwait -= 1

	position += Vector2.from_angle(-deg_to_rad(angle / 1000.0)) * (move / 100.0)  # DIV: advance(Move)
	move = _near_angle(move, 0, velo / 2)
	for other: Tank in get_tree().get_nodes_in_group(&"tanks"):  # DIV: "Collision"
		_resolve_overlap(other)

	position = position.clamp(MIN_POS, MAX_POS)
	if angle > 180000:
		angle -= 360000
	if angle < -180000:
		angle += 360000
	rotation = -deg_to_rad(angle / 1000.0)
	if player > 0:
		Game.player_life[player] = life
	if life < 0:
		_die()


func _player_control() -> void:
	var prefix := "p%d_" % player
	if Input.is_action_pressed(prefix + "left"):
		angle += velo * 50 + move * 2
	if Input.is_action_pressed(prefix + "right"):
		angle -= velo * 50 + move * 2
	if Input.is_action_pressed(prefix + "up") and move < velo * 20:
		move += velo
	if Input.is_action_pressed(prefix + "down") and move > -velo * 5:
		move -= velo * 2
	if Input.is_action_pressed(prefix + "fire") and shotwait < 0:
		_fire()


func _ai_control() -> void:
	var nearest: Tank = null
	for other: Tank in get_tree().get_nodes_in_group(&"tanks"):
		_resolve_overlap(other)
		if other.team != team:
			if nearest == null or position.distance_to(other.position) < position.distance_to(nearest.position):
				nearest = other
	var distance := 0.0 if nearest == null else position.distance_to(nearest.position)
	if backstab < 0:
		if distance > AI_KEEP_DISTANCE and move < velo * 20:
			move += velo
	elif move > -velo * 5:
		move -= velo * 2
	backstab -= 1
	if nearest == null:
		return
	var target_angle := _angle_to(nearest.position)
	angle = _near_angle(angle, target_angle, velo * 50 + move * 2)
	if shotwait < 0 and angle + AIM_TOLERANCE > target_angle and angle - AIM_TOLERANCE < target_angle:
		_fire()


func _fire() -> void:
	var shot := SHOT_SCENE.instantiate() as Shot
	shot.shooter = self
	shot.team = team
	shot.power = power
	shot.angle = angle
	shot.shooter_move = move
	shot.position = position
	get_parent().add_child(shot)
	shotwait = RELOAD_TICKS


## Push two overlapping tanks apart (5 px each) and slow this one down.
func _resolve_overlap(other: Tank) -> void:
	if other == self:
		return  # DIV's get_id(TYPE Panzer) never returns the calling tank itself
	if position.distance_to(other.position) >= PUSH_DISTANCE:
		return
	var dir := Vector2.RIGHT
	if other.position != position:
		dir = (other.position - position).normalized()
	position -= dir * PUSH_STEP
	other.position += dir * PUSH_STEP
	@warning_ignore("integer_division")
	move = (move * 2) / 3


func _die() -> void:
	Explosion.spawn(get_parent(), position, 100)
	Game.tank_died(team)
	if player > 0:
		# hand the player's camera and controls to the first living computer tank of the team
		for other: Tank in get_tree().get_nodes_in_group(&"tanks"):
			if other != self and other.team == team and other.player == 0:
				other.player = player
				Game.player_tank[player] = other
				break
		if Game.player_tank[player] == self:
			Game.player_tank[player] = null
	remove_from_group(&"tanks")
	queue_free()


## DIV get_angle: thousandths of a degree, counter-clockwise, -180000..180000.
func _angle_to(point: Vector2) -> int:
	return int(-rad_to_deg((point - position).angle()) * 1000.0)


## DIV near_angle(): turn `current` towards `target` by at most `step` the short way round.
static func _near_angle(current: int, target: int, step: int) -> int:
	var diff := posmod(target - current + 180000, 360000) - 180000
	if absi(diff) <= step:
		return target
	return current + step * signi(diff)
