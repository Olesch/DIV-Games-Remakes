class_name Arena
extends Node2D
## The fight (DIV: main code after the menu: creates both Fighters and the Dontmove counter).
## Added to the DIV original: the round ends when a fighter's life reaches 0 (the original just
## kept fighting with negative life), with a rematch / back-to-menu prompt.

const FIGHTER_SCENE := preload("res://scenes/fighter.tscn")

@onready var hud: Hud = $Hud

var fighters: Array[Fighter] = []
var round_over: bool = false


func _ready() -> void:
	Game.hit_pause = 0
	# DIV: the DontMovePlus process ran with priority -100, i.e. after the fighters.
	process_physics_priority = 100
	var same_character: bool = Game.characters[0] == Game.characters[1]
	for i in 2:
		var fighter := FIGHTER_SCENE.instantiate() as Fighter
		fighter.setup(i + 1, Game.characters[i], Game.is_cpu[i], same_character)
		add_child(fighter)
		fighters.append(fighter)
	fighters[0].opponent = fighters[1]
	fighters[1].opponent = fighters[0]
	hud.bind(fighters[0], fighters[1])
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _physics_process(_delta: float) -> void:
	if Game.hit_pause > 0:
		Game.hit_pause -= 1
	if not round_over:
		_check_knockout()


func _check_knockout() -> void:
	var life_1 := fighters[0].life
	var life_2 := fighters[1].life
	if life_1 > 0 and life_2 > 0:
		return
	round_over = true
	for fighter in fighters:
		fighter.locked = true
	if life_1 <= 0 and life_2 <= 0:
		hud.show_banner("DOUBLE K.O.")
	elif life_1 <= 0:
		hud.show_banner("PLAYER 2 WINS")
	else:
		hud.show_banner("PLAYER 1 WINS")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	elif round_over and event.is_action_pressed(&"ui_accept"):
		get_tree().reload_current_scene()
