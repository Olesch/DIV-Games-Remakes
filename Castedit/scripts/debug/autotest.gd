extends Node
## Headless smoke test, only active with `-- --autotest` (added by the Game autoload).
## Loads both level sets, opens the editor, then drives it with simulated key events: cursor moves,
## both choosers, placing/erasing on both layers, an empty chooser slot, hold-to-draw, room changes
## (incl. the original's room-29 limit), Ctrl+S on an original (cancel, then save to slot 3), Ctrl+S in a
## slot, import (wrong and right size), Ctrl+E/Ctrl+O dialogs, help, Esc, the slot marks, an empty slot
## started from set 2, D-delete on the start screen, and that an old CastleLevel1.dat is ignored.
## CastleLevel1..4.dat the user already had are moved aside during the test and put back at the end,
## so user:// looks exactly as before. Prints a summary and quits with exit code 0/1 (desktop only).
## `--screenshot=<path>` saves PNGs of the editor and the start screen (needs a window).

const STEP_TICKS := 8   # physics ticks (24/s) between steps; the editor needs up to 4 after a pick
const BACKUP_SUFFIX := ".autotest-backup"

var _steps: Array[Callable] = []
var _step := 0
var _ticks := 0
var _failures := 0
var _screenshot_path := ""
var _user_files_before := PackedStringArray()
var _held_actions: Array[StringName] = []
var _queue: Array[StringName] = []
var _saved_map := PackedInt32Array()


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_screenshot_path = arg.substr("--screenshot=".length())
	_user_files_before = _user_files()
	for n in range(1, 5):
		var path := Game.SAVED_PATH % n
		if FileAccess.file_exists(path + BACKUP_SUFFIX) and not FileAccess.file_exists(path):
			DirAccess.rename_absolute(path + BACKUP_SUFFIX, path)   # left by an interrupted run
		if FileAccess.file_exists(Game.SAVED_PATH % n):
			DirAccess.rename_absolute(Game.SAVED_PATH % n, Game.SAVED_PATH % n + BACKUP_SUFFIX)
	# a leftover of the previous version (sets 1/2 were saved over): must be ignored
	var old := FileAccess.open(Game.SAVED_PATH % 1, FileAccess.WRITE)
	old.store_buffer(FileAccess.get_file_as_bytes(Game.ORIGINAL_PATH % 2))
	old.close()
	_steps = [
		_check_data, _open_editor, _check_room_drawn,
		_move_cursor, _check_cursor,
		_open_floor_chooser, _check_floor_chooser, _choose, _check_brush_wall,
		_place, _check_wall_placed, _erase, _check_floor_erased,
		_open_object_chooser, _move_to_ork, _choose, _check_brush_ork,
		_place, _check_ork_placed, _erase, _check_ork_erased,
		_open_object_chooser, _move_to_empty_slot, _choose, _check_empty_brush,
		_place, _check_empty_placed,
		_start_drawing, _wait, _wait, _stop_drawing, _check_line,
		_room_right, _check_room_14, _room_down_from_29, _check_room_limit,
		_ctrl_s, _cancel_save, _check_cancelled, _ctrl_s, _save_slot_3, _check_saved, _ctrl_s, _check_saved_again,
		_import_files, _check_import, _ctrl_e, _check_dialog, _ctrl_o, _check_dialog,
		_help, _check_help,
		_screenshot_room, _screenshot_chooser,
		_escape, _check_title, _screenshot_title, _check_start_from_open, _check_slot_4_from_set_2,
		_delete_slot_3, _check_deleted, _finish,
	]
	print("AUTOTEST start")


func _physics_process(_delta: float) -> void:
	if not _queue.is_empty():
		_send_tap(_queue.pop_front())
		_ticks = 0
		return
	_ticks += 1
	if _ticks < STEP_TICKS or _step >= _steps.size():
		return
	_ticks = 0
	var s := _steps[_step]
	_step += 1
	s.call()


# ----------------------------------------------------------------- helpers

func _editor() -> Editor:
	return get_tree().current_scene as Editor


func _check(cond: bool, msg: String) -> void:
	print("  ok   " if cond else "  FAIL ", msg)
	if not cond:
		_failures += 1


## Queues `times` key taps (press + release); one tap is sent per physics tick.
func _tap(action: StringName, times: int = 1) -> void:
	for i in times:
		_queue.append(action)


