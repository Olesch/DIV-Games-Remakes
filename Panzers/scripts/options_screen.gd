class_name OptionsScreen
extends Control
## Options screen before playing (new, owner's decision 2026-10-26; the original starts the
## duel at once and has no hits). Life (or the sandbox) and the tank camouflage.
## Keyboard: Up/Down select, Left/Right change, Enter start, Esc quit (desktop only).
## Mouse: hovering a row selects it, click the < > arrows or START.

const MAIN_SCENE := "res://scenes/main.tscn"

## Palette colours of PANZERS.FPG (greens 32..38, fire 28, grey 8)
const PANEL_COLOUR := Color8(0, 40, 0, 235)
const BORDER_COLOUR := Color8(0, 182, 0)
const SELECTED_COLOUR := Color8(0, 109, 0)
const BUTTON_COLOUR := Color8(0, 60, 0)
const BUTTON_HOVER_COLOUR := Color8(0, 85, 0)
const HIGHLIGHT_TEXT := Color8(255, 182, 56)
const DIM_TEXT := Color8(134, 134, 134)

const ROW_LIFE := 0
const ROW_CAMOUFLAGE := 1
const ROW_START := 2
const ROW_COUNT := 3

const HELP: Array[String] = [
	"HITS A TANK TAKES BEFORE IT IS DESTROYED.\nOFF = SANDBOX: SHELLS HURT NOTHING, NO WINNER (THE ORIGINAL).",
	"ON = TANKS PAINTED WITH THE GRASS COLOURS,\nNEARLY INVISIBLE (THE ORIGINAL LOOK).",
	"IN THE GAME: ESC = BACK TO THESE OPTIONS,\nENTER AFTER A ROUND = NEW ROUND.",
]

var _row := ROW_START
var _rows: Array[PanelContainer] = []
var _value_labels: Array[Label] = []
var _start_button: Button
var _help: Label

@onready var _background: TextureRect = $Background


func _ready() -> void:
	if "--autotest" in OS.get_cmdline_user_args():
		_start.call_deferred()  # the smoke test plays straight away with the current options
		return
	theme = Game.make_theme()
	_background.material = Camo.material_for(_background.texture)
	_build()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_up", true):
		_select(posmod(_row - 1, ROW_COUNT))
	elif event.is_action_pressed(&"ui_down", true):
		_select(posmod(_row + 1, ROW_COUNT))
	elif event.is_action_pressed(&"ui_left", true):
		_change(_row, -1)
	elif event.is_action_pressed(&"ui_right", true):
		_change(_row, 1)
	elif event.is_action_pressed(&"ui_accept"):
		_start()
	elif event.is_action_pressed(&"ui_cancel"):
		Game.quit_game()
	else:
		return
	get_viewport().set_input_as_handled()


func _start() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE)


func _select(row: int) -> void:
	_row = row
	_refresh()


func _change(row: int, direction: int) -> void:
	match row:
		ROW_LIFE:
			var index := Game.LIFE_CHOICES.find(Game.life)
			Game.life = Game.LIFE_CHOICES[clampi(index + direction, 0, Game.LIFE_CHOICES.size() - 1)]
		ROW_CAMOUFLAGE:
			Game.camouflage = not Game.camouflage
		_:
			return
	_select(row)


func _value_text(row: int) -> String:
	match row:
		ROW_LIFE:
			if Game.is_sandbox():
				return "OFF (SANDBOX)"
			return "1 HIT" if Game.life == 1 else "%d HITS" % Game.life
		ROW_CAMOUFLAGE:
			return "ON" if Game.camouflage else "OFF"
	return ""


