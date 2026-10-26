class_name OptionsPanel
extends PanelContainer
## In-game options overlay (new; the original hard-codes all of this). Opened with O / Esc.
## Rule, ants and start canvas restart the run; speed and edges apply at once.

const RULE_NAMES := {
	"RL": "RL - Langton's ant (default)",
	AntRule.ORIGINAL: "Original's bug - straight line",
}
const CANVAS_NAMES: Array[String] = ["Start picture (Ant.fpg)", "Random dots"]

var _rule_select: OptionButton
var _rule_edit: LineEdit
var _rule_error: Label
var _steps_select: OptionButton
var _ants_spin: SpinBox
var _canvas_select: OptionButton
var _wrap_check: CheckBox
var _restart_button: Button


func _ready() -> void:
	visible = false
	_build()
	_sync_from_settings()
	Settings.restart_requested.connect(_sync_from_settings)
	Settings.live_changed.connect(_sync_from_settings)


func toggle() -> void:
	visible = not visible
	if visible:
		_sync_from_settings()
		_rule_select.grab_focus()
	else:
		var focus := get_viewport().gui_get_focus_owner()
		if focus:
			focus.release_focus()


func _build() -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 8)
	add_child(box)

	var title := Label.new()
	title.text = "AntJumper options"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 16)
	grid.add_theme_constant_override(&"v_separation", 8)
	box.add_child(grid)

	_rule_select = OptionButton.new()
	for preset in Settings.RULE_PRESETS:
		_rule_select.add_item(RULE_NAMES.get(preset, preset))
	_rule_select.add_item("Custom")
	_rule_select.item_selected.connect(_on_rule_selected)
	_add_row(grid, "Rule", _rule_select)

	_rule_edit = LineEdit.new()
	_rule_edit.placeholder_text = "e.g. RLR"
	_rule_edit.max_length = AntRule.MAX_STATES
	_rule_edit.custom_minimum_size.x = 260
	_rule_edit.text_submitted.connect(_on_rule_submitted)
	_rule_edit.focus_exited.connect(func() -> void: _on_rule_submitted(_rule_edit.text))
	_add_row(grid, "Rule string", _rule_edit)

	_steps_select = OptionButton.new()
	for steps in Settings.STEP_CHOICES:
		_steps_select.add_item(str(steps) + (" (original)" if steps == Settings.DEFAULT_STEPS else ""))
	_steps_select.item_selected.connect(
		func(index: int) -> void: Settings.steps_per_frame = Settings.STEP_CHOICES[index])
	_add_row(grid, "Steps per frame", _steps_select)

	_ants_spin = SpinBox.new()
	_ants_spin.min_value = 1
	_ants_spin.max_value = Settings.MAX_ANTS
	_ants_spin.value_changed.connect(func(value: float) -> void: Settings.ant_count = int(value))
	_add_row(grid, "Ants", _ants_spin)

	_canvas_select = OptionButton.new()
	for canvas_name in CANVAS_NAMES:
		_canvas_select.add_item(canvas_name)
	_canvas_select.item_selected.connect(
		func(index: int) -> void: Settings.start_canvas = index as Settings.StartCanvas)
	_add_row(grid, "Start canvas", _canvas_select)

	_wrap_check = CheckBox.new()
	_wrap_check.text = "wrap around"
	_wrap_check.toggled.connect(func(on: bool) -> void: Settings.wrap_edges = on)
	_add_row(grid, "Edges", _wrap_check)

	_rule_error = Label.new()
	_rule_error.add_theme_color_override(&"font_color", Color(1, 0.4, 0.4))
	box.add_child(_rule_error)

	var help := Label.new()
	help.text = ("Rule letters, one per colour: L left, R right, S straight, U U-turn.\n"
		+ "On colour n the ant turns by letter n and paints colour n+1.\n"
		+ "Default RL is ANT.PRG with its colour-table slip fixed;\n"
		+ "\"Original's bug\" keeps the slip: the ant draws one line and leaves.")
	box.add_child(help)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override(&"separation", 12)
	box.add_child(buttons)
	_restart_button = _add_button(buttons, "Restart (R)", _on_restart)
	_add_button(buttons, "Defaults", Settings.reset_to_defaults)
	_add_button(buttons, "Close (Esc)", toggle)


func _add_row(grid: GridContainer, text: String, control: Control) -> void:
	var label := Label.new()
	label.text = text
	grid.add_child(label)
	grid.add_child(control)


func _add_button(parent: Control, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _sync_from_settings() -> void:
	var preset := Settings.RULE_PRESETS.find(Settings.rule_text)
	_rule_select.select(preset if preset >= 0 else Settings.RULE_PRESETS.size())
	if not _rule_edit.has_focus():
		_rule_edit.text = "" if Settings.rule_text == AntRule.ORIGINAL else Settings.rule_text
	_rule_edit.placeholder_text = "(ANT.PRG tables, unfixed)" if Settings.rule_text == AntRule.ORIGINAL else "e.g. RLR"
	_steps_select.select(maxi(0, Settings.STEP_CHOICES.find(Settings.steps_per_frame)))
	_ants_spin.set_value_no_signal(Settings.ant_count)
	_canvas_select.select(Settings.start_canvas)
	_wrap_check.set_pressed_no_signal(Settings.wrap_edges)


func _on_rule_selected(index: int) -> void:
	if index < Settings.RULE_PRESETS.size():
		_rule_error.text = ""
		Settings.rule_text = Settings.RULE_PRESETS[index]
	else:
		_rule_edit.grab_focus()


func _on_rule_submitted(text: String) -> void:
	if text.strip_edges().is_empty():
		_sync_from_settings()
		return
	var rule := AntRule.parse(text)
	if rule == null:
		_rule_error.text = "Invalid rule \"%s\": use 1-%d letters L R S U." % [text, AntRule.MAX_STATES]
		return
	_rule_error.text = ""
	Settings.rule_text = rule.label
	_sync_from_settings()


func _on_restart() -> void:
	Settings.restart_requested.emit()
