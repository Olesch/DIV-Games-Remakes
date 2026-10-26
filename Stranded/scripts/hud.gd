class_name Hud
extends CanvasLayer
## DIV: ShowItems, ShowHunger/Thirst/Health bars, KarteF/KarteO/RadShad (radar), PunktM, TimeSun sprite.
## Text is drawn with PixelLabel (DIV write / write_int with the system font).

const FPG := "res://assets/fpg/stranded/%d.png"
const RADAR_TOP_LEFT := Vector2(550, 350)   # radar graphic centred at (675, 475), 250x250
const ITEM_ROWS := [  # [key text, label, getter name, DIV y]
	["1-Getreide:", &"grain", 10], ["2-Beeren:", &"berries", 20], ["3-Ast:", &"branch", 30],
	["4-Stein:", &"stone", 40], ["5-Blatt:", &"leaf", 50], ["6-Liane:", &"vine", 60],
	["7-Heilkraut:", &"herb", 70],
]

@onready var radar: Sprite2D = $Radar
@onready var hero_dot: ColorRect = $HeroDot
@onready var sun: Sprite2D = $Sun
@onready var bar_hunger: Sprite2D = $BarHunger
@onready var bar_thirst: Sprite2D = $BarThirst
@onready var bar_health: Sprite2D = $BarHealth
@onready var arrow: PixelLabel = $Arrow
@onready var popups: Control = $Popups
@onready var lists: Control = $Lists

var _value_labels: Dictionary = {}     # property name -> PixelLabel
var _flour_row: Array[PixelLabel] = []
var _dough_row: Array[PixelLabel] = []
var _tool_labels: Dictionary = {}


func _ready() -> void:
	radar.texture = Game.island.radar_texture
	for row: Array in ITEM_ROWS:
		_add_row(row[0], row[1], row[2])
	for text in [["V-Essen", 10], ["B-Benutzen", 20], ["G-Kombinieren", 30],
			["D-Suchen", 50], ["F-Aufnehmen", 60], ["A-Schlafen", 70]]:
		_add_label(text[0], Vector2(720, text[1]), lists)
	Game.inventory_changed.connect(_refresh_items)
	Game.stats_changed.connect(_refresh_bars)
	Game.mode_changed.connect(_refresh_arrow)
	Game.clock_changed.connect(_refresh_sun)
	Game.message.connect(_show_message)
	_refresh_items()
	_refresh_bars()
	_refresh_arrow()
	_refresh_sun()


func _process(_delta: float) -> void:
	var cell := Game.hero_cell
	hero_dot.position = RADAR_TOP_LEFT + Vector2(cell) - Vector2(1, 1)


func _add_label(text: String, anchor: Vector2, parent: Node, align: int = 6) -> PixelLabel:
	var label := PixelLabel.new()
	label.align_code = align
	label.position = anchor
	label.text = text
	parent.add_child(label)
	return label


func _add_row(caption: String, property: StringName, y: int, parent: Node = lists) -> Array[PixelLabel]:
	var name_label := _add_label(caption, Vector2(0, y), parent)
	var value_label := _add_label("0", Vector2(80, y), parent)
	_value_labels[property] = value_label
	return [name_label, value_label]


func _refresh_items() -> void:
	for property: StringName in _value_labels:
		(_value_labels[property] as PixelLabel).set_value(str(Game.get(property)))
	# rows that appear once first discovered (DIV: MehlTex, TeigTex, Axt, Angel, Hammer)
	if Game.flour_listed and _flour_row.is_empty():
		_flour_row = _add_row("8-Mehl:", &"flour", 80)
		(_value_labels[&"flour"] as PixelLabel).set_value(str(Game.flour))
	if Game.dough_listed and _dough_row.is_empty():
		_dough_row = _add_row("9-Teig:", &"dough", 90)
		(_value_labels[&"dough"] as PixelLabel).set_value(str(Game.dough))
	if Game.flour_listed and _value_labels.has(&"flour"):
		(_value_labels[&"flour"] as PixelLabel).set_value(str(Game.flour))
	if Game.dough_listed and _value_labels.has(&"dough"):
		(_value_labels[&"dough"] as PixelLabel).set_value(str(Game.dough))
	_tool_row(&"axe", "H-Axt", 90, Game.axe)
	_tool_row(&"rod", "N-Angel", 100, Game.rod)
	_tool_row(&"hammer", "J-Bauen", 110, Game.hammer)


func _tool_row(key: StringName, text: String, y: int, value: int) -> void:
	if value >= 1 and not _tool_labels.has(key):
		_tool_labels[key] = _add_label(text, Vector2(720, y), lists)


func _refresh_bars() -> void:
	# the bar slides in from the left: x = value - 100 (control point at the bottom-left corner)
	bar_hunger.position.x = Game.hunger - 100
	bar_thirst.position.x = Game.thirst - 100
	bar_health.position.x = Game.health - 100


func _refresh_arrow() -> void:
	arrow.set_anchor_point(Vector2(700, 10 * int(Game.mode)))


func _refresh_sun() -> void:
	sun.position.x = Game.sun_x


func _show_message(text: String, y: int) -> void:
	if text.strip_edges() == "":
		return
	var label := PixelLabel.new()
	label.align_code = 7
	label.position = Vector2(400, y)
	label.text = text
	popups.add_child(label)
	get_tree().create_timer(Game.MESSAGE_SECONDS).timeout.connect(label.queue_free)
