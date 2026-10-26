extends Node2D
## The settings screen = the first LOOP of the DIV main code, now also the title screen.
## Up/Down pick a row (the pointer is the graphic 7 shot), Left/Right change the value by the
## current step ("Pinselgr"), Q W A S Z X / E R T Y U I change the step, Esc / Enter / Space start.

const ARENA_SCENE := "res://scenes/arena.tscn"
const ROW_HEIGHT := 15
const POINTER_START := Vector2(190, 4)
const VALUE_X := 200

## DIV: Key(_Q) Pinselgr-=1 ... and Key(_E) Pinselgr=1 ... (action -> [is_relative, amount])
const BRUSH_KEYS := {
	&"brush_minus_1": [true, -1], &"brush_plus_1": [true, 1],
	&"brush_minus_10": [true, -10], &"brush_plus_10": [true, 10],
	&"brush_minus_100": [true, -100], &"brush_plus_100": [true, 100],
	&"brush_set_1": [false, 1], &"brush_set_5": [false, 5], &"brush_set_10": [false, 10],
	&"brush_set_50": [false, 50], &"brush_set_100": [false, 100], &"brush_set_1000": [false, 1000],
}

var _row := 0  # DIV: zeigerpos - 1
var _value_labels: Array[PixelLabel] = []
var _brush_label: PixelLabel
var _starting := false

@onready var _pointer: Sprite2D = $Pointer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_pointer.texture = Gfx.tex(Gfx.FIRST_SHOT)
	# DIV: write(0, ...) texts - font 0 is the 6x8 system font
	_add_text("Einstellzahl Knoepfe Q W A S Z X", Vector2(300, 0))
	_add_text("E=1 R=5 T=10 Y=50 U=100 I=1000", Vector2(300, 15))
	for i in Defs.SETTING_ROWS.size():
		_add_text(Defs.SETTING_ROWS[i][1], Vector2(0, i * ROW_HEIGHT))
		_value_labels.append(_add_text("", Vector2(VALUE_X, i * ROW_HEIGHT)))
	_brush_label = _add_text("", Vector2(600, 0))
	_add_title_block()
	Game.settings_changed.connect(_refresh)
	_refresh()
	_move_pointer()


func _unhandled_input(event: InputEvent) -> void:
	# The original repeats every action once per frame while the key is held; here a key press and
	# the OS key repeat (echo) do the same.
	if event.is_action_pressed(&"set_down", true):
		_row = mini(_row + 1, Defs.SETTING_ROWS.size() - 1)  # DIV let the pointer run off the list
		_move_pointer()
	elif event.is_action_pressed(&"set_up", true):
		_row = maxi(_row - 1, 0)
		_move_pointer()
	elif event.is_action_pressed(&"set_dec", true):
		Game.adjust(Defs.SETTING_ROWS[_row][0], -Game.brush)
	elif event.is_action_pressed(&"set_inc", true):
		Game.adjust(Defs.SETTING_ROWS[_row][0], Game.brush)
	elif event.is_action_pressed(&"start_game"):
		_start_game()
	else:
		for action: StringName in BRUSH_KEYS:
			if event.is_action_pressed(action, true):
				var entry: Array = BRUSH_KEYS[action]
				Game.brush = Game.brush + entry[1] if entry[0] else entry[1]
				break


func _start_game() -> void:
	if _starting:
		return
	_starting = true
	get_tree().change_scene_to_file(ARENA_SCENE)


func _move_pointer() -> void:
	_pointer.position = POINTER_START + Vector2(0, _row * ROW_HEIGHT)


func _refresh() -> void:
	for i in Defs.SETTING_ROWS.size():
		_value_labels[i].set_value(str(Game.get(Defs.SETTING_ROWS[i][0])))
	_brush_label.set_value(str(Game.brush))


func _add_text(text_value: String, at: Vector2, align: int = 0,
		kind: PixelLabel.FontKind = PixelLabel.FontKind.SYSTEM) -> PixelLabel:
	var label := PixelLabel.make(text_value, at, align, kind)
	add_child(label)
	return label


## New: the title and a short control list in the empty lower half of the original screen.
func _add_title_block() -> void:
	_add_text("Tutorial 1", Vector2(320, 262), 4, PixelLabel.FontKind.MINI1)
	_add_text("von Oleg Yuschuk, 2004  -  Neuumsetzung in Godot", Vector2(320, 300), 4)
	_add_text("Pfeil hoch/runter: Zeile    Pfeil links/rechts: Wert aendern", Vector2(320, 330), 4)
	_add_text("Esc / Enter / Leertaste: Spiel starten (4 Schiffe, Esc: zurueck hierher)", Vector2(320, 345), 4)
	_add_text("Spieler 1  Pfeil links/rechts, Pfeil hoch = Schuss, Pfeil runter = Explosionsschuss", Vector2(320, 380), 4)
	_add_text("Spieler 2  A / D, W = Schuss, Q = Explosionsschuss", Vector2(320, 395), 4)
	_add_text("Spieler 3  Ziffernblock 1 / 3, 5 = Schuss, Entf = Explosionsschuss", Vector2(320, 410), 4)
	_add_text("Spieler 4  J / L, I = Schuss, U = Explosionsschuss", Vector2(320, 425), 4)
