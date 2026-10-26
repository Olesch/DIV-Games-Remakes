class_name Bunny
extends Node2D
## One bunny (DIV process Bunny). The original runs integer logic once per frame at 24 fps, with
## step-by-step movement and pixel-colour tests, so the project's physics tick is 24 Hz and
## _physics_process is exactly one DIV frame.

const FALLEN_OUT_MARGIN := 64  # px below the map: the whole graphic is off screen

@export var action_prefix: String = "p1"  # p1 = arrows, p2 = WASD, "" = no keys (extra bunnies)
@export var start: Vector2i = Vector2i.ZERO

var x: int = 0
var y: int = 0
var x_speed: int = 0
var y_speed: int = 0
var standing: bool = false  # DIV: Standing
## Set by the other bunny when it bumped into us sideways (DIV: Kontakt); reverses our x speed.
var contact: bool = false


func _ready() -> void:
	add_to_group(&"bunnies")
	x = start.x
	y = start.y
	position = Vector2(x, y)


func _physics_process(_delta: float) -> void:
	_move_vertically()
	_move_horizontally()
	y_speed += 1  # gravity
	_handle_input()
	if contact:
		x_speed = -x_speed
	contact = false
	position = Vector2(x, y)
	if y > Game.terrain.height + FALLEN_OUT_MARGIN and y_speed > 0:
		# Fell out below the map (only random extra bunnies can, e.g. spawned inside a bottom block):
		# outside the map nothing stops it, so in DIV it would fall unseen forever. Remove it.
		queue_free()


@warning_ignore("integer_division")
func _move_vertically() -> void:
	standing = false
	var counter := 0
	while true:
		y += signi(y_speed)
		counter += 1
		if Game.terrain_at(x, y) == Game.TERRAIN_PLATFORM and y_speed > -4:
			# land (rising fast = jumping up through the platform from below)
			y -= 1
			y_speed = 0
			standing = true
		if Game.terrain_at(x, y) == Game.TERRAIN_CEILING:
			y += 1
			y_speed = -y_speed
		# The original also had a get_dist(TYPE Bunny) loop here; it never yields a bunny id,
		# so it did nothing (see PORTING_NOTES.md) and is not ported.
		if counter > absi(y_speed / 2):
			break


func _move_horizontally() -> void:
	var counter := 0
	while true:
		x += signi(x_speed)
		counter += 1
		if Game.terrain_at(x, y) == Game.TERRAIN_WALL_LEFT:
			x -= 1
			x_speed = -x_speed
		if Game.terrain_at(x, y) == Game.TERRAIN_WALL_RIGHT:
			x += 1
			x_speed = -x_speed
		var other := _overlapping_bunny()
		if other and absi(x - other.x) > absi(y - other.y):
			# sideways crash (SEITLICHER CRASH): we turn now, the other at the end of its frame
			x_speed = -x_speed
			other.contact = true
		if counter > absi(x_speed) or counter > 4:
			break


func _overlapping_bunny() -> Bunny:
	for node in get_tree().get_nodes_in_group(&"bunnies"):
		var other := node as Bunny
		if other != self and Game.bunnies_overlap(Vector2i(x, y), Vector2i(other.x, other.y)):
			return other
	return null


func _handle_input() -> void:
	var left := _key(&"_left")
	var right := _key(&"_right")
	if _key(&"_up") and standing:
		y_speed = -25  # jump
	if left and x_speed > -6 and standing:
		x_speed -= 1
	if right and x_speed < 6 and standing:
		x_speed += 1
	if not right and not left and standing:
		x_speed -= signi(x_speed)  # friction on the ground


## DIV key(): an extra bunny was called without keys, so none of them is ever pressed.
func _key(suffix: StringName) -> bool:
	return action_prefix != "" and Input.is_action_pressed(action_prefix + suffix)
