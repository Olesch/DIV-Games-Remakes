class_name OptionsScreen
extends Control
## Options screen shown before playing (new, owner's request 2026-10-26; the original had no menu
## and hard-codes all of this). Esc twice in the game comes back here.
## Keyboard: Up/Down select, Left/Right change, Enter start (or reset on "ORIGINAL SETTINGS").
## Mouse: hover selects; left click / wheel up = next value, right click / wheel down = previous;
## clicking START starts.

const GAME_SCENE := "res://scenes/main.tscn"
const FONT_PATH := "res://assets/fnt/system/font_bmfont.fnt"
const FONT_SCALE := 2  # DIV system font is 6x8; drawn at 2x on the 1024x768 screen
const SELECTED_COLOUR := Color(1.0, 0.9, 0.2)
const DIM_COLOUR := Color(0.65, 0.65, 0.65)

enum Row { SNIPERS, RIFLES, MINIGUNS, GRENADES, BALLOONS, ORIGINAL, START }

const WEAPON_ROWS := {
	Row.RIFLES: Sniper.Mode.NORMAL,
	Row.MINIGUNS: Sniper.Mode.MINIGUN,
	Row.GRENADES: Sniper.Mode.GRENADE,
}

var _row: Row = Row.START
var _row_labels: Array[Label] = []
var _footer: Label
var _message := ""


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		_start_game.call_deferred()
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	theme = _make_theme()
	_build()
	_refresh()


func _build() -> void:
	var background := ColorRect.new()
	background.color = Color.BLACK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var centre := CenterContainer.new()
	centre.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centre)
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 12)
	centre.add_child(box)

	var title := _add_label(box, "SNIPER")
	title.add_theme_font_size_override(&"font_size", 8 * FONT_SCALE * 3)
	_add_label(box, "OPTIONS", DIM_COLOUR)
	_add_spacer(box, 16)

	for row: Row in Row.values():
		if row == Row.ORIGINAL:
			_add_spacer(box, 12)
		var label := _add_label(box, "")
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.mouse_entered.connect(_select.bind(row))
		label.gui_input.connect(_on_row_input.bind(row))
		_row_labels.append(label)

	_add_spacer(box, 8)
	_footer = _add_label(box, "", DIM_COLOUR)
	_add_spacer(box, 24)
	for line in [
			"UP/DOWN SELECT   LEFT/RIGHT CHANGE   ENTER START",
			"MOUSE: CLICK / WHEEL CHANGE, RIGHT CLICK BACK",
			"",
			"IN THE GAME: MOUSE AIMS, LEFT BUTTON FIRES, UP/DOWN MOVE THE COLUMN",
			"MINIGUN: HOLD FIRE TO SPIN UP, 75 SHOTS, RIGHT BUTTON RELOADS",
			"ESC FREES THE MOUSE, ESC AGAIN COMES BACK HERE"]:
		_add_label(box, line, DIM_COLOUR)


func _add_label(parent: Control, text: String, colour := Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override(&"font_color", colour)
	parent.add_child(label)
	return label


func _add_spacer(parent: Control, height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(spacer)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_up", true):
		_select(posmod(_row - 1, Row.size()) as Row)
	elif event.is_action_pressed(&"ui_down", true):
		_select(posmod(_row + 1, Row.size()) as Row)
	elif event.is_action_pressed(&"ui_left", true):
		_change(_row, -1)
	elif event.is_action_pressed(&"ui_right", true):
		_change(_row, 1)
	elif event.is_action_pressed(&"ui_accept"):
		if _row == Row.ORIGINAL:
			_change(_row, 1)
		else:
			_start_game()
	elif event.is_action_pressed(&"release_mouse") and not OS.has_feature("web"):
		get_tree().quit()
	else:
		return
	get_viewport().set_input_as_handled()


func _on_row_input(event: InputEvent, row: Row) -> void:
	var button := event as InputEventMouseButton
	if button == null:
		return
	if row == Row.START:
		# start on release, so the held button does not fire the first salvo
		if button.button_index == MOUSE_BUTTON_LEFT and not button.pressed:
			_start_game()
	elif button.pressed:
		match button.button_index:
			MOUSE_BUTTON_LEFT, MOUSE_BUTTON_WHEEL_UP:
				_change(row, 1)
			MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_WHEEL_DOWN:
				_change(row, -1)
			_:
				return
	accept_event()


func _select(row: Row) -> void:
	_row = row
	_message = ""
	_refresh()


func _change(row: Row, direction: int) -> void:
	_select(row)
	match row:
		Row.SNIPERS:
			Settings.step_sniper_count(direction)
		Row.RIFLES, Row.MINIGUNS, Row.GRENADES:
			var mode: Sniper.Mode = WEAPON_ROWS[row]
			if not Settings.set_weapon(mode, not Settings.is_weapon_on(mode)):
				_message = "AT LEAST ONE WEAPON MUST STAY ON"
		Row.BALLOONS:
			Settings.step_balloon_rate(direction)
		Row.ORIGINAL:
			Settings.reset_to_defaults()
	_refresh()


func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _refresh() -> void:
	var texts: Array[String] = [
		"SNIPERS: %d" % Settings.sniper_count,
		"RIFLES: %s" % _on_off(Sniper.Mode.NORMAL),
		"MINIGUNS: %s" % _on_off(Sniper.Mode.MINIGUN),
		"GRENADE LAUNCHERS: %s" % _on_off(Sniper.Mode.GRENADE),
		"BALLOONS: %s" % _balloon_rate_text(),
		"ORIGINAL SETTINGS",
		"START",
	]
	for i in texts.size():
		var selected := i == _row
		_row_labels[i].text = ("> %s <" % texts[i]) if selected else texts[i]
		_row_labels[i].add_theme_color_override(&"font_color", SELECTED_COLOUR if selected else Color.WHITE)
	if _message != "":
		_footer.text = _message
	elif Settings.is_default():
		_footer.text = "AS IN THE ORIGINAL"
	elif Settings.enabled_modes().size() > 1:
		_footer.text = "CHANGED - THE COLUMN TAKES THE WEAPONS IN TURN"
	else:
		_footer.text = "CHANGED FROM THE ORIGINAL"


func _on_off(mode: Sniper.Mode) -> String:
	return "ON" if Settings.is_weapon_on(mode) else "OFF"


func _balloon_rate_text() -> String:
	var rate := Settings.balloons_per_second
	if rate < 1.0:
		return "1 EVERY %d SECONDS" % roundi(1.0 / rate)
	var amount := str(roundi(rate)) if is_equal_approx(rate, roundf(rate)) else String.num(rate)
	return "%s PER SECOND" % amount


func _make_theme() -> Theme:
	var font := load(FONT_PATH) as FontFile
	font.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	var ui_theme := Theme.new()
	ui_theme.default_font = font
	ui_theme.default_font_size = 8 * FONT_SCALE
	return ui_theme
