extends Node2D
## The DIV main program as a small state machine: intro, rules, the option screens, the round
## and the exit screen. Each state builds its texts when entered and reacts to input through
## `_unhandled_input` (InputMap actions; `echo` = key repeat for the value selectors).
##
## In-game texts are the original German ones (ATOMS.PRG), drawn with the converted Atoms font.

enum State {
	INTRO,          # title texts for 72/18 s, input ignored (DIV: FRAME(7200))
	INTRO_MENU,     # "Weiter mit: ENTER / Regeln mit: H"
	RULES_PICTURE,
	RULES_KEYS,
	MODE,           # 1 easy / 2 hard, Esc quits
	QUAD,
	SIZE,
	GIVEN_ATOMS,
	BOMBS,
	BOMB_NEED,
	CON_INFO,
	ROUND,
	THANKS,
}

const INTRO_TIME := 72.0 / 18.0      # DIV: FRAME(7200) at 18 fps
const THANKS_TIME := 3.0

@onready var _board_view: BoardView = $Board
@onready var _cursor: AtomCursor = $Cursor
@onready var _rules: Sprite2D = $Rules
@onready var _texts: CanvasLayer = $Texts

var _state := State.INTRO


func _ready() -> void:
	_board_view.hide()
	_rules.hide()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(preload("res://scripts/debug/autotest.gd").new())
	_enter(State.INTRO)


func current_state() -> State:
	return _state


# --- state machine ----------------------------------------------------------------------------

func _enter(state: State) -> void:
	_state = state
	_delete_texts()
	match state:
		State.INTRO:
			_show_intro_texts()
			get_tree().create_timer(INTRO_TIME).timeout.connect(_on_intro_timeout)
		State.INTRO_MENU:
			_show_intro_texts()
			_write(320, 380, 4, "Weiter mit: ENTER")
			_write(320, 440, 4, "Regeln mit: H")
		State.RULES_PICTURE:
			_rules.show()                      # graphic 4 "Regeln" (German rules text)
		State.RULES_KEYS:
			_rules.hide()
			_write(5, 5, 0, "Richtungspfeile:")
			_write(5, 55, 0, "    Cursor bewegen")
			_write(5, 105, 0, "Enter:")
			_write(5, 155, 0, "    Atom setzen")
			_write(5, 205, 0, "BackSpace:")
			_write(5, 255, 0, "    Bombe benutzen")
			_write(5, 305, 0, "ESC:")
			_write(5, 355, 0, "    Neue Runde")
		State.MODE:
			_write(320, 60, 4, "Modus waehlen")
			_write(320, 150, 4, "1-Leicht")
			_write(320, 200, 4, "Wand zaehlt als Bindung")
			_write(320, 232, 4, "Rekord: %d" % Game.hi_easy, PixelLabel.FontKind.SYSTEM)  # added
			_write(320, 280, 4, "2-Schwer")
			_write(320, 330, 4, "Wand zaehlt nicht als Bindung")
			_write(320, 362, 4, "Rekord: %d" % Game.hi_hard, PixelLabel.FontKind.SYSTEM)  # added
			_write(320, 455, 4, "ESC-Beenden")
		State.QUAD:
			_write(320, 60, 4, "Anzahl der 4er-Atome")
			_write(320, 150, 4, "1-Normal")
			_write(320, 200, 4, "4er tauchen normal auf")
			_write(320, 280, 4, "2-Seltener")
			_write(320, 330, 4, "4er tauchen seltener auf")
		State.SIZE:
			Game.points = 0
			Game.field = 5
			_value_screen("Groesse waehlen", func() -> int: return Game.field)
		State.GIVEN_ATOMS:
			_value_screen("Vorgegebene Atome waehlen", func() -> int: return Game.given_atoms)
		State.BOMBS:
			Game.bombs = 0
			Game.bombs_supply = 0
			_value_screen("Vorgegebene Bomben waehlen", func() -> int: return Game.bombs)
		State.BOMB_NEED:
			Game.bomb_need = 100
			_value_screen("Benoetigte Punkte fuer Bombe", func() -> int: return Game.bomb_need)
		State.CON_INFO:
			Game.con_info = 0
			_value_screen("Angezeigte Atome waehlen", func() -> int: return Game.con_info)
		State.ROUND:
			_start_round()
		State.THANKS:
			# DIV: Exit("Thanks! Your Score:", Points)
			Game.submit_score()
			_write(320, 190, 4, "Thanks! Your Score:")
			_write_value(320, 270, 4, func() -> int: return Game.points)
			get_tree().create_timer(THANKS_TIME).timeout.connect(_on_thanks_timeout)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	match _state:
		State.INTRO_MENU:
			if event.is_action_pressed(&"confirm"):
				_enter(State.MODE)
			elif event.is_action_pressed(&"rules"):
				_enter(State.RULES_PICTURE)
		State.RULES_PICTURE:
			if event.is_action_pressed(&"confirm"):
				_enter(State.RULES_KEYS)
		State.RULES_KEYS:
			if event.is_action_pressed(&"confirm"):
				_enter(State.MODE)
		State.MODE:
			if event.is_action_pressed(&"choice_1"):
				Game.mode = 0
				_enter(State.QUAD)
			elif event.is_action_pressed(&"choice_2"):
				Game.mode = 1
				_enter(State.QUAD)
			elif event.is_action_pressed(&"new_round"):
				_enter(State.THANKS)
		State.QUAD:
			if event.is_action_pressed(&"choice_1"):
				Game.quad = 0
				_enter(State.SIZE)
			elif event.is_action_pressed(&"choice_2"):
				Game.quad = 1
				_enter(State.SIZE)
		State.SIZE, State.GIVEN_ATOMS, State.BOMBS, State.BOMB_NEED, State.CON_INFO:
			_handle_value_input(event)
		State.ROUND:
			if event.is_action_pressed(&"new_round"):
				_end_round()


