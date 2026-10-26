class_name Pickup
extends Node2D
## DIV: PROCESS Potion(graph,Healpower,x,y) - every collectible lying in a room:
## potions (60/61 life, 63/64 mana), arrows (66/67), shield (69), save point (72), all-healer (74),
## scrolls (75 flame, 76 ice, 77 heal), skill books (78 sword, 79 bow, 80 magic), keys (127 gold, 128 silver).
## Picking one up removes it from the map object layer so it does not come back.

var graph: int = 60
var power: int = 1
var ix: int = 0
var iy: int = 0
var inix: int = 0
var iniy: int = 0

@onready var _sprite: Sprite2D = $Sprite


func setup(p_graph: int, p_power: int, px: int, py: int) -> void:
	graph = p_graph
	power = p_power
	ix = px
	iy = py


func _ready() -> void:
	inix = (ix - 10) / 20
	iniy = (iy - 10) / 20
	Gfx.apply(_sprite, graph)
	position = Vector2(ix, iy)
	add_to_group(&"pickups")


func _physics_process(_delta: float) -> void:
	var hero := Game.hero
	if hero == null or not is_instance_valid(hero):
		return
	if not Gfx.overlap(graph, ix, iy, hero.graph, hero.ix, hero.iy):   # DIV: collision(TYPE Hero)
		return
	var st := Game.stat
	if graph == 60 and st.life < st.max_life:
		st.life += power
		_consume()
		return
	if graph == 61 and st.life < st.max_life:
		st.life += st.max_life * power / 100
		_consume()
		return
	if graph == 63 and st.mana < st.max_mana:
		st.mana += power
		_consume()
		return
	if graph == 64 and st.mana < st.max_mana:
		st.mana += st.max_mana * power / 100
		_consume()
		return
	if graph == 66 or graph == 67:
		st.arrows += power
		_consume()
		return
	if graph == 69:
		st.defense += 1
		_consume()
		return
	if graph == 74:
		st.mana = st.max_mana
		st.life = st.max_life
		_consume()
		return
	if graph == 75:
		st.flame_learned += 1
		_consume()
		return
	if graph == 76:
		st.ice_learned += 1
		_consume()
		return
	if graph == 77:
		st.heal_learned += 1
		_consume()
		return
	if graph == 78:
		st.strength += 2
		_consume()
		return
	if graph == 79:
		st.bow += 2
		_consume()
		return
	if graph == 80:
		st.magic += 2
		_consume()
		return
	if graph == 127:
		st.gold_keys += 1
		_consume()
		return
	if graph == 128:
		st.silver_keys += 1
		_consume()
		return


## Save point: Ctrl+1..4 (or F1..F4) while standing on it.
func _unhandled_input(event: InputEvent) -> void:
	if graph != 72 or not is_inside_tree():
		return
	var hero := Game.hero
	if hero == null or not is_instance_valid(hero) or not Gfx.overlap(graph, ix, iy, hero.graph, hero.ix, hero.iy):
		return
	var slot := Game.save_slot_for_event(event)
	if slot > 0:
		Game.save_slot(slot, hero.ix, hero.iy)   # saved before the point is used up, like the original
		get_viewport().set_input_as_handled()
		_consume()


func _consume() -> void:
	Game.set_cell(1, inix, iniy, 0)
	remove_from_group(&"pickups")
	queue_free()
