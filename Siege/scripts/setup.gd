@warning_ignore_start("integer_division")
class_name Setup
extends Node2D
## Setup page (new, owner's decision 2026-10-26): before the six help pages, choose who plays each castle -
## a human at the keyboard or the computer opponent KI(player) that the PRG contains but never starts.
## Drawn like the help pages (white page, black frames) with the DIV system font; the selected row gets the
## blue frame of the field cursor. Up/Down select, Left/Right (or Enter/Space on a player row) change,
## Enter/Space on START goes on to the help pages. Default: both HUMAN = the original game.

const FONT: FontFile = preload("res://assets/fnt/system/font_bmfont.fnt")
const INK := Color(0, 0, 0)
const CURSOR_BLUE := Color8(0, 0, 252)   # colour of the field cursor graph 2
const ROW_PLAYER_1 := 0
const ROW_PLAYER_2 := 1
const ROW_START := 2
const ROW_RECTS: Array[Rect2i] = [Rect2i(40, 58, 240, 40), Rect2i(40, 106, 240, 40), Rect2i(100, 162, 120, 24)]
const HUMAN_KEYS: Array[String] = ["ARROWS  O = PICK  P = BUILD  L = NEW", "W A S D  1 = PICK  2 = BUILD  Q = NEW"]

var _row := ROW_START


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_down", true):
		_row = (_row + 1) % ROW_RECTS.size()
	elif event.is_action_pressed(&"ui_up", true):
		_row = (_row + ROW_RECTS.size() - 1) % ROW_RECTS.size()
	elif event.is_action_pressed(&"ui_left") or event.is_action_pressed(&"ui_right"):
		_toggle()
	elif event.is_action_released(&"confirm"):
		# acts on release like the help pages, so the same key press does not also turn page 80
		if _row == ROW_START:
			get_tree().change_scene_to_file("res://scenes/splash.tscn")
			return
		_toggle()
	else:
		return
	queue_redraw()
	get_viewport().set_input_as_handled()


func _toggle() -> void:
	if _row != ROW_START:
		Game.computer[_row] = not Game.computer[_row]


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Defs.SCREEN), Color.WHITE)
	_text("SIEGE", 160, 16, 3)
	for p in 2:
		var r := ROW_RECTS[p]
		_frame(r, p)
		_text("PL %d" % (p + 1), r.position.x + 30, r.position.y + 6, 2)
		_text("COMPUTER" if Game.computer[p] else "HUMAN", r.position.x + 150, r.position.y + 6, 2)
		_text("SENDS WARRIORS" if Game.computer[p] else HUMAN_KEYS[p], r.get_center().x, r.position.y + 27, 1)
		# a warrior of that side (graph 101; player 2's units are mirrored)
		var side := 1.0 if p == 0 else -1.0
		var at := Vector2(r.position.x - 22 if p == 0 else r.end.x + 22, r.position.y + 2)
		draw_set_transform(at, 0.0, Vector2(2.0 * side, 2.0))
		draw_texture(Gfx.tex(101), Vector2(-Gfx.tex(101).get_width() / 2, 0))
		draw_set_transform(Vector2.ZERO)
	_frame(ROW_RECTS[ROW_START], ROW_START)
	_text("START", 160, ROW_RECTS[ROW_START].position.y + 4, 2)
	_text("UP/DOWN SELECT   LEFT/RIGHT CHANGE", 160, 204, 1)
	_text("ENTER OR SPACE: START", 160, 216, 1)


func _frame(r: Rect2i, row: int) -> void:
	if row == _row:
		draw_rect(Rect2(r).grow(-1), CURSOR_BLUE, false, 3.0)
	else:
		draw_rect(Rect2(r).grow(-0.5), INK, false, 1.0)


## Text in the 6x8 DIV system font at an integer scale, centred on cx, top edge at top.
func _text(value: String, cx: int, top: int, scale_factor: int) -> void:
	var width := int(FONT.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x)
	draw_set_transform(Vector2(cx - width * scale_factor / 2, top), 0.0, Vector2.ONE * scale_factor)
	draw_string(FONT, Vector2(0, 8), value, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, INK)
	draw_set_transform(Vector2.ZERO)
