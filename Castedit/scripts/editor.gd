class_name Editor
extends Node2D
## The room editor. DIV: PROCESS Painter (cursor + all keys), Chooser (graph 851/852) and Back (graph 853)
## of CASTEDIT.PRG.
##
## Timing: the original handles held keys once per frame at set_fps(24). The editor logic runs in
## _physics_process with physics_ticks_per_second = 24, one tick = one DIV frame: a held arrow moves the
## cursor one cell per tick, a held Enter/Del paints every 2nd tick (the original waits one extra FRAME
## after every redraw), and picking from a chooser pauses 3 extra ticks (DIV: FRAME(300)).
## New: a key acts at once when pressed and only starts repeating after REPEAT_DELAY_TICKS
## (the original repeats from the first frame, so a short tap often moved 2-3 cells).

const REPEAT_DELAY_TICKS := 6   # 0 = exactly like the original
const CURSOR_GRAPH := 860       # "Editorzeiger"
const FLOOR_CHOOSER_GRAPH := 851
const OBJECT_CHOOSER_GRAPH := 852
const CHOOSER_BACK_GRAPH := 853
const REPEATING := [&"pick_floor", &"pick_object", &"cursor_right", &"cursor_left", &"cursor_up",
	&"cursor_down", &"room_up", &"room_down", &"room_left", &"room_right", &"place", &"erase"]

var layer: int = Game.Layer.FLOOR   # DIV: Stat 0/1 = editing floor/objects ...
var picking := false                # ... Stat 2/3 = a chooser is open (then `layer` says which one)
var brush := 0                      # DIV: Object (Painter's private), shared by both layers
var _brush_layer: int = Game.Layer.FLOOR   # chooser the brush came from (for the help text only)
var cursor := Vector2i.ZERO         # cell under the cursor; DIV x = cell*20+10
var _cursor_before_pick := Vector2i.ZERO   # DIV: oldx, oldy
var _wait_ticks := 0
var saving_prompt := false         # new: "Save to slot 3 or 4?" is waiting for a key
var _held: Dictionary = {}          # action -> ticks held
var _tapped: Dictionary = {}        # action -> pressed since the last handled tick

@onready var room_view: RoomView = $RoomView
@onready var _cursor_sprite: Sprite2D = $Cursor
@onready var _chooser: Sprite2D = $Chooser
@onready var _chooser_back: Sprite2D = $ChooserBack
@onready var hud: Hud = $Hud
@onready var files: LevelFiles = $LevelFiles


func _ready() -> void:
	Gfx.apply(_cursor_sprite, CURSOR_GRAPH)
	Gfx.apply(_chooser_back, CHOOSER_BACK_GRAPH)
	_chooser.position = Vector2(400, 300)
	_chooser_back.position = Vector2(400, 300)
	files.imported.connect(_on_file_imported)
	files.exported.connect(func(message: String) -> void: hud.toast(message, 4.0))
	room_view.redraw()
	_update_view()
	hud.toast("%s, room %d.  H = help" % [open_set_label(), Game.room], 4.0)


func _unhandled_input(event: InputEvent) -> void:
	if saving_prompt:
		_answer_save_prompt(event)
	elif event.is_action_pressed(&"save"):
		save_set()
	elif event.is_action_pressed(&"export"):
		hud.toast(files.export_file(Game.map.to_byte_array(), Game.EXPORT_NAME % Game.level_set), 4.0)
	elif event.is_action_pressed(&"import"):
		hud.toast(files.import_file(), 4.0)
	elif event.is_action_pressed(&"help"):
		hud.toggle_help()
	elif event.is_action_pressed(&"back"):
		Game.to_title()
	else:
		for action: StringName in REPEATING:
			if event.is_action_pressed(action):
				_tapped[action] = true