func _build() -> void:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOUR
	style.border_color = BORDER_COLOUR
	style.set_border_width_all(Game.FONT_SCALE)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override(&"panel", style)
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 8)
	panel.add_child(box)

	_make_label(box, "PANZERS", 4).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_spacer(16))

	_add_option_row(box, ROW_LIFE, "LIFE")
	_add_option_row(box, ROW_CAMOUFLAGE, "CAMOUFLAGE")
	var start_row := _make_row(box, ROW_START)
	_start_button = _make_button("START")
	_start_button.custom_minimum_size.x = 200
	_start_button.pressed.connect(_start)
	_start_button.mouse_entered.connect(_select.bind(ROW_START))
	var centre := CenterContainer.new()
	centre.mouse_filter = Control.MOUSE_FILTER_PASS
	centre.add_child(_start_button)
	start_row.add_child(centre)

	box.add_child(_spacer(4))
	_help = _make_label(box, "", 1)
	_help.custom_minimum_size.y = 40
	_help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_help.add_theme_color_override(&"font_color", DIM_TEXT)
	box.add_child(_spacer(12))
	_make_label(box, "PLAYER 1:  J L TURN   K DRIVE   U O TURRET   I FIRE", 1)
	_make_label(box, "PLAYER 2:  A D TURN   S DRIVE   Q E TURRET   W FIRE", 1)
	box.add_child(_spacer(12))
	var keys := "UP/DOWN SELECT   LEFT/RIGHT CHANGE   ENTER START"
	if not OS.has_feature("web"):
		keys += "   ESC QUIT"
	var keys_label := _make_label(box, keys, 1)
	keys_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keys_label.add_theme_color_override(&"font_color", DIM_TEXT)

	# centre the panel on the 1024x768 screen
	panel.reset_size()
	panel.position = ((Game.SCREEN_SIZE - panel.size) * 0.5).floor()


func _add_option_row(parent: Control, row: int, caption: String) -> void:
	var box := HBoxContainer.new()
	box.add_theme_constant_override(&"separation", 8)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	_make_row(parent, row).add_child(box)
	_make_label(box, caption, 1).custom_minimum_size.x = 240
	var minus := _make_button("<")
	minus.pressed.connect(_change.bind(row, -1))
	box.add_child(minus)
	var value_label := _make_label(box, "", 1)
	value_label.custom_minimum_size.x = 240
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var plus := _make_button(">")
	plus.pressed.connect(_change.bind(row, 1))
	box.add_child(plus)
	_value_labels.append(value_label)
	for button: Button in [minus, plus]:
		button.mouse_entered.connect(_select.bind(row))


## A selectable row: a panel whose background shows the selection; hovering selects it.
func _make_row(parent: Control, row: int) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.set_content_margin_all(4)
	panel.add_theme_stylebox_override(&"panel", style)
	panel.mouse_entered.connect(_select.bind(row))
	parent.add_child(panel)
	_rows.append(panel)
	return panel


func _make_label(parent: Control, text: String, size_factor: int) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	label.add_theme_font_size_override(&"font_size", 8 * Game.FONT_SCALE * size_factor)
	parent.add_child(label)
	return label


func _make_button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.focus_mode = Control.FOCUS_NONE  # keyboard selection is handled by the screen itself
	button.custom_minimum_size = Vector2(36, 0)
	for state: StringName in [&"normal", &"hover", &"pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = BUTTON_COLOUR if state == &"normal" else BUTTON_HOVER_COLOUR
		style.border_color = BORDER_COLOUR
		style.set_border_width_all(Game.FONT_SCALE)
		style.set_content_margin_all(4)
		button.add_theme_stylebox_override(state, style)
	button.add_theme_color_override(&"font_hover_color", HIGHLIGHT_TEXT)
	return button


func _spacer(height: int) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _refresh() -> void:
	for i in _rows.size():
		var style := _rows[i].get_theme_stylebox(&"panel") as StyleBoxFlat
		style.bg_color = SELECTED_COLOUR if i == _row else Color(0, 0, 0, 0)
	for i in _value_labels.size():
		_value_labels[i].text = _value_text(i)
		_value_labels[i].add_theme_color_override(&"font_color",
			HIGHLIGHT_TEXT if i == _row else Color.WHITE)
	_start_button.add_theme_color_override(&"font_color",
		HIGHLIGHT_TEXT if _row == ROW_START else Color.WHITE)
	_help.text = HELP[_row]
