extends Node2D
## The menu part of the DIV main code: "S - new game / L - load game", level set 1-2, difficulty
## selection with the particle show, or slot selection 1-4. Runs one step per physics tick (24/s)
## like the original loops did.

const SPEC_EFFECT_SCENE := preload("res://scenes/spec_effect.tscn")

enum Step { MENU, LEVELSET, DIFFICULTY, LOAD }

var _step: Step = Step.MENU
var _labels: Array[PixelLabel] = []
var _difficulty: int = 0         # DIV: difficulty starts at 0 = "Erwachsener"
var _particle_timer: Timer
var _difficulty_label: PixelLabel
var _message: PixelLabel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_particle_timer = Timer.new()
	_particle_timer.wait_time = 3.0 / Game.FPS   # DIV: FRAME(300) in the difficulty loop
	_particle_timer.timeout.connect(_emit_particles)
	add_child(_particle_timer)
	_show_menu()


func _clear_labels() -> void:
	for l in _labels:
		l.queue_free()
	_labels.clear()
	_difficulty_label = null
	_message = null


func _write(text: String, x: float, y: float, align: int) -> PixelLabel:
	var l := PixelLabel.create(text, x, y, align)
	l.z_index = 256
	add_child(l)
	_labels.append(l)
	return l


func _show_menu() -> void:
	_step = Step.MENU
	_clear_labels()
	_write("S-Starte neues Spiel", 400, 285, 4)
	_write("L-Lade altes Spiel", 400, 315, 4)


func _unhandled_input(event: InputEvent) -> void:
	match _step:
		Step.MENU:
			if event.is_action_pressed(&"menu_new"):
				_clear_labels()
				_write("Welches Levelset? 1-4", 400, 300, 5)   # original: 1-2 (sets 3/4 are new)
				_write(_slots_text(), 400, 345, 4)
				_step = Step.LEVELSET
			elif event.is_action_pressed(&"menu_load"):
				_clear_labels()
				_write("Waehle eine Nummer - 1  2  3  4", 400, 285, 5)
				_step = Step.LOAD
		Step.LEVELSET:
			var set_no := Game.slot_for_event(event)
			if set_no > 0 and Game.load_levelset(set_no):
				_clear_labels()
				_write("Schwierigkeitsstufe:", 400, 300, 5)
				_difficulty_label = _write(Game.DIFFICULTY_NAMES[_difficulty + 3], 400, 300, 3)
				_step = Step.DIFFICULTY
				_particle_timer.start()
				_emit_particles()
		Step.DIFFICULTY:
			# the original changed the value every 3 frames while the key was held -> key repeat
			if event.is_action_pressed(&"menu_left", true) and _difficulty > -3:
				_difficulty -= 1
				_difficulty_label.set_value(Game.DIFFICULTY_NAMES[_difficulty + 3])
			elif event.is_action_pressed(&"menu_right", true) and _difficulty < 3:
				_difficulty += 1
				_difficulty_label.set_value(Game.DIFFICULTY_NAMES[_difficulty + 3])
			elif event.is_action_pressed(&"menu_confirm"):
				_particle_timer.stop()
				Game.start_new_game(_difficulty)
		Step.LOAD:
			var slot := Game.slot_for_event(event)
			if slot > 0:
				if Game.load_slot(slot):
					Game.start_loaded_game()
				else:
					_show_message("Kein Spielstand in Platz %d" % slot)


## New: sets 3 and 4 are the user slots saved in Castedit; a slot it has not saved cannot be chosen.
func _slots_text() -> String:
	var parts := PackedStringArray()
	for n in [3, 4]:
		parts.append("%d - %s" % [n, "Castedit-Level" if Game.has_levelset(n) else "nicht vorhanden"])
	return "    ".join(parts)


## DIV: every 3 frames of the difficulty loop, particles fly out of the text.
func _emit_particles() -> void:
	var d := _difficulty
	_spawn_effect(400, 300, randi_range(-180000, 180000), randi_range(0, 1) * 10000 - 5000 - d * 500, 100 + (d + 3) * 20)
	if d > -1:
		_spawn_effect(randi_range(0, 800), 600, randi_range(0, 180000), randi_range(0, 1) * 10000 - 5000 - d * 500, 40 + (d + 3) * 20)
	if d > 2:
		_spawn_effect(randi_range(0, 800), 0, randi_range(-180000, 0), randi_range(0, 1) * 10000 - 5000 - d * 500, 40 + (d + 3) * 20)


func _spawn_effect(px: int, py: int, angle: int, angle_step: int, size_pct: int) -> void:
	var e := SPEC_EFFECT_SCENE.instantiate() as SpecEffect
	e.setup(px, py, angle, angle_step, size_pct)
	add_child(e)


## New: the DIV program would try to load a missing file; here we just tell the player.
func _show_message(text: String) -> void:
	if _message == null:
		_message = _write(text, 400, 340, 4)
	else:
		_message.set_value(text)
		_message.anchor = Vector2(400, 340)
		_message._reposition()