func _physics_process(_delta: float) -> void:
	if saving_prompt:
		return
	for action: StringName in REPEATING:
		_held[action] = int(_held.get(action, 0)) + 1 if Input.is_action_pressed(action) else 0
	if _wait_ticks > 0:
		_wait_ticks -= 1
		return
	_wait_ticks = _editor_tick()
	_tapped.clear()
	_update_view()


func _fires(action: StringName) -> bool:
	return _tapped.has(action) or int(_held.get(action, 0)) > REPEAT_DELAY_TICKS


## One pass of the Painter loop; returns the extra ticks the original spends in FRAMEs inside the loop.
func _editor_tick() -> int:
	var extra := 0
	if _fires(&"pick_floor"):
		open_chooser(Game.Layer.FLOOR)
	if _fires(&"pick_object"):
		open_chooser(Game.Layer.OBJECTS)
	if _fires(&"cursor_right"):
		move_cursor(Vector2i.RIGHT)
	if _fires(&"cursor_left"):
		move_cursor(Vector2i.LEFT)
	if _fires(&"cursor_up"):
		move_cursor(Vector2i.UP)
	if _fires(&"cursor_down"):
		move_cursor(Vector2i.DOWN)
	if _fires(&"room_up") and change_room(-Game.GRID_W):
		extra += 1
	if _fires(&"room_down") and change_room(Game.GRID_W):
		extra += 1
	if _fires(&"room_left") and change_room(-1):
		extra += 1
	if _fires(&"room_right") and change_room(1):
		extra += 1
	if _fires(&"place"):
		if picking:
			pick_at_cursor()
			extra += 3   # DIV: FRAME(300)
		else:
			place_at_cursor()
			extra += 1
	if _fires(&"erase"):
		erase_at_cursor()
		extra += 1
	return extra


# ----------------------------------------------------------------- editor actions

## DIV: key(_z) / key(_x). Opening a chooser from the room remembers the cursor and moves it to the
## top-left cell; switching between the two choosers keeps it where it is.
func open_chooser(which: int) -> void:
	if not picking:
		_cursor_before_pick = cursor
		cursor = Vector2i.ZERO
	picking = true
	layer = which


## DIV: cursor keys, 20 px per frame, kept inside the 40x30 cells (also inside the choosers).
func move_cursor(dir: Vector2i) -> void:
	cursor = (cursor + dir).clamp(Vector2i.ZERO, Vector2i(Game.COLS - 1, Game.ROWS - 1))


## DIV: i/k/j/l move through the 6x6 room grid without wrapping. Works with a chooser open, too.
## Original limits kept: `k` only works while Stage<29, so room 29 cannot step down to room 35
## (reach it from room 34 with `l`).
func change_room(step: int) -> bool:
	var r := Game.room
	var allowed := false
	match step:
		-6:
			allowed = r > 5          # DIV: key(_i) AND Stage>5
		6:
			allowed = r < 29         # DIV: key(_k) AND Stage<29
		-1:
			allowed = r % Game.GRID_W > 0
		1:
			allowed = r % Game.GRID_W < Game.GRID_W - 1
	if not allowed:
		return false
	Game.room = r + step
	room_view.redraw()
	hud.toast("Room %d" % Game.room, 1.0)
	return true


## DIV: Enter in a chooser - get_Object() under the cursor becomes the brush, the chooser closes and
## the cursor goes back. An empty slot gives a value that is painted but never drawn (see Tiles.EMPTY_PICK).
func pick_at_cursor() -> void:
	brush = Tiles.pick(layer == Game.Layer.FLOOR, cursor.x, cursor.y)
	_brush_layer = layer
	picking = false
	cursor = _cursor_before_pick


## DIV: Enter in the room - writes the brush into the current layer and redraws the room.
func place_at_cursor() -> void:
	Game.set_cell(layer, cursor.x, cursor.y, brush)
	room_view.redraw()