func _send_tap(action: StringName) -> void:
	var e := InputEventAction.new()
	e.action = action
	e.pressed = true
	Input.parse_input_event(e)
	var r := InputEventAction.new()
	r.action = action
	r.pressed = false
	Input.parse_input_event(r)


func _hold(action: StringName) -> void:
	Input.action_press(action)
	_held_actions.append(action)


func _user_files() -> PackedStringArray:
	var out := PackedStringArray()
	var dir := DirAccess.open("user://")
	if dir:
		for f in dir.get_files():
			out.append(f)
	return out


func _count_objects() -> int:
	var n := 0
	for y in Game.ROWS:
		for x in Game.COLS:
			if Tiles.OBJECT_GRAPHS.has(Game.cell(Game.Layer.OBJECTS, x, y)):
				n += 1
	return n


# ----------------------------------------------------------------- steps

func _check_data() -> void:
	for n in [2, 1]:
		_check(Game.load_levelset(n), "level set %d loads (%d ints)" % [n, Game.map.size()])
	_check(Game.map[Game.index_of(13, 0, 0, 0)] == 22, "set 1 room 13 top-left is a wall")


func _open_editor() -> void:
	Game.start_editor(1)


func _check_room_drawn() -> void:
	var e := _editor()
	_check(e != null, "editor scene is running")
	_check(Game.room == 13, "editor starts in room 13")
	_check(e.room_view.marker_count() == _count_objects(),
		"room 13 shows %d object markers (expected %d)" % [e.room_view.marker_count(), _count_objects()])


func _move_cursor() -> void:
	_tap(&"cursor_right", 3)
	_tap(&"cursor_down", 2)


func _check_cursor() -> void:
	_check(_editor().cursor == Vector2i(3, 2), "cursor moved to 3,2 (is %s)" % _editor().cursor)


func _open_floor_chooser() -> void:
	_tap(&"pick_floor")


func _check_floor_chooser() -> void:
	var e := _editor()
	_check(e.picking and e.layer == Game.Layer.FLOOR and e.cursor == Vector2i.ZERO, "floor chooser open, cursor at 0,0")
	_tap(&"cursor_right")   # slot 1 = wall


func _choose() -> void:
	_tap(&"place")


func _check_brush_wall() -> void:
	var e := _editor()
	_check(not e.picking and e.brush == 22 and e.cursor == Vector2i(3, 2), "picked wall (22), cursor back at 3,2")


func _place() -> void:
	_tap(&"place")


func _check_wall_placed() -> void:
	_check(Game.cell(Game.Layer.FLOOR, 3, 2) == 22, "wall placed at 3,2")


func _erase() -> void:
	_tap(&"erase")


func _check_floor_erased() -> void:
	_check(Game.cell(Game.Layer.FLOOR, 3, 2) == 6, "Del made 3,2 plain floor (6)")


func _open_object_chooser() -> void:
	_tap(&"pick_object")


func _move_to_ork() -> void:
	_tap(&"cursor_down", 3)   # row 3, slot 0 = Ork


func _check_brush_ork() -> void:
	_check(_editor().brush == 41 and _editor().layer == Game.Layer.OBJECTS, "picked Ork (41) on the object layer")


func _check_ork_placed() -> void:
	_check(Game.cell(Game.Layer.OBJECTS, 3, 2) == 41, "Ork placed at 3,2")
	_check(_editor().room_view.marker_count() == _count_objects(), "marker count follows (%d)" % _count_objects())


func _check_ork_erased() -> void:
	_check(Game.cell(Game.Layer.OBJECTS, 3, 2) == 0, "Del removed the Ork")


func _move_to_empty_slot() -> void:
	_tap(&"cursor_down", 10)


func _check_empty_brush() -> void:
	_check(_editor().brush == Tiles.EMPTY_PICK, "empty chooser slot gives the invisible value")


func _check_empty_placed() -> void:
	_check(Game.cell(Game.Layer.OBJECTS, 3, 2) == Tiles.EMPTY_PICK, "invisible value stored at 3,2")
	_check(_editor().room_view.marker_count() == _count_objects(), "and no marker drawn for it")


