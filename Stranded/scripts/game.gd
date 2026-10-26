extends Node
## Autoload "Game": the GLOBAL section of STRANDED.PRG (inventory, hunger/thirst/health, action
## mode, day clock) plus the rules for eating, planting, combining and sleeping.
## Original frame counts are converted with FPS = 24 (DIV: set_fps(24, 0)).

signal inventory_changed
signal stats_changed
signal mode_changed
signal clock_changed
signal message(text: String, y: int)   # DIV: Write(0, 400, y, 7, text) shown for 96 frames
signal died                            # DIV: Held_id.Graph = 40
signal night_fell                      # DIV: TimeSun after the last sun step
signal night_ended

const FPS := 24.0
const MESSAGE_SECONDS := 96.0 / FPS            # FRAME(9600)
const HUNGER_PERIOD := 121.0 / FPS             # DIV: ShowHunger counter >= 120 (one frame later)
const THIRST_PERIOD := 61.0 / FPS              # DIV: ShowThirst counter >= 60
const HEALTH_PERIOD := 73.0 / FPS              # DIV: ShowHealth counter >= 72
const SUN_STEP_SECONDS := 12.0 / FPS           # DIV: FRAME(1200) per sun step
const SUN_START := 550                         # sun x on the radar header (DIV: Time_id.x)
const SUN_END := 800
const SLEEP_FROM := 750                        # sleeping allowed when the sun is past this
const SEARCH_SECONDS := 49.0 / FPS             # DIV: FRAME(4900), twice

enum Mode { EAT = 1, USE = 2, COMBINE = 3 }    # DIV: Aktion (V / B / G)

var island: Island
var hero_cell := Island.START_CELL
var searching := false          # DIV: Suchen
var night_stop := false         # DIV: NachtStop
var mode: Mode = Mode.EAT:
	set(value):
		mode = value
		mode_changed.emit()

# Inventory (DIV: Getreide, Beeren, Ast, Stein, Blatt, Liane, Heilkraut, Mehl, Teig)
var grain := 0
var berries := 0
var branch := 0
var stone := 0
var leaf := 0
var vine := 0
var herb := 0
var flour := 0
var dough := 0
# Tools (DIV: Hammer, Axt, Angel: 0 = none, 1 = just made, 2 = shown in the list)
var hammer := 0
var axe := 0
var rod := 0
var flour_listed := false       # DIV: MehlTex == 2
var dough_listed := false       # DIV: TeigTex == 2

var hunger := 50:               # 100 = good, 0 = bad
	set(value):
		hunger = clampi(value, 0, 100)
		stats_changed.emit()
var thirst := 50:
	set(value):
		thirst = clampi(value, 0, 100)
		stats_changed.emit()
var health := 50:
	set(value):
		if value < 0:
			health = 0
			died.emit()
		else:
			health = mini(value, 100)
		stats_changed.emit()

var sun_x := SUN_START + 1     # DIV: Time_id.x
var _hunger_timer := Timer.new()
var _thirst_timer := Timer.new()
var _health_timer := Timer.new()
var _sun_timer := Timer.new()


func _ready() -> void:
	_register_input_actions()
	for t: Array in [[_hunger_timer, HUNGER_PERIOD, _on_hunger_tick], [_thirst_timer, THIRST_PERIOD, _on_thirst_tick],
			[_health_timer, HEALTH_PERIOD, _on_health_tick], [_sun_timer, SUN_STEP_SECONDS, _on_sun_step]]:
		var timer: Timer = t[0]
		timer.wait_time = t[1]
		timer.timeout.connect(t[2])
		add_child(timer)
		timer.start()


## Called by the world scene: fresh state and a fresh (not yet generated) island.
func start_new_game() -> void:
	island = Island.new()
	hero_cell = Island.START_CELL
	searching = false
	night_stop = false
	mode = Mode.EAT
	grain = 0
	berries = 0
	branch = 0
	stone = 0
	leaf = 0
	vine = 0
	herb = 0
	flour = 0
	dough = 0
	hammer = 0
	axe = 0
	rod = 0
	flour_listed = false
	dough_listed = false
	hunger = 50
	thirst = 50
	health = 50
	sun_x = SUN_START + 1
	for t in [_hunger_timer, _thirst_timer, _health_timer, _sun_timer]:
		(t as Timer).start()
	inventory_changed.emit()
	clock_changed.emit()


