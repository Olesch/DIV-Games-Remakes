extends Node2D
## Level set choice. DIV: main code of CASTEDIT.PRG - write(0,400,300,4,"Welches Mapset? 1,2") and
## wait for key 1 or 2, then load saves/Level1.dat or Level2.dat. New: user slots 3 and 4 (an empty slot
## starts as a copy of set 1 or 2), D deletes a slot, and a controls list.

const CONTROLS := """Castedit - Oleg's room editor for Castle

Arrows: move cursor     Z: floor chooser     X: object chooser
Enter: pick / place     Del: clear cell      I J K L: change room
H or F1: help           Esc: back here
Ctrl+S: save to slot 3/4   Ctrl+E: export file   Ctrl+O: import file

Sets 1 and 2 are the originals and stay unchanged. Slots 3 and 4
are stored in this browser and can be played in Castle."""

enum Step { CHOOSE, START_FROM, DELETE_WHICH, DELETE_CONFIRM }

var _step := Step.CHOOSE
var _slot := 0
var _sets_label: PixelLabel
var _prompt_label: PixelLabel


func _ready() -> void:
	add_child(PixelLabel.create("Welches Mapset? 1,2", 400, 300, 4))   # "Which map set?"
	add_child(PixelLabel.create("Which level set? Press 1, 2, 3 or 4", 400, 316, 4))
	_sets_label = PixelLabel.create("", 400, 336, 4)
	_sets_label.add_theme_color_override(&"font_color", Color(1.0, 0.9, 0.45))
	add_child(_sets_label)
	_prompt_label = PixelLabel.create("", 400, 352, 4)
	add_child(_prompt_label)
	var info := PixelLabel.create(CONTROLS, 400, 380, 1)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.modulate = Color(0.7, 0.7, 0.7)
	add_child(info)
	_show_choose()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or event is InputEventMouse:
		return
	get_viewport().set_input_as_handled()
	var n := _set_number(event)
	match _step:
		Step.CHOOSE:
			if n in Game.ORIGINAL_SETS or Game.has_saved_set(n):
				Game.start_editor(n)
			elif n > 0:
				_slot = n
				_step = Step.START_FROM
				_prompt_label.set_value("Slot %d is empty. Start from a copy of set 1 or 2?" % n)
			elif event.is_action_pressed(&"delete_slot") and _saved_slots() > 0:
				_step = Step.DELETE_WHICH
				_prompt_label.set_value("Delete which slot? 3 or 4   (other key: cancel)")
		Step.START_FROM:
			if n in Game.ORIGINAL_SETS and Game.start_slot_from(_slot, n):
				Game.open_editor()
			else:
				_show_choose()
		Step.DELETE_WHICH:
			if Game.has_saved_set(n):
				_slot = n
				_step = Step.DELETE_CONFIRM
				_prompt_label.set_value("Delete slot %d for good? Enter: yes   any other key: no" % n)
			else:
				_show_choose()
		Step.DELETE_CONFIRM:
			if event.is_action_pressed(&"confirm"):
				Game.delete_slot(_slot)
				_show_choose()
				_prompt_label.set_value("Slot %d deleted." % _slot)
			else:
				_show_choose()


func _set_number(event: InputEvent) -> int:
	for n in range(1, 5):
		if event.is_action_pressed(StringName("set_%d" % n)):
			return n
	return 0


func _show_choose() -> void:
	_step = Step.CHOOSE
	var marks := PackedStringArray(["1, 2 - originals"])
	for n: int in Game.USER_SLOTS:
		marks.append("%d - %s" % [n, "saved" if Game.has_saved_set(n) else "empty"])
	_sets_label.set_value("     ".join(marks))
	_prompt_label.set_value("D: delete a slot" if _saved_slots() > 0 else "")


func _saved_slots() -> int:
	return Game.USER_SLOTS.filter(func(n: int) -> bool: return Game.has_saved_set(n)).size()
