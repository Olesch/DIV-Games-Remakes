extends Node2D
## Main scene: background + two player bunnies, plus Game.extra_bunnies computer bunnies (the
## original's commented-out FROM loop). Esc goes back to the options screen. Only adds the debug
## autotest when started with `-- --autotest`.

const BUNNY_SCENE := preload("res://scenes/bunny.tscn")


func _ready() -> void:
	_spawn_extra_bunnies()
	if "--autotest" in OS.get_cmdline_user_args():
		var test := AutoTest.new()
		test.name = "AutoTest"
		add_child(test)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/options.tscn")


## Commented out in the original: FROM x=0 TO 10; Bunny(rand(100,924),rand(100,668)); END.
## Those bunnies get no keys, so they only fall, land, bounce and are bumped into. The loop ran
## before the two player bunnies were created, so they go before them (they act first each frame).
func _spawn_extra_bunnies() -> void:
	var first_player := $Bunny1.get_index()
	for i in Game.extra_bunnies:
		var bunny := BUNNY_SCENE.instantiate() as Bunny
		bunny.name = "Extra%d" % (i + 1)
		bunny.action_prefix = ""
		bunny.start = Vector2i(randi_range(100, 924), randi_range(100, 668))
		add_child(bunny)
		move_child(bunny, first_player + i)
