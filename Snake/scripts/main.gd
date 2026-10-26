extends Node2D
## Main code of the original: sets up the screen, spawns apples (one at a time) and restarts the worm
## after a crash (fade off / fade on).

const APPLE_SCENE := preload("res://scenes/apple.tscn")
const FADE_TIME := 0.4   # DIV fade_off()/fade_on(): roughly 8 frames at 20 fps

@onready var _field: Node2D = $Field
@onready var _worm: Worm = $Field/Worm
@onready var _apples: Node2D = $Field/Apples
@onready var _score_label: PixelLabel = $Field/Score
@onready var _topscore_label: PixelLabel = $Field/TopScore
@onready var _fade: ColorRect = $Fade/Black

var _fading := false


func _ready() -> void:
	_field.position = Vector2(Game.field_origin())
	_score_label.set_value(Game.score)
	_topscore_label.set_value(Game.topscore)
	Game.score_changed.connect(_score_label.set_value)
	Game.topscore_changed.connect(_topscore_label.set_value)
	_worm.crashed.connect(_on_worm_crashed)
	_worm.active = true
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(preload("res://scripts/debug/autotest.gd").new())


func _physics_process(_delta: float) -> void:
	if _fading:
		return
	if Game.apples < 1:
		var apple := APPLE_SCENE.instantiate() as Apple
		apple.position = Vector2(randi_range(1, 38) * 8, randi_range(3, 23) * 8)
		_apples.add_child(apple)
		Game.apples += 1
	_worm.step()


func _on_worm_crashed() -> void:
	_fading = true
	_worm.active = false
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, FADE_TIME)
	tween.tween_property(_fade, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_restart)


func _restart() -> void:
	Game.reset_round()
	_worm.reset()
	_worm.active = true
	_fading = false
