class_name Hud
extends CanvasLayer
## Status display. DIV only wrote three numbers per fighter with write_int (SLZ at y=100, life at
## y=125, mana at y=440, x=100 / x=540); they are kept at those spots, with life and mana bars added.

const LIFE_BAR := Rect2(20, 20, 280, 14)
const MANA_BAR := Rect2(20, 456, 280, 8)

var _fighters: Array[Fighter] = []
var _stun_labels: Array[PixelLabel] = []
var _life_labels: Array[PixelLabel] = []
var _mana_labels: Array[PixelLabel] = []
var _banner: PixelLabel
var _hint: PixelLabel
var _bars: Control


func bind(first: Fighter, second: Fighter) -> void:
	_fighters = [first, second]
	_bars = Control.new()
	_bars.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bars.draw.connect(_draw_bars)
	add_child(_bars)
	var columns := [100.0, 540.0]
	for i in 2:
		var who := "PLAYER %d  %s  (%s)" % [i + 1, Defs.CHARACTER_NAMES[Game.characters[i]],
			"CPU" if Game.is_cpu[i] else "HUMAN"]
		var name_x := 20.0 if i == 0 else 620.0
		PixelLabel.make(self, who, Vector2(name_x, 8), 0 if i == 0 else 2)
		_stun_labels.append(PixelLabel.make(self, "0", Vector2(columns[i], 100), 4))
		_life_labels.append(PixelLabel.make(self, "0", Vector2(columns[i], 125), 4, 2))
		_mana_labels.append(PixelLabel.make(self, "0", Vector2(columns[i], 440), 4, 2))
	PixelLabel.make(self, "STUN", Vector2(100, 90), 4)
	PixelLabel.make(self, "STUN", Vector2(540, 90), 4)
	_banner = PixelLabel.make(self, "", Vector2(320, 200), 4, 5)
	_hint = PixelLabel.make(self, "", Vector2(320, 250), 4, 2)


func show_banner(text: String) -> void:
	_banner.set_value(text)
	_hint.set_value("ENTER = REMATCH     ESC = MENU")


func _process(_delta: float) -> void:
	if _fighters.is_empty():
		return
	for i in 2:
		_stun_labels[i].set_value(str(_fighters[i].slz))
		_life_labels[i].set_value(str(_fighters[i].life))
		_mana_labels[i].set_value(str(_fighters[i].mana))
	_bars.queue_redraw()


func _draw_bars() -> void:
	for i in 2:
		var f := _fighters[i]
		var life_ratio := clampf(float(f.life) / Defs.START_LIFE, 0.0, 1.0)
		var mana_ratio := clampf(float(f.mana) / Defs.MAX_MANA, 0.0, 1.0)
		var life_rect := LIFE_BAR
		var mana_rect := MANA_BAR
		if i == 1:
			life_rect.position.x = 640.0 - LIFE_BAR.position.x - LIFE_BAR.size.x
			mana_rect.position.x = 640.0 - MANA_BAR.position.x - MANA_BAR.size.x
		_draw_bar(life_rect, life_ratio, Color(0.9, 0.2, 0.15), i == 1)
		var mana_color := Color(0.25, 0.55, 1.0) if f.mana >= 0 else Color(0.5, 0.2, 0.6)
		_draw_bar(mana_rect, mana_ratio, mana_color, i == 1)


func _draw_bar(rect: Rect2, ratio: float, color: Color, from_right: bool) -> void:
	_bars.draw_rect(rect, Color(0.12, 0.12, 0.12))
	var fill := rect
	fill.size.x = rect.size.x * ratio
	if from_right:
		fill.position.x = rect.end.x - fill.size.x
	_bars.draw_rect(fill, color)
	_bars.draw_rect(rect, Color(0.8, 0.8, 0.8), false)
