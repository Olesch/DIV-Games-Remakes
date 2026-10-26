class_name Hud
extends CanvasLayer
## Numbers on the skill panel (DIV: write_int(1, ...)) and centre banners (DIV: write(1,160,120,4,"...")).

const SKILL_X0 := 10      # DIV: skill counters at x = 10 + 20*i, y = 209
const SKILL_DX := 20
const ROW1_Y := 209
const ROW2_Y := 234

var _skill_labels: Array[PixelLabel] = []
var _time: PixelLabel
var _emerge: PixelLabel
var _emerge_max: PixelLabel
var _saved: PixelLabel
var _to_save: PixelLabel
var _total: PixelLabel
var _banner: PixelLabel
var _marker: Node2D


func _ready() -> void:
	_marker = Node2D.new()
	_marker.draw.connect(_draw_marker)
	add_child(_marker)
	for i in 9:
		_skill_labels.append(_label(SKILL_X0 + SKILL_DX * i, ROW1_Y))
	_time = _label(250, ROW1_Y)
	_emerge = _label(270, ROW1_Y)
	_emerge_max = _label(290, ROW1_Y)
	_saved = _label(270, ROW2_Y)
	_to_save = _label(290, ROW2_Y)
	_total = _label(310, ROW2_Y)
	_banner = _label(160, 120)
	_banner.hide()
	Game.stats_changed.connect(refresh)
	refresh()


func _label(x: int, y: int) -> PixelLabel:
	var l := PixelLabel.new()
	l.anchor = Vector2(x, y)
	l.align_code = 4
	add_child(l)
	return l


func refresh() -> void:
	for i in 9:
		_skill_labels[i].set_value(str(Game.skill_counts[i + 1]))
	_time.set_value(str(Game.time_left))
	_emerge.set_value(str(Game.emerge_interval))
	_emerge_max.set_value(str(Game.emerge_max))
	_saved.set_value(str(Game.saved))
	_to_save.set_value(str(Game.to_save + 1))        # DIV: Tosaveadd
	_total.set_value(str(Game.lemming_total + 1))    # DIV: Lommingsnumberadd
	_marker.queue_redraw()


func show_banner(text: String) -> void:
	_banner.set_value(text)
	_banner.show()


func hide_banner() -> void:
	_banner.hide()


## Outline around the selected skill (new: the original gave no feedback for the 1-9 keys).
func _draw_marker() -> void:
	if Game.selected_skill == Defs.Skill.NONE:
		return
	var x := (Game.selected_skill - 1) * SKILL_DX
	_marker.draw_rect(Rect2(x, Defs.PANEL_Y, SKILL_DX, 24), Color(1, 1, 0, 1), false)
