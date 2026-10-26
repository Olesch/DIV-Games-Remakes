class_name Hero
extends Node2D
## DIV: process Held. Walks the tile grid one 20 px cell at a time (4 px per frame, 5 frames per
## cell), searches (D), takes (F), eats/uses/combines with the number keys, sleeps (A).
## Input arrives as events; held direction keys are tracked from press/release events.

const WALK_SPEED := 4.0 * 24.0     # DIV: 4 px per frame at 24 fps = 96 px/s
const TILE := Island.TILE_PX
const TEX_ALIVE := preload("res://assets/fpg/stranded/1.png")
const TEX_DEAD := preload("res://assets/fpg/stranded/40.png")
const DIRECTION_ACTIONS: Array[StringName] = [&"move_up", &"move_down", &"move_left", &"move_right"]
const DIRECTIONS := {
	&"move_up": Vector2i(0, -1),   # _s
	&"move_down": Vector2i(0, 1),  # _x
	&"move_left": Vector2i(-1, 0), # _z
	&"move_right": Vector2i(1, 0), # _c
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var search_timer: Timer = $SearchTimer
@onready var combo_timer: Timer = $ComboTimer

var _held_dirs: Array[StringName] = []
var _target := Vector2.ZERO
var _moving := false
var _pos := Vector2.ZERO
var _search_phase := 0
## DIV: AntiFastClick - one action per press; unlocked when F, A and 1..9 are all released.
var _locked := false
var _held_lock_keys: Dictionary = {}    # action -> true while down


func _ready() -> void:
	sprite.texture = TEX_ALIVE   # cp0 = (0, 0): the node position is the top-left of the hero cell
	_pos = Vector2(Game.hero_cell * TILE)
	position = _pos
	search_timer.wait_time = Game.SEARCH_SECONDS
	search_timer.one_shot = true
	search_timer.timeout.connect(_on_search_timer)
	combo_timer.wait_time = 1.0 / Game.FPS
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_evaluate_combination)
	Game.died.connect(_on_died)


func _on_died() -> void:
	sprite.texture = TEX_DEAD


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).echo:
		return
	for action: StringName in DIRECTION_ACTIONS:
		if event.is_action_pressed(action):
			if action not in _held_dirs:
				_held_dirs.append(action)
		elif event.is_action_released(action):
			_held_dirs.erase(action)
	_track_lock_keys(event)
	if event.is_action_pressed(&"mode_eat"):
		Game.mode = Game.Mode.EAT
	elif event.is_action_pressed(&"mode_use"):
		Game.mode = Game.Mode.USE
	elif event.is_action_pressed(&"mode_combine"):
		Game.mode = Game.Mode.COMBINE
	elif event.is_action_pressed(&"search"):
		if Game.can_act():
			_start_search()
	elif event.is_action_pressed(&"take"):
		if Game.can_act() and not _locked:
			_locked = true
			Game.take()
	elif event.is_action_pressed(&"sleep"):
		if Game.can_act() and not _locked:
			_locked = true
			Game.sleep()
	else:
		for i in range(1, 10):
			if event.is_action_pressed(StringName("item_%d" % i)):
				_item_pressed(i)
				break


func _track_lock_keys(event: InputEvent) -> void:
	var actions: Array[StringName] = [&"take", &"sleep"]
	for i in range(1, 10):
		actions.append(StringName("item_%d" % i))
	for action in actions:
		if event.is_action_pressed(action):
			_held_lock_keys[action] = true
		elif event.is_action_released(action):
			_held_lock_keys.erase(action)
	if _held_lock_keys.is_empty():
		_locked = false


func _item_pressed(item: int) -> void:
	if not Game.can_act():
		return
	match Game.mode:
		Game.Mode.EAT:
			if not _locked:
				var before := _stock(item)
				Game.eat(item)
				if before > 0 and item in [1, 2, 7, 8, 9]:
					_locked = true
		Game.Mode.USE:
			if _locked:
				return
			if item == 1 and Game.plant_grain():
				_locked = true
			elif item == 8 and Game.make_dough():
				_locked = true
		Game.Mode.COMBINE:
			if item <= 7:
				# DIV polled the keys every frame; wait one frame so that keys pressed together count
				combo_timer.start()


func _stock(item: int) -> int:
	match item:
		1: return Game.grain
		2: return Game.berries
		7: return Game.herb
		8: return Game.flour
		9: return Game.dough
	return 0


func _evaluate_combination() -> void:
	if _locked or not Game.can_act() or Game.mode != Game.Mode.COMBINE:
		return
	var keys: Array[int] = []
	for i in range(1, 8):
		if _held_lock_keys.has(StringName("item_%d" % i)):
			keys.append(i)
	if Game.combine(keys):
		_locked = true


func _process(delta: float) -> void:
	if _moving:
		_pos = _pos.move_toward(_target, WALK_SPEED * delta)
		if _pos == _target:
			_moving = false
			Game.hero_cell = Vector2i(_target) / TILE
			Game.island.open_card(Game.hero_cell)   # DIV: OpenCard
	if not _moving and Game.can_act():
		_try_start_step()
	position = _pos.round()
	Game.island.flush_radar()


func _try_start_step() -> void:
	for action: StringName in DIRECTION_ACTIONS:
		if action in _held_dirs:
			var dir: Vector2i = DIRECTIONS[action]
			if Game.island.is_walkable(Game.hero_cell + dir):
				Game.hunger -= randi_range(0, 1)
				Game.thirst -= 1
				_target = _pos + Vector2(dir * TILE)
				_moving = true
				return


## DIV: HeldSucht - two waits of 49 frames, abandoned if night falls.
func _start_search() -> void:
	Game.searching = true
	_search_phase = 0
	search_timer.start()


func _on_search_timer() -> void:
	if Game.night_stop:
		Game.searching = false
		return
	_search_phase += 1
	if _search_phase < 2:
		search_timer.start()
		return
	Game.searching = false
	Game.search_result(Game.island.get_object(Game.hero_cell))
