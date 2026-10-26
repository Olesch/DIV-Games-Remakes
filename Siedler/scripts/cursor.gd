class_name WorldCursor
extends Sprite2D
## DIV: cursor() - the arrow lives in world coordinates and the scroll camera follows it.
## The original re-centred the hardware mouse every frame to read relative motion; here the
## mouse is captured and InputEventMouseMotion.relative moves the arrow. Holding the left
## button applies the pending action every tick (set a collection point / lay out a building
## site), like the original's `IF(Mouse.left)` - so dragging paints several sites.

@export var colony: Colony

var _left_held := false


func _ready() -> void:
	texture = Gfx.texture(1)
	centered = false
	offset = -Gfx.cp0(1)
	z_index = 100  # DIV z=-100
	position = Vector2(320, 240)
	var camera := $Camera2D as Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(Game.WORLD_SIZE.x)
	camera.limit_bottom = int(Game.WORLD_SIZE.y)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		move_by((event as InputEventMouseMotion).relative)
	elif event.is_action(&"place"):
		if event.is_pressed() and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			# First click only grabs the mouse (browsers need a click for pointer lock).
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
			return
		_left_held = event.is_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"release_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_left_held = false


## DIV: x+=mouse.x-320 ... plus new_coordinates() clamping to the world graphic.
func move_by(relative: Vector2) -> void:
	position = (position + relative).clamp(Vector2.ZERO, Game.WORLD_SIZE)


func cell() -> Vector2i:
	return Vector2i(position / Game.CELL)


func set_held(held: bool) -> void:
	_left_held = held


func _physics_process(_delta: float) -> void:
	if _left_held:
		apply_click()


func apply_click() -> void:
	if Game.wood_point_pending:
		Game.wood_point = cell()
		Game.wood_point_pending = false
	if Game.clay_point_pending:
		Game.clay_point = cell()
		Game.clay_point_pending = false
	if Game.building and Game.house_size == Game.HOUSE_3X3:
		colony.try_place_house(cell())
