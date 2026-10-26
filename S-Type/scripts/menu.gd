extends Node2D
## Start menu (DIV: the first part of the main code). Up/Down select a line, Left/Right change it,
## Enter / Space / Esc starts the game.

const ROW_Y := [0, 15, 30, 45, 60]
const TEXTS := [
	"Spielerzahl:1-4",
	"Gemeinsame Leben:0=nein 1=ja",
	"Graphikstufe:1-3",
	"Spieler 4 Joystick?:0=nein 1=ja",
	"Passive Waffen beim Tod weg?               0=nein 1=ja(bei 'nein' erfolgt schwaechung der Waffen)",
]
const HELP := [
	"P1: arrows, Ctrl=fire, Right Shift=buy, Enter=change weapon, 1-4=choose weapon",
	"P2: Z C S X, A=fire, W=buy, Q=change weapon",
	"P3: J L I K, H=fire, U=buy, Y=change weapon",
	"P4: V N G B, F=fire, T=buy, R=change weapon",
	"Collect money, buy upgrades with the buy key while the cursor in the top bar is on them.",
	"Esc in game: back to this menu",
]

var _cursor := 0
var _values: Array[PixelLabel] = []
var _pointer: Sprite2D


func _ready() -> void:
	for i in TEXTS.size():
		PixelLabel.make(self, 0, 0, ROW_Y[i], 0, TEXTS[i])
		_values.append(PixelLabel.make(self, 0, 200, ROW_Y[i], 0, ""))
	for i in HELP.size():
		PixelLabel.make(self, 0, 0, 120 + i * 15, 0, HELP[i])
	_pointer = Sprite2D.new()
	Gfx.apply(_pointer, 1)
	add_child(_pointer)
	_refresh()
	if Game.autotest:
		Game.player_count = 4
		Game.start_game.call_deferred()


func _row_value(i: int) -> int:
	match i:
		0: return Game.player_count
		1: return Game.shared_lives
		2: return Game.graphics_level
		3: return Game.joystick4
		_: return Game.passive_loss


func _refresh() -> void:
	for i in _values.size():
		_values[i].set_value(str(_row_value(i)))
	# pointer ship next to the selected line (DIV: x=190, y moves 15 per line)
	_pointer.position = Vector2(190, ROW_Y[_cursor])
	_pointer.reset_physics_interpolation()  # jump to the line, don't slide there


func _change(dir: int) -> void:
	match _cursor:
		0: Game.player_count = clampi(Game.player_count + dir, 1, 4)
		1: Game.shared_lives = clampi(Game.shared_lives + dir, 0, 1)
		2: Game.graphics_level = clampi(Game.graphics_level + dir, 0, 3)
		3: Game.joystick4 = clampi(Game.joystick4 + dir, 0, 1)
		4: Game.passive_loss = clampi(Game.passive_loss + dir, 0, 1)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_down"):
		_cursor = mini(_cursor + 1, TEXTS.size() - 1)
		_refresh()
	elif event.is_action_pressed(&"ui_up"):
		_cursor = maxi(_cursor - 1, 0)
		_refresh()
	elif event.is_action_pressed(&"ui_left"):
		_change(-1)
	elif event.is_action_pressed(&"ui_right"):
		_change(1)
	elif event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel"):
		Game.start_game()
