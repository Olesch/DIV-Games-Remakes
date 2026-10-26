class_name Hud
extends CanvasLayer
## DIV: the write_int() counters, the Munition icons, floating texts and the final score screen.

const FLOATING_TEXT := preload("res://scenes/floating_text.tscn")
const AMMO_ICONS := 16          # DIV: Munition(0..15)

@onready var score_label: PixelLabel = $Score
@onready var kills_label: PixelLabel = $Kills
@onready var accuracy_label: PixelLabel = $Accuracy
@onready var time_label: PixelLabel = $Time
@onready var combo_label: PixelLabel = $Combo
@onready var popups: Node = $Popups
@onready var ammo_box: Node2D = $AmmoIcons
@onready var game_over: Control = $GameOver
@onready var end_score: PixelLabel = $GameOver/EndScore
@onready var end_details: PixelLabel = $GameOver/Details
@onready var end_hint: PixelLabel = $GameOver/Hint


func _ready() -> void:
	Game.popup.connect(_on_popup)
	for i in AMMO_ICONS:
		var icon := Sprite2D.new()
		Gfx.apply(icon, 5)
		icon.position = Vector2(800 - i * 20, 600)
		icon.name = "Ammo%d" % i
		ammo_box.add_child(icon)
	game_over.hide()


func _process(_delta: float) -> void:
	score_label.set_value(str(Game.score))
	kills_label.set_value(str(Game.birds_killed))
	accuracy_label.set_value(str(Game.accuracy))
	time_label.set_value(str(Game.time))
	combo_label.set_value(str(Game.combo_bar))
	var i := 0
	for icon: Sprite2D in ammo_box.get_children():
		icon.visible = Game.ammo - i > 0     # DIV: graph 5 while AmmoAmount-Number>0
		i += 1


func show_game_over() -> void:
	end_score.set_value(str(Game.final_score))
	end_details.set_value("Birds shot: %d   Accuracy: %d%%" % [Game.birds_killed, Game.accuracy])
	end_hint.set_value("Click to play again")
	game_over.show()


func _on_popup(text: String, screen_pos: Vector2) -> void:
	var label := FLOATING_TEXT.instantiate() as FloatingText
	label.setup(text, screen_pos)
	popups.add_child(label)
	label.reset_physics_interpolation()  # _ready() places it: don't slide in from (0, 0)
