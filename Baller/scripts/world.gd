class_name World
extends Node2D
## One level being played (DIV main code after set_mode): level picture, tuning from its pixels,
## time counter, result texts. Time counts physics ticks (frames at 40 fps) like the original.

var level_info: Dictionary
var level: LevelMap
var time := 0            # DIV: Time (frames)
var result := ""         # "", "You WIN!" or "You LOOSE"

@onready var ball: Ball = $Ball
@onready var guide: GuideBall = $GuideBall
@onready var time_label: PixelLabel = $Hud/TimeLabel
@onready var best_label: PixelLabel = $Hud/BestLabel
@onready var result_label: PixelLabel = $Hud/ResultLabel
@onready var hint_label: PixelLabel = $Hud/HintLabel


func _ready() -> void:
	level_info = Game.LEVELS[Game.selected_level]
	var size: Vector2i = level_info["size"]
	var start: Vector2i = level_info["start"]
	level = LevelMap.load_level(level_info["code"], size.x, size.y)
	($Level as Sprite2D).texture = load("res://assets/fpg/baller/%d.png" % level_info["code"])
	guide.setup(start, size, level)
	ball.setup(start, level, guide)
	ball.finished.connect(_on_ball_finished)
	ball.recalled.connect(_on_ball_recalled)
	_refresh_hud()


func _physics_process(_delta: float) -> void:
	if result.is_empty():
		time += 1
	_refresh_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		Game.show_menu()
	elif not result.is_empty() and event.is_action_pressed(&"ui_accept"):
		Game.start_level(Game.selected_level)


func _refresh_hud() -> void:
	time_label.set_value(str(time))
	best_label.set_value(str(Game.hi_time(level_info["code"])))


func _on_ball_recalled() -> void:
	time += 24  # DIV: Time+=24


func _on_ball_finished(won: bool) -> void:
	if won:
		result = "You WIN!"
		Game.submit_time(level_info["code"], time)
	else:
		result = "You LOOSE"  # sic, the original's text
	result_label.set_value(result)
	hint_label.visible = true
	_refresh_hud()
