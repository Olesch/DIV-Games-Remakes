class_name OptionsPanel
extends PanelContainer
## The options overlay: one row per value of Options.SPECS plus action buttons.
## Keyboard: Up/Down select, Left/Right change (or pick a button), Enter/Space activate.
## Mouse: click the < > arrows or the buttons; hovering a row selects it.

signal restart_requested
signal close_requested

const SELECTED_COLOUR := Color(0.25, 0.32, 0.55, 0.9)
const ACTIONS := ["Restart", "Random", "Original", "Close"]

var _rows: Array[Control] = []        # one per option + one for the button bar
var _value_labels: Dictionary = {}    # option key -> Label
var _action_buttons: Array[Button] = []
var _selected_row := 0
var _selected_action := 0

@onready var _row_box: VBoxContainer = %Rows
@onready var _button_bar: HBoxContainer = %Buttons
@onready var _footer: Label = %Footer


func _ready() -> void:
	for spec: Dictionary in Options.SPECS:
		_add_option_row(spec)
	for i in ACTIONS.size():
		var button := _make_button(ACTIONS[i])
		button.custom_minimum_size.x = 120
		button.pressed.connect(_run_action.bind(i))
		button.mouse_entered.connect(_select.bind(Options.SPECS.size(), i))
		_button_bar.add_child(button)
		_action_buttons.append(button)
	_rows.append(_button_bar)
	Options.changed.connect(func(_key: StringName) -> void: _refresh())
	visibility_changed.connect(_refresh)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_up", true):
		_select(posmod(_selected_row - 1, _rows.size()), _selected_action)
	elif event.is_action_pressed(&"ui_down", true):
		_select(posmod(_selected_row + 1, _rows.size()), _selected_action)
	elif event.is_action_pressed(&"ui_left", true):
		_change(-1)
	elif event.is_action_pressed(&"ui_right", true):
		_change(1)
	elif event.is_action_pressed(&"ui_accept"):
		if _on_button_bar():
			_run_action(_selected_action)
		else:
			_change(1)
	else:
		return
	get_viewport().set_input_as_handled()


## Index of the currently selected row (options first, then the button bar) - used by the autotest.
func selected_row() -> int:
	return _selected_row


func _on_button_bar() -> bool:
	return _selected_row == Options.SPECS.size()


func _change(direction: int) -> void:
	if _on_button_bar():
		_select(_selected_row, posmod(_selected_action + direction, ACTIONS.size()))
	else:
		Options.step_value(Options.SPECS[_selected_row]["key"], direction)


func _select(row: int, action: int) -> void:
	_selected_row = row
	_selected_action = action
	_refresh()


func _run_action(i: int) -> void:
	match ACTIONS[i]:
		"Restart":
			restart_requested.emit()
		"Random":
			Options.randomise()
		"Original":
			Options.reset_to_original()
		"Close":
			close_requested.emit()


func _add_option_row(spec: Dictionary) -> void:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override(&"panel", StyleBoxFlat.new())
	var box := HBoxContainer.new()
	box.add_theme_constant_override(&"separation", 8)
	row.add_child(box)
	var name_label := Label.new()
	name_label.text = spec["label"]
	name_label.custom_minimum_size.x = 230
	box.add_child(name_label)
	var minus := _make_button("<")
	var key: StringName = spec["key"]
	minus.pressed.connect(Options.step_value.bind(key, -1))
	box.add_child(minus)
	var value_label := Label.new()
	value_label.custom_minimum_size.x = 280
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(value_label)
	var plus := _make_button(">")
	plus.pressed.connect(Options.step_value.bind(key, 1))
	box.add_child(plus)
	var row_index := _rows.size()
	row.mouse_entered.connect(func() -> void: _select(row_index, _selected_action))
	for control: Control in [name_label, value_label]:
		control.mouse_filter = Control.MOUSE_FILTER_PASS
	_row_box.add_child(row)
	_rows.append(row)
	_value_labels[key] = value_label


func _make_button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.focus_mode = Control.FOCUS_NONE  # keyboard selection is handled by the panel itself
	button.custom_minimum_size = Vector2(36, 0)
	return button


func _refresh() -> void:
	if _value_labels.is_empty():
		return
	for spec: Dictionary in Options.SPECS:
		var key: StringName = spec["key"]
		(_value_labels[key] as Label).text = Options.format_value(key)
	for i in Options.SPECS.size():
		var style := (_rows[i] as PanelContainer).get_theme_stylebox(&"panel") as StyleBoxFlat
		style.bg_color = SELECTED_COLOUR if i == _selected_row else Color(0, 0, 0, 0)
	for i in _action_buttons.size():
		var highlighted := _on_button_bar() and i == _selected_action
		_action_buttons[i].modulate = Color(1.0, 0.9, 0.3) if highlighted else Color.WHITE
	_footer.text = "Original settings" if Options.is_default() else "Changed from the original"
