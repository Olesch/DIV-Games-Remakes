extends Node2D
## The DIV main code: builds the world from the start maps (Draw_all), then the colony runs
## on its own. Children: Colony (simulation), Terrain/Trees/Settlers (views), HouseGhost,
## Cursor (+ scroll camera), Hud (minimap, menu bar).

@onready var colony: Colony = $Colony
@onready var terrain: TerrainLayer = $Terrain
@onready var trees: TreeLayer = $Trees


func _ready() -> void:
	colony.load_start_maps()
	terrain.build(colony.terrain)
	colony.place_start_objects()
	trees.queue_redraw()
	var autotest := "--autotest" in OS.get_cmdline_user_args()
	# Browsers only allow pointer lock after a click; the cursor grabs the mouse on the first one.
	if OS.has_feature("web") or autotest or DisplayServer.get_name() == "headless":
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if autotest:
		add_child(AutoTest.new())


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
