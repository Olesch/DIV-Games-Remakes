extends Node2D
## Kochkurve: a black screen with two menu lines. Pressing 1 (or F1) draws a Sierpinski triangle
## of depth 7 in one go. Key 2 (or F2) was meant to draw a Koch curve, but Oleg never finished
## that routine and the key draws the same Sierpinski triangle. After one drawing the program
## ignores all further keys, exactly like the original (it parks in an endless empty loop).

const DEPTH := 7  # DIV: CONST DEPTH=7
## Start triangle (DIV: x0,y0 / x1,y1 / x2,y2 in the //Init blocks)
const TOP := Vector2i(512, 100)
const BOTTOM_RIGHT := Vector2i(924, 668)
const BOTTOM_LEFT := Vector2i(100, 668)

var canvas: PixelCanvas
var drawn := false


func _ready() -> void:
	_setup_input()
	canvas = PixelCanvas.new()
	add_child(canvas)
	# texts are above the background drawing, like DIV's text_z
	var hud := CanvasLayer.new()
	add_child(hud)
	PixelLabel.make(hud, "1 - Sierpinski", 0, 0, 0)
	PixelLabel.make(hud, "2 - Koch", 0, 8, 0)
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _unhandled_input(event: InputEvent) -> void:
	if drawn:
		return
	# The original tests key 1 first; both branches draw the Sierpinski triangle.
	if event.is_action_pressed(&"draw_sierpinski") or event.is_action_pressed(&"draw_koch"):
		draw_figure()


func draw_figure() -> void:
	drawn = true
	Sierpinski.draw(canvas, TOP, BOTTOM_RIGHT, BOTTOM_LEFT, DEPTH)


func _setup_input() -> void:
	_bind(&"draw_sierpinski", [KEY_1, KEY_F1])  # DIV: key(_f1) OR key(_1)
	_bind(&"draw_koch", [KEY_2, KEY_F2])        # DIV: key(_f2) OR key(_2)


func _bind(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k: Key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