func _on_hunger_tick() -> void:
	hunger -= 1


func _on_thirst_tick() -> void:
	thirst -= 1


func _on_health_tick() -> void:
	if hunger <= 0:
		health -= 1
	if thirst <= 0:
		health -= 1
	if hunger > 90 and thirst > 90:
		health += 1


func _on_sun_step() -> void:
	sun_x += 1
	if sun_x > SUN_END:
		_begin_night()
		return
	clock_changed.emit()


## DIV: end of the TimeSun loop. The hero loses health (less when standing at a tree), then the
## screen fades out, Refresh_all runs, and the next day begins after the fade-in.
func _begin_night() -> void:
	_sun_timer.stop()
	var standing_object := island.get_object(hero_cell) if island else 0
	if standing_object == Island.TREE:
		health -= 15 + randi_range(-5, 5)
	else:
		health -= 25 + randi_range(-5, 5)
	night_stop = true
	night_fell.emit()


## Called by the fader when the screen is black again.
func end_night() -> void:
	night_stop = false
	sun_x = SUN_START + 1
	_sun_timer.start()
	clock_changed.emit()
	night_ended.emit()


func say(text: String, y: int = 280 + randi_range(-20, 20)) -> void:
	message.emit(text, y)


# --- actions bound to keys -------------------------------------------------------------

func can_act() -> bool:
	return not night_stop and not searching


## DIV: Aktion==1 and key 1/2/7/8/9
func eat(item: int) -> void:
	match item:
		1:
			if grain > 0:
				grain -= 1
				hunger += 4
		2:
			if berries > 0:
				berries -= 1
				hunger += 5
				thirst += 2
		7:
			if herb > 0:
				herb -= 1
				hunger += 10
				thirst += 10
				health += 20
		8:
			if flour > 0:
				flour -= 1
				hunger += 8
		9:
			if dough > 0:
				dough -= 1
				hunger += 12
				thirst += 6
				health += 1
	inventory_changed.emit()


## DIV: Aktion==2 and key 1 - sow grain on empty grass. Returns true if it used the key.
func plant_grain() -> bool:
	if grain <= 0:
		return false
	if island.get_object(hero_cell) == 0 and island.get_field(hero_cell) == Island.GRASS:
		grain -= 1
		island.put_tile(hero_cell, Island.T_GRAIN_SEEDLING)
		island.set_object(hero_cell, Island.PLANTED_GRAIN)
		inventory_changed.emit()
		return true
	return false


## DIV: Aktion==2 and key 8 standing at a spring: flour + water = dough. True if it locked the keys.
func make_dough() -> bool:
	if flour > 0 and island.get_object(hero_cell) == Island.SPRING:
		flour -= 1
		dough += 1
		if not dough_listed:
			dough_listed = true
			say("Teig Hergestellt")
		inventory_changed.emit()
		return true
	return false


## DIV: Aktion==3. `keys` = the item keys (1..7) held down. True if a recipe matched (keys lock).
func combine(keys: Array[int]) -> bool:
	if keys.size() == 2:
		if 1 in keys and 4 in keys and grain > 2 and stone > 0:
			if not flour_listed:
				flour_listed = true   # DIV: MehlTex=1 -> the list shows "8-Mehl"
			grain -= 3
			flour += 1
			say("Mehl Hergestellt")
			inventory_changed.emit()
			return true
		if 3 in keys and 4 in keys and branch > 0 and stone > 0:
			if hammer == 0:
				hammer = 1
				stone -= 1
				branch -= 1
				say("Hammer Hergestellt")
			inventory_changed.emit()
			return true
		if 3 in keys and 6 in keys and branch > 0 and vine > 0:
			if rod == 0:
				rod = 1
				vine -= 1
				branch -= 1
				say("Angel Hergestellt")
			inventory_changed.emit()
			return true
	elif keys.size() == 3:
		if 3 in keys and 4 in keys and 6 in keys and branch > 0 and stone > 0 and vine > 0:
			if axe == 0:
				axe = 1
				stone -= 1
				branch -= 1
				vine -= 1
				say("Axt Hergestellt")
			inventory_changed.emit()
			return true
	return false


