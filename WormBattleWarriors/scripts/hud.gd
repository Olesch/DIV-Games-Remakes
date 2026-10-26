class_name Hud
extends CanvasLayer
## Status line of the unit under the cursor ("LP: 50/50   AP: 5/5", DIV: Write/Write_Int with font 1),
## plus a small turn indicator and the game-over banner (both added).

const BIG_FONT := "res://assets/fnt/undworld/font_bmfont.fnt"
const SMALL_FONT := "res://assets/fnt/system/font_bmfont.fnt"

var _life: Label
var _life_max: Label
var _ap: Label
var _ap_max: Label
var _turn: Label
var _banner: Label
var _banner_hint: Label


func _ready() -> void:
	# anchors as in the original: texts at x 0, numbers right-aligned at 100 / 262, maxima left at 120 / 282
	_label("LP:", Vector2(0, 0), 0)
	_label("/", Vector2(100, 0), 0)
	_label("AP:", Vector2(192, 0), 0)
	_label("/", Vector2(262, 0), 0)
	_life = _label("0", Vector2(100, 0), 2)
	_life_max = _label("0", Vector2(120, 0), 0)
	_ap = _label("0", Vector2(262, 0), 2)
	_ap_max = _label("0", Vector2(282, 0), 0)
	_turn = _label("", Vector2(2, 231), 0, true)
	_banner = _label("", Vector2(160, 100), 1)
	_banner_hint = _label("", Vector2(160, 140), 1, true)
	Game.cursor_moved.connect(_refresh)
	Game.board_changed.connect(_refresh)
	Game.turn_changed.connect(_refresh)
	Game.game_over.connect(_on_game_over)
	Game.turn_changed.connect(_refresh_banner)
	_refresh()
	_refresh_banner()


func _label(text: String, anchor: Vector2, align: int, small := false) -> Label:
	var l := Label.new()
	l.set_meta(&"anchor", anchor)
	l.set_meta(&"align", align)
	l.add_theme_font_override(&"font", load(SMALL_FONT if small else BIG_FONT))
	l.add_theme_font_size_override(&"font_size", 8 if small else 31)
	l.add_theme_color_override(&"font_color", Color.WHITE)
	l.text = text
	add_child(l)
	_place(l)
	return l


func _place(l: Label) -> void:
	# DIV alignment: 0 = left, 1 = centre, 2 = right of the anchor
	var s := l.get_minimum_size()
	l.size = s
	var a: Vector2 = l.get_meta(&"anchor")
	var align: int = l.get_meta(&"align")
	l.position = (a - Vector2(s.x * align * 0.5, 0.0)).floor()


func _set_text(l: Label, text: String) -> void:
	l.text = text
	_place(l)


func _refresh() -> void:
	var i := Game.idx(Game.cursor_cell)
	_set_text(_life, str(Game.life[i]))
	_set_text(_life_max, str(Game.life_max[i]))
	_set_text(_ap, str(Game.move[i]))
	_set_text(_ap_max, str(Game.move_max[i]))
	_set_text(_turn, "PLAYER %d   SPACE = END TURN" % (Game.player_turn + 1))


func _on_game_over(_winner: int) -> void:
	_refresh_banner()


func _refresh_banner() -> void:
	if Game.finished:
		_set_text(_banner, "PLAYER %d WINS" % (Game.winner + 1))
		_set_text(_banner_hint, "ENTER = NEW GAME")
	else:
		_set_text(_banner, "")
		_set_text(_banner_hint, "")
