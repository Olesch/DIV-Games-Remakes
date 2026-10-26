extends CanvasLayer
## DIV: Fade_Off() / Refresh_all() / FRAME(3000) / Fade_On() while NachtStop = 1 (the "night").
## A black overlay; the fades are assumed to take about 8 frames each (see PORTING_NOTES).

const FPS := 24.0   # DIV: set_fps(24, 0)
const FADE_SECONDS := 8.0 / FPS
const NIGHT_SECONDS := 30.0 / FPS

@onready var cover: ColorRect = $Cover


func _ready() -> void:
	cover.color = Color(0, 0, 0, 0)
	Game.night_fell.connect(_on_night_fell)


func _on_night_fell() -> void:
	var tween := create_tween()
	tween.tween_property(cover, "color:a", 1.0, FADE_SECONDS)
	tween.tween_callback(Game.island.refresh_all)
	tween.tween_interval(NIGHT_SECONDS)
	tween.tween_property(cover, "color:a", 0.0, FADE_SECONDS)
	tween.tween_callback(Game.end_night)
