extends Node2D
## The match: level, four ships, diamond, items.  Esc quits (DIV: exit("May the force be with you!")).

const SHIP_SCENE := preload("res://scenes/ship.tscn")
const SHOT_SCENE := preload("res://scenes/shot.tscn")
const PICKUP_SCENE := preload("res://scenes/pickup.tscn")

@onready var _level_sprite: Sprite2D = $Level
@onready var _ships: Node2D = $Ships
@onready var _items: Node2D = $Items
@onready var _shots: Node2D = $Shots


func _ready() -> void:
	Game.reset_stats()
	_level_sprite.texture = Game.tex(Game.LEVEL_CODE)
	for p in Game.PLAYERS:
		var ship := SHIP_SCENE.instantiate() as Ship
		ship.setup(p)
		ship.shot_requested.connect(_on_shot_requested)
		_ships.add_child(ship)
	for n in range(Game.POINT_ITEM_FIRST, Game.POINT_ITEM_LAST + 1):
		var at := Game.level.get_point(n)
		if at.x < 0 or at.y < 0 or at.x > 640 or at.y > 440:   # undefined points: no item
			continue
		var item := PICKUP_SCENE.instantiate() as Pickup
		item.setup(n, at)
		_items.add_child(item)
	if "--autotest" in OS.get_cmdline_user_args():
		var test := AutoTest.new()
		test.main = self
		add_child(test)


func get_ships() -> Array[Ship]:
	var result: Array[Ship] = []
	for s in Game.stats:
		result.append(s.ship)
	return result


func _on_shot_requested(ship: Ship, dir: int, weapon: int) -> void:
	if dir == Ship.Dir.NONE or not Game.SHOTS.has(weapon):
		return
	var shot := SHOT_SCENE.instantiate() as Shot
	_shots.add_child(shot)
	shot.setup(ship, dir, weapon)
	shot.step()   # the original shot already moves in the frame it is created


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()