## DIV: key A. Sleeping skips the rest of the day, but only late in the day.
func sleep() -> void:
	if sun_x > SLEEP_FROM:
		sun_x = SUN_END
		clock_changed.emit()
	else:
		say("Zu Frueh!")


## Result of a search at the hero's cell (DIV: HeldSucht, after 2 x 49 frames).
func search_result(object_code: int) -> void:
	var found: int
	match object_code:
		Island.TREE:
			found = randi_range(0, 11)
			if found <= 3:
				branch += 1
				say("Ast gefunden!", 300)
			elif found <= 6:
				leaf += 1
				say("Blatt gefunden!", 300)
			elif found <= 8:
				vine += 1
				say("Liane gefunden!", 300)
			else:
				say("Nichts gefunden!", 300)
		Island.BERRIES, Island.PICKED_BERRIES, Island.HERB:
			found = randi_range(0, 8)
			if found <= 1:
				branch += 1
				say("Ast gefunden!", 300)
			elif found <= 6:
				leaf += 1
				say("Blatt gefunden!", 300)
			else:
				say("Nichts gefunden!", 300)
		Island.SPRING, Island.STONE, Island.BIG_STONE:
			found = randi_range(0, 5)
			if found <= 3:
				stone += 1
				say("Stein gefunden!", 300)
			else:
				say("Nichts gefunden!", 300)
		_:
			say("Nichts gefunden!", 300)
	inventory_changed.emit()


## DIV: HeldNimmt - pick up whatever stands on the hero's cell.
func take() -> void:
	var cell := hero_cell
	match island.get_object(cell):
		Island.BERRIES:
			berries += 1
			say("Beeren gefunden!")
			island.set_object(cell, Island.PICKED_BERRIES)
			island.put_tile(cell, Island.T_PICKED_BERRIES)
		Island.PICKED_BERRIES:
			leaf += 2
			say("2 Blaetter gefunden!")
			_clear_cell(cell)
		Island.GRAIN:
			grain += 2
			say("2 Getreide gefunden!")
			_clear_cell(cell)
		Island.HERB:
			herb += 1
			say("Heilkraut gefunden!")
			_clear_cell(cell)
		Island.STONE:
			stone += 2
			say("2 Steine gefunden!")
			_clear_cell(cell)
		Island.SPRING:
			thirst += 5       # DIV prints a blank text
		_:
			say("Nichts da!", 300)
	inventory_changed.emit()


func _clear_cell(cell: Vector2i) -> void:
	island.set_object(cell, 0)
	island.put_tile(cell, island.random_grass())


# --- input map --------------------------------------------------------------------------

func _register_input_actions() -> void:
	# physical keys = DIV scan codes (Oleg's German keyboard: _z is the key left of X)
	var keys := {
		&"move_up": [KEY_S],        # _s
		&"move_down": [KEY_X],      # _x
		&"move_left": [KEY_Z],      # _z
		&"move_right": [KEY_C],     # _c
		&"search": [KEY_D],         # _d  Durchsuchen
		&"take": [KEY_F],           # _f  Aufnehmen
		&"sleep": [KEY_A],          # _a  Schlafen
		&"mode_eat": [KEY_V],       # _v  Essen
		&"mode_use": [KEY_B],       # _b  Benutzen
		&"mode_combine": [KEY_G],   # _g  Kombinieren
	}
	for i in range(1, 10):
		keys[StringName("item_%d" % i)] = [KEY_0 + i, KEY_KP_0 + i]
	for action: StringName in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code: int in keys[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = code as Key
			InputMap.action_add_event(action, ev)
