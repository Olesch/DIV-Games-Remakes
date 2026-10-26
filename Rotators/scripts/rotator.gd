class_name Rotator
extends Node2D
## One spinning key (DIV processes Dreher1 / Dreher2 / Dreher3). The key rotates around its
## left knob (control point 0); the right knob (control point 1, the `Tip` marker) is where the
## next rotator of the chain is fastened and where a dot is left on the trail canvas every frame.
##
## The chain is built like the original: each rotator creates its successor as soon as it
## enters the tree (in `_ready`), and successors are children, so in every physics frame a
## rotator moves after the one it hangs on (tree order = DIV's falling `priority`).

enum Kind {
	FIRST,   ## DIV: Dreher1 - fixed in the screen centre
	MIDDLE,  ## DIV: Dreher2 - reads its tip BEFORE moving to the previous tip (one-frame lag)
	LAST,    ## DIV: Dreher3 - moves first, then reads its tip; always draws
}

const SCENE := preload("res://scenes/rotator.tscn")

var kind: Kind = Kind.FIRST
var index: int = 0             ## 0 = first rotator of the chain
var spin: int = 0              ## DIV: Rotsp, thousandths of a degree per frame
var leader: Rotator            ## DIV: father (the rotator this one hangs on)
var canvas: TrailCanvas
var tip := Vector2i.ZERO       ## DIV: pa_x, pa_y (integer screen position of control point 1)

var _angle: int = 0            ## DIV: angle, thousandths of a degree, counter-clockwise

@onready var _sprite: Sprite2D = $Sprite
@onready var _tip_marker: Marker2D = $Tip


func _ready() -> void:
	if kind != Kind.FIRST:
		top_level = true  # positioned on the screen, not relative to the leader
	scale = Vector2.ONE * Options.get_value(&"size") / 100.0  # DIV: size=Size_ins
	_sprite.visible = Options.get_value(&"show_rotators")
	if kind != Kind.LAST:
		_spawn_successor()
	# The DIV process runs its first frame right when it is created, after its successors.
	_step()


func _physics_process(_delta: float) -> void:
	_step()


func set_sprite_visible(on: bool) -> void:
	_sprite.visible = on
	for child in get_children():
		if child is Rotator:
			(child as Rotator).set_sprite_visible(on)


## One DIV frame of this rotator.
func _step() -> void:
	match kind:
		Kind.FIRST:
			tip = _read_tip()
		Kind.MIDDLE:
			tip = _read_tip()                 # still at last frame's position
			position = Vector2(leader.tip)
		Kind.LAST:
			position = Vector2(leader.tip)
			tip = _read_tip()
	if _draws_trail():
		canvas.plot(tip, index)
	_angle = (_angle + spin) % 360000
	rotation = -deg_to_rad(_angle / 1000.0)


## DIV: get_real_point(1, ...) - control point 1 after rotation and scaling, in whole pixels.
func _read_tip() -> Vector2i:
	return Vector2i(_tip_marker.global_position.round())


func _draws_trail() -> bool:
	match int(Options.get_value(&"trails")):
		Options.Trails.ALL:
			return true
		Options.Trails.LAST_ONLY:
			return kind == Kind.LAST  # DIV: Modeb=1, only Dreher3 ignores it
	return false


func _spawn_successor() -> void:
	var next := SCENE.instantiate() as Rotator
	next.index = index + 1
	next.kind = Kind.LAST if next.index >= Options.rotator_count() - 1 else Kind.MIDDLE
	next.spin = Options.rotator_speed(next.index)
	next.leader = self
	next.canvas = canvas
	add_child(next)