func _start_drawing() -> void:
	var e := _editor()
	e.open_chooser(Game.Layer.FLOOR)
	e.cursor = Vector2i(1, 0)
	e.pick_at_cursor()
	e.cursor = Vector2i(5, 10)
	for x in Game.COLS:
		Game.set_cell(Game.Layer.FLOOR, x, 10, 6)
	_hold(&"place")
	_hold(&"cursor_right")


func _wait() -> void:
	pass


func _stop_drawing() -> void:
	for a in _held_actions:
		Input.action_release(a)
	_held_actions.clear()


func _check_line() -> void:
	var walls := 0
	for x in Game.COLS:
		if Game.cell(Game.Layer.FLOOR, x, 10) == 22:
			walls += 1
	_check(walls >= 4 and walls == _editor().cursor.x - 5, "holding Enter + Right drew a wall line (%d cells, cursor now %s)" % [walls, _editor().cursor])


func _room_right() -> void:
	_tap(&"room_right")


func _check_room_14() -> void:
	_check(Game.room == 14, "L moved to room 14")
	Game.room = 29
	_editor().room_view.redraw()


func _room_down_from_29() -> void:
	_tap(&"room_down")


func _check_room_limit() -> void:
	_check(Game.room == 29, "K from room 29 is blocked like the original (Stage<29)")
	_tap(&"room_up")


func _ctrl_key(key: Key) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = key
	e.keycode = key
	e.ctrl_pressed = true
	e.pressed = true
	Input.parse_input_event(e)
	var r := e.duplicate() as InputEventKey
	r.pressed = false
	Input.parse_input_event(r)


func _ctrl_s() -> void:
	_ctrl_key(KEY_S)


func _cancel_save() -> void:
	var e := _editor()
	_check(e.saving_prompt and e.hud.toast_text().begins_with("Save to slot 3 (empty) or 4 (empty)?"),
		"Ctrl+S on original set 1 asks for slot 3 or 4 ('%s')" % e.hud.toast_text())
	_tap(&"help")


func _check_cancelled() -> void:
	var e := _editor()
	_check(not e.saving_prompt and not e.hud.is_help_visible() and e.hud.toast_text() == "Not saved",
		"any other key cancels, nothing else happens")
	_check(not FileAccess.file_exists(Game.SAVED_PATH % 3) and not FileAccess.file_exists(Game.SAVED_PATH % 4),
		"nothing written")


func _save_slot_3() -> void:
	_tap(&"set_3")


func _check_saved() -> void:
	_check(_editor().hud.toast_text() == "Saved to slot 3" and Game.level_set == 3, "3 saves to slot 3, which is now open")
	var bytes := FileAccess.get_file_as_bytes(Game.SAVED_PATH % 3)
	_check(bytes.size() == Game.LEVEL_BYTES and bytes == Game.map.to_byte_array(),
		"user://CastleLevel3.dat holds the map in the original format (%d bytes)" % bytes.size())
	_saved_map = Game.map.duplicate()
	Game.load_levelset(1)
	_check(Game.map == FileAccess.get_file_as_bytes(Game.ORIGINAL_PATH % 1).to_int32_array(),
		"set 1 is still the original (old CastleLevel1.dat ignored)")
	Game.load_levelset(3)
	_check(Game.map == _saved_map and Game.map[Game.index_of(13, 0, 6, 10)] == 22,
		"loading slot 3 reads the saved map (with the drawn wall line)")
	Game.room = 23
	Game.set_cell(Game.Layer.FLOOR, 0, 0, 40)
	_saved_map = Game.map.duplicate()


func _check_saved_again() -> void:
	var e := _editor()
	_check(not e.saving_prompt and e.hud.toast_text() == "Saved to slot 3", "Ctrl+S in slot 3 saves straight back")
	_check(FileAccess.get_file_as_bytes(Game.SAVED_PATH % 3) == _saved_map.to_byte_array(), "with the latest change")


func _import_files() -> void:
	var e := _editor()
	e._on_file_imported("broken.dat", PackedByteArray([1, 2, 3]))
	_check(e.hud.toast_text().contains("3 bytes") and Game.map == _saved_map, "importing a 3-byte file is refused")
	e._on_file_imported("level2.dat", FileAccess.get_file_as_bytes(Game.ORIGINAL_PATH % 2))