## DIV: Del - floor cell back to plain floor (6), object cell emptied (0). With a chooser open the
## original still sent the erase pulse but skipped the redraw, so all object markers vanish until
## the next redraw; kept.
func erase_at_cursor() -> void:
	if picking:
		room_view.clear_markers()
		return
	Game.set_cell(layer, cursor.x, cursor.y, 6 if layer == Game.Layer.FLOOR else 0)
	room_view.redraw()


## DIV: Control+S wrote saves/LevelN.dat. Here the originals (sets 1, 2) stay read-only: an open user
## slot is saved straight back, otherwise Ctrl+S asks for slot 3 or 4.
func save_set() -> void:
	if Game.is_user_slot(Game.level_set):
		_save_to(Game.level_set)
		return
	saving_prompt = true
	var choices := PackedStringArray()
	for n: int in Game.USER_SLOTS:
		choices.append("%d (%s)" % [n, "overwrite" if Game.has_saved_set(n) else "empty"])
	hud.toast("Save to slot %s?  Other key: cancel" % " or ".join(choices), 3600.0)


func _answer_save_prompt(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or event is InputEventMouse:
		return
	get_viewport().set_input_as_handled()
	saving_prompt = false
	for n: int in Game.USER_SLOTS:
		if event.is_action_pressed(StringName("set_%d" % n)):
			_save_to(n)
			return
	hud.toast("Not saved", 2.0)


func _save_to(slot: int) -> void:
	if Game.save_to_slot(slot):
		hud.toast("Saved to slot %d" % slot, 3.0)
	else:
		hud.toast("Could not save slot %d" % slot, 4.0)


func open_set_label() -> String:
	if Game.is_user_slot(Game.level_set):
		return "Slot %d%s" % [Game.level_set, "" if Game.has_saved_set(Game.level_set) else " (not saved yet)"]
	return "Level set %d (original)" % Game.level_set


## New: a LevelN.dat file replaces the set in memory; Ctrl+S then keeps it.
func _on_file_imported(file_name: String, bytes: PackedByteArray) -> void:
	if file_name.length() > 24:
		file_name = file_name.left(21) + "..."
	if not Game.use_bytes(bytes):
		hud.toast("%s: %d bytes, a level set has %d" % [file_name, bytes.size(), Game.LEVEL_BYTES], 5.0)
		return
	room_view.redraw()
	_update_view()
	hud.toast("Imported %s - Ctrl+S saves it" % file_name, 5.0)


# ----------------------------------------------------------------- view

func _update_view() -> void:
	_cursor_sprite.position = Vector2(cursor * Game.TILE) + Vector2(10, 10)
	_chooser_back.visible = picking
	_chooser.visible = picking
	if picking:
		Gfx.apply(_chooser, FLOOR_CHOOSER_GRAPH if layer == Game.Layer.FLOOR else OBJECT_CHOOSER_GRAPH)
	var mode := ("%s chooser open" if picking else "editing the %s layer") % ["floor" if layer == Game.Layer.FLOOR else "object"]
	var lines := PackedStringArray()
	lines.append("%s, room %d (row %d, column %d)" % [open_set_label(), Game.room,
		Game.room / Game.GRID_W + 1, Game.room % Game.GRID_W + 1])
	lines.append("Mode: %s" % mode)
	lines.append("Brush: %s" % Tiles.describe(_brush_layer, brush))
	if picking:
		lines.append("Under cursor: %s" % Tiles.describe(layer, Tiles.pick(layer == Game.Layer.FLOOR, cursor.x, cursor.y)))
	else:
		lines.append("Cell %d,%d: floor %s" % [cursor.x, cursor.y,
			Tiles.describe(Game.Layer.FLOOR, Game.cell(Game.Layer.FLOOR, cursor.x, cursor.y))])
		lines.append("          object %s" % Tiles.describe(Game.Layer.OBJECTS,
			Game.cell(Game.Layer.OBJECTS, cursor.x, cursor.y)))
	hud.set_status("\n".join(lines))
