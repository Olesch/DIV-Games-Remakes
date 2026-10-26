class_name Hud
extends PanelContainer
## Bottom bar with the controls and the run status (new: the original showed no text). H hides it.

@onready var _status: Label = $Lines/Status
@onready var _controls: Label = $Lines/Controls


func _ready() -> void:
	var zoom_out := "Ctrl/Q" if Settings.ctrl_zoom_available() else "Q"
	_controls.text = ("WASD/arrows/drag: move   Alt/E/wheel: zoom in   %s: zoom out   Home: reset view\n"
		+ "Space: pause   R: restart   O/Esc: options   H: hide this bar") % zoom_out


func show_status(rule_label: String, ant_count: int, steps_per_frame: int, total_steps: int,
		size_percent: float, paused: bool) -> void:
	_status.text = "Rule %s   ants %d   %d steps/frame   steps %d   zoom %d%%%s" % [
		rule_label, ant_count, steps_per_frame, total_steps, roundi(size_percent),
		"   PAUSED" if paused else ""]