func _check_import() -> void:
	var original_2 := FileAccess.get_file_as_bytes(Game.ORIGINAL_PATH % 2).to_int32_array()
	_check(Game.map == original_2 and Game.level_set == 3, "importing Level2.dat replaces slot 3 in memory")
	_check(FileAccess.get_file_as_bytes(Game.SAVED_PATH % 3) == _saved_map.to_byte_array(),
		"import alone does not overwrite the saved file")
	Game.map = _saved_map.duplicate()
	_editor().room_view.redraw()


func _ctrl_e() -> void:
	_editor().files.use_native_dialog = false
	_ctrl_key(KEY_E)


func _ctrl_o() -> void:
	_ctrl_key(KEY_O)


func _check_dialog() -> void:
	var files := _editor().files
	_check(files.is_dialog_open(), "Ctrl+E / Ctrl+O opens the file dialog (desktop)")
	if files.is_dialog_open():
		files._dialog.hide()


func _help() -> void:
	_tap(&"help")


func _check_help() -> void:
	_check(_editor().hud.is_help_visible(), "H shows the help overlay")
	_tap(&"help")
	_editor().hud.clear_toast()
	Game.room = 13
	_editor().cursor = Vector2i(20, 16)
	_editor().room_view.redraw()


func _screenshot_room() -> void:
	_save_screenshot("")


func _screenshot_chooser() -> void:
	_editor().open_chooser(Game.Layer.OBJECTS)
	_editor()._update_view()
	_editor().hud.toggle_help()


func _escape() -> void:
	_save_screenshot("_chooser")
	_editor().hud.toggle_help()
	_tap(&"back")


func _check_title() -> void:
	_check(get_tree().current_scene.name == "Title", "Esc returns to the level set choice")
	_check(_title_text().contains("3 - saved") and _title_text().contains("4 - empty"),
		"start screen shows slot 3 saved, slot 4 empty")


func _screenshot_title() -> void:
	_save_screenshot("_title")
	_tap(&"set_4")


func _check_start_from_open() -> void:
	_check(_title_text().contains("Slot 4 is empty. Start from a copy of set 1 or 2?"), "empty slot 4 offers a start set")
	_tap(&"set_2")


func _check_slot_4_from_set_2() -> void:
	var e := _editor()
	_check(e != null and Game.level_set == 4 and not Game.has_saved_set(4)
		and Game.map == FileAccess.get_file_as_bytes(Game.ORIGINAL_PATH % 2).to_int32_array(),
		"slot 4 opens as an unsaved copy of set 2")
	_tap(&"back")


func _delete_slot_3() -> void:
	_check(not Game.has_saved_set(4), "leaving without Ctrl+S keeps slot 4 empty")
	_tap(&"delete_slot")
	_tap(&"set_4")      # empty slot: cancels
	_tap(&"delete_slot")
	_tap(&"set_3")
	_tap(&"confirm")


func _check_deleted() -> void:
	_check(not Game.has_saved_set(3) and _title_text().contains("3 - empty"), "D, 3, Enter deletes slot 3")
	_check(FileAccess.file_exists(Game.SAVED_PATH % 1), "the old CastleLevel1.dat is left alone")


func _title_text() -> String:
	var texts := PackedStringArray()
	for child in get_tree().current_scene.get_children():
		if child is Label:
			texts.append(child.text)
	return "\n".join(texts)


func _save_screenshot(suffix: String) -> void:
	if _screenshot_path == "" or DisplayServer.get_name() == "headless":
		return
	var path := _screenshot_path.get_basename() + suffix + "." + _screenshot_path.get_extension()
	get_viewport().get_texture().get_image().save_png(path)
	print("screenshot saved: ", path)


func _finish() -> void:
	for n in range(1, 5):
		if FileAccess.file_exists(Game.SAVED_PATH % n):
			DirAccess.remove_absolute(Game.SAVED_PATH % n)
		if FileAccess.file_exists(Game.SAVED_PATH % n + BACKUP_SUFFIX):
			DirAccess.rename_absolute(Game.SAVED_PATH % n + BACKUP_SUFFIX, Game.SAVED_PATH % n)
	_check(_user_files() == _user_files_before, "user:// is left as it was (%s)" % ", ".join(_user_files()))
	print("AUTOTEST done: %d failure(s)" % _failures)
	if not OS.has_feature("web"):
		get_tree().quit(1 if _failures > 0 else 0)