func _on_intro_timeout() -> void:
	if _state == State.INTRO:
		_enter(State.INTRO_MENU)


func _on_thanks_timeout() -> void:
	if _state != State.THANKS:
		return
	if OS.has_feature("web"):
		_enter(State.INTRO)      # a browser page cannot quit
	else:
		get_tree().quit()


# --- option screens with a "< value >" selector -------------------------------------------------

func _handle_value_input(event: InputEvent) -> void:
	var step := 0
	if event.is_action_pressed(&"left", true):
		step = -1
	elif event.is_action_pressed(&"right", true):
		step = 1
	if step != 0:
		_change_value(step)
	elif event.is_action_pressed(&"confirm"):
		_confirm_value()


func _change_value(step: int) -> void:
	match _state:
		State.SIZE:                     # 2..8
			Game.field = clampi(Game.field + step, 2, 8)
		State.GIVEN_ATOMS:
			var limit := (Game.field + 1) * (Game.field + 1) - 1 if Game.mode == 0 \
					else (Game.field - 1) * (Game.field - 1)
			Game.given_atoms = clampi(Game.given_atoms + step, 0, maxi(limit, 0))
		State.BOMBS:
			Game.bombs = clampi(Game.bombs + step, 0, 20)
		State.BOMB_NEED:
			Game.bomb_need = clampi(Game.bomb_need + step * 5, 5, 500)
		State.CON_INFO:
			Game.con_info = clampi(Game.con_info + step, 0, 10)


func _confirm_value() -> void:
	match _state:
		State.SIZE:
			Game.field -= 1             # stored as index of the last row/column
			_enter(State.GIVEN_ATOMS)
		State.GIVEN_ATOMS:
			Game.place_given_atoms()
			_enter(State.BOMBS)
		State.BOMBS:
			_enter(State.BOMB_NEED)
		State.BOMB_NEED:
			_enter(State.CON_INFO)
		State.CON_INFO:
			_enter(State.ROUND)


func _value_screen(title: String, getter: Callable) -> void:
	_write(320, 60, 4, title)
	_write_value(320, 200, 4, getter)
	_write(320, 200, 4, "<        >")


# --- the round --------------------------------------------------------------------------------

func _start_round() -> void:
	_board_view.show()
	_cursor.start()
	for i in Game.con_info + 1:
		Game.connections[i] = Game.random_connections()
	_write_value(283, 40, 3, func() -> int: return Game.connections[0])
	for i in range(1, Game.con_info + 1):
		_write_value(313 + i * 30, 40, 3, func() -> int: return Game.connections[i])
	_write_value(90, 170, 4, func() -> int: return Game.points)
	_write(90, 220, 4, "Bombs:")
	_write_value(90, 270, 4, func() -> int: return Game.bombs)
	_write(5, 480, 6, "Leicht" if Game.mode == 0 else "Schwer")


func _end_round() -> void:
	Game.submit_score()        # added: the original has this commented out
	Game.reset_round_board()
	_cursor.stop()
	_board_view.hide()
	_enter(State.MODE)


# --- text helpers -----------------------------------------------------------------------------

func _show_intro_texts() -> void:
	_write(360, 40, 4, "*** ATOME ***")
	_write(360, 40, 4, "_____")
	_write(200, 120, 4, "Ein Spiel von:")
	_write(200, 180, 4, "OLEG YUSCHUK")
	_write(200, 180, 4, "____________")
	_write(400, 260, 4, "Erstellt mit dem:")
	_write(400, 320, 4, "DIV GAME MAKER")
	_write(400, 320, 4, "______________")


## DIV: write(font, x, y, align, "text")
func _write(x: int, y: int, align: int, text: String, kind := PixelLabel.FontKind.ATOMS) -> PixelLabel:
	var label := PixelLabel.new()
	label.font_kind = kind
	label.align_code = align
	label.text = text
	label.position = Vector2(x, y)
	_texts.add_child(label)
	return label


## DIV: write_int(font, x, y, align, OFFSET var) - follows the value.
func _write_value(x: int, y: int, align: int, getter: Callable) -> PixelLabel:
	var label := PixelLabel.new()
	label.align_code = align
	label.getter = getter
	label.position = Vector2(x, y)
	_texts.add_child(label)
	return label


## DIV: delete_text(all_text)
func _delete_texts() -> void:
	for child in _texts.get_children():
		child.queue_free()
