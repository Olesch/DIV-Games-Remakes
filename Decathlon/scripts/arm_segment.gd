class_name ArmSegment
extends Sprite2D
## One part of the jointed throwing arm. DIV: processes Arma (UPPER, graph 1) and Armb (LOWER,
## graph 2). The lower segment hangs on the upper one's joint (control point 1) and, when the
## player releases, hands the joint's per-tick movement to the main script as throw velocity.

signal released(velocity: Vector2i)

enum Kind { UPPER, LOWER }

const TEXTURES := {
	Kind.UPPER: preload("res://assets/fpg/decatlon/1.png"),
	Kind.LOWER: preload("res://assets/fpg/decatlon/2.png"),
}
## Control point 0 (pivot) and control point 1 (joint / hand) of each graphic.
const PIVOTS := {Kind.UPPER: Vector2(18, 24), Kind.LOWER: Vector2(23, 26)}
const JOINTS := {Kind.UPPER: Vector2(137, 20), Kind.LOWER: Vector2(144, 22)}
## Start angles in DIV thousandths of a degree (counter-clockwise).
const START_ANGLES := {Kind.UPPER: 220000, Kind.LOWER: 200000}

var kind: Kind = Kind.UPPER
## The segment this one hangs on (LOWER only, DIV: father).
var upper: ArmSegment
var ghosts_parent: Node

const GHOST_SCENE := preload("res://scenes/ghost.tscn")

## Position of control point 1 in screen pixels (DIV: Gelenkx/Gelenky), truncated like DIV.
var joint := Vector2i.ZERO

var _angle: int = 0
var _finished := false


func setup(arm_kind: Kind, pivot_position: Vector2, ghost_container: Node) -> void:
	kind = arm_kind
	position = pivot_position
	ghosts_parent = ghost_container


func _ready() -> void:
	texture = TEXTURES[kind]
	centered = false
	offset = -PIVOTS[kind]
	_angle = START_ANGLES[kind]
	_update_pose()



func _physics_process(_delta: float) -> void:
	if _finished:
		# Upper arm: the release happened last tick (DIV: IF(Kill==1) RETURN).
		queue_free()
		return
	if kind == Kind.UPPER:
		_step_upper()
	else:
		_step_lower()


func _step_upper() -> void:
	if Game.stage >= 1:
		_angle -= 3000 + Game.movement * 80
	if _angle < 0:
		Game.stage = 4  # arm swung all the way round: forced release
	_update_pose()
	_spawn_ghost()


func _step_lower() -> void:
	position = Vector2(upper.joint)
	if Game.stage >= 1:
		_angle -= 500
	if Game.stage >= 2:
		_angle -= 4500 + Game.movement * 120
	var old_joint := joint
	_update_pose()
	if Game.stage >= 3:
		released.emit(joint - old_joint)
		queue_free()
		return
	_spawn_ghost()


## LOWER segment: hang on the joint of `parent_arm`.
func attach(parent_arm: ArmSegment) -> void:
	upper = parent_arm
	position = Vector2(upper.joint)
	_update_pose()


## Called by the main script when the throw has left: the upper arm disappears next tick.
func finish() -> void:
	_finished = true


func _update_pose() -> void:
	rotation = -deg_to_rad(_angle / 1000.0)
	# DIV get_real_point(1): control point 1 after rotation, relative to control point 0.
	joint = Vector2i(position + (JOINTS[kind] - PIVOTS[kind]).rotated(rotation))


func _spawn_ghost() -> void:
	var ghost := GHOST_SCENE.instantiate() as Ghost
	ghost.setup(self)
	ghosts_parent.add_child(ghost)
