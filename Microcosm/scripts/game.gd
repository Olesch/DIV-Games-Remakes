extends Node
## Autoload "Game": the GLOBAL section of the DIV program (money, ammo, difficulty,
## upgrades) plus the shop rules. Entities read from here and listen to its signals.

signal money_changed(value: int)
signal ammo_changed
## Anything that can change a buy button (money, upgrades, bird/potion counts).
signal state_changed
signal duk_bought
signal potion_bought
signal bird_bought
signal atom_bought
signal second_player_bought
## One "pulse" of the atom bomb: every meteor on screen takes a hit.
signal atom_blast

## DIV: the second-player ship is shown at 5000 and required 5000, but only 3000 is charged.
const SECOND_PLAYER_CHARGE := 3000

## Title screen: 1 = hard ... 5 = easy (DIV: Difficulty)
var difficulty: int = 3

var money: int = 250:
	set(value):
		money = value
		money_changed.emit(money)
		state_changed.emit()

## Current / maximum ammo per cannon, indexed by Defs.Side
## (DIV: Left/RightShootMunition, Left/RightShootMunitionMax)
var ammo: Array[int] = [2, 2]
var ammo_max: Array[int] = [2, 2]

var cannon_cost: int = 80        # DIV: KanonsCost
var atom_cost: int = 300         # DIV: AtomKosten
var super_rocket: int = 0        # DIV: SuperRocket, 0..3 (rocket type)
var reload_level: int = 0        # DIV: Nachladezeit, 0..2
var bird_breeding: bool = false  # DIV: VogelZucht
var potion_upgrade: bool = false # DIV: TraenkeVerb
var magnet: bool = false         # DIV: ElektroMagnet
var second_player: bool = false  # DIV: secondPlayer
var atom_active: bool = false    # DIV: AtomBombe

var birds_amount: int = 0:       # DIV: BirdsAmount
	set(value):
		birds_amount = value
		state_changed.emit()
var potions_amount: int = 0:     # DIV: PotionsAmount
	set(value):
		potions_amount = value
		state_changed.emit()

## Meteor difficulty ramp (DIV: Schwierigkeitplus) and the highest meteor kind that may spawn
## (DIV: Supermeteore, 0..3).
var ramp: int = 0
var super_meteors: int = 0


func _ready() -> void:
	_register_input_actions()


## Start a fresh game with the difficulty chosen on the title screen.
func new_game() -> void:
	money = 250
	ammo = [2, 2]
	ammo_max = [2, 2]
	cannon_cost = 80 - 20 * (difficulty - 3)
	atom_cost = 300 - 50 * (difficulty - 3)
	super_rocket = 0
	reload_level = 0
	bird_breeding = false
	potion_upgrade = false
	magnet = false
	second_player = false
	atom_active = false
	birds_amount = 0
	potions_amount = 0
	ramp = 0
	super_meteors = 0
	ammo_changed.emit()
	state_changed.emit()


# ----------------------------------------------------------------- ammo

func use_ammo(side: Defs.Side) -> bool:
	if ammo[side] < 1:
		return false
	ammo[side] -= 1
	ammo_changed.emit()
	return true


## Reloading adds one round without checking the maximum, exactly like the original.
func add_ammo(side: Defs.Side) -> void:
	ammo[side] += 1
	ammo_changed.emit()


## DIV: FRAME(8000 - Max*750 - Nachladezeit*500 - 250*(difficulty-3)) = hundredths of frames.
func reload_seconds(side: Defs.Side) -> float:
	var hundredths := 8000 - ammo_max[side] * 750 - reload_level * 500 - 250 * (difficulty - 3)
	return maxf(hundredths, 100) / 100.0 / Defs.FPS


# ----------------------------------------------------------------- meteors

## DIV: FRAME(rand(5200+200*(d-3), 7200-ramp/5+300*(d-3)) - ramp)
func meteor_interval_seconds() -> float:
	var low := 5200 + 200 * (difficulty - 3)
	var high := 7200 - ramp / 5 + 300 * (difficulty - 3)
	var hundredths := randi_range(mini(low, high), maxi(low, high)) - ramp
	return maxf(hundredths, 100) / 100.0 / Defs.FPS


# ----------------------------------------------------------------- shop

func cost_of(item: Defs.Item) -> int:
	match item:
		Defs.Item.LEFT_CANNON, Defs.Item.RIGHT_CANNON:
			return cannon_cost
		Defs.Item.DUK:
			return 150 - 25 * (difficulty - 3)
		Defs.Item.POTION:
			return 400
		Defs.Item.BIRD:
			return birds_amount * (20 - (15 if bird_breeding else 0)) + 50
		Defs.Item.ATOM:
			return atom_cost
		Defs.Item.SECOND_PLAYER:
			return 5000
		Defs.Item.RELOAD:
			return 1500 if reload_level == 0 else 3000
		Defs.Item.ROCKET:
			return [800, 1200, 2500][clampi(super_rocket, 0, 2)]
		Defs.Item.BIRD_BREEDING:
			return 1000
		Defs.Item.POTION_LIMIT:
			return 3000
		Defs.Item.MAGNET:
			return 750
	return 0


## Fully bought: the button disappears. The magnet only appears once homing rockets exist.
func is_hidden(item: Defs.Item) -> bool:
	match item:
		Defs.Item.SECOND_PLAYER:
			return second_player
		Defs.Item.RELOAD:
			return reload_level >= 2
		Defs.Item.ROCKET:
			return super_rocket >= 3
		Defs.Item.BIRD_BREEDING:
			return bird_breeding
		Defs.Item.POTION_LIMIT:
			return potion_upgrade
		Defs.Item.MAGNET:
			return magnet or super_rocket < 2
	return false


func can_buy(item: Defs.Item) -> bool:
	if is_hidden(item) or money < cost_of(item):
		return false
	match item:
		Defs.Item.LEFT_CANNON:
			return ammo_max[Defs.Side.LEFT] < Defs.MAX_AMMO
		Defs.Item.RIGHT_CANNON:
			return ammo_max[Defs.Side.RIGHT] < Defs.MAX_AMMO
		Defs.Item.POTION:
			return potions_amount < 3 + (3 if potion_upgrade else 0)
		Defs.Item.BIRD:
			return birds_amount < 10 + (10 if bird_breeding else 0)
	return true


## Buy a menu item if possible. Returns true on success.
func try_buy(item: Defs.Item) -> bool:
	if not can_buy(item):
		return false
	var price := cost_of(item)
	if item == Defs.Item.SECOND_PLAYER:
		price = SECOND_PLAYER_CHARGE
	money -= price
	match item:
		Defs.Item.LEFT_CANNON:
			ammo_max[Defs.Side.LEFT] += 1
			cannon_cost += 20
		Defs.Item.RIGHT_CANNON:
			ammo_max[Defs.Side.RIGHT] += 1
			cannon_cost += 20
		Defs.Item.DUK:
			duk_bought.emit()
		Defs.Item.POTION:
			potions_amount += 1
			potion_bought.emit()
		Defs.Item.BIRD:
			birds_amount += 1
			bird_bought.emit()
		Defs.Item.ATOM:
			ammo[Defs.Side.LEFT] = ammo_max[Defs.Side.LEFT]
			ammo[Defs.Side.RIGHT] = ammo_max[Defs.Side.RIGHT]
			atom_active = true
			atom_cost += 100
			atom_bought.emit()
		Defs.Item.SECOND_PLAYER:
			second_player = true
			second_player_bought.emit()
		Defs.Item.RELOAD:
			reload_level += 1
		Defs.Item.ROCKET:
			# Each rocket upgrade costs capacity: 2, 3, 3 rounds per cannon.
			var capacity_loss: int = [2, 3, 3][super_rocket]
			super_rocket += 1
			ammo_max[Defs.Side.LEFT] -= capacity_loss
			ammo_max[Defs.Side.RIGHT] -= capacity_loss
		Defs.Item.BIRD_BREEDING:
			bird_breeding = true
		Defs.Item.POTION_LIMIT:
			potion_upgrade = true
		Defs.Item.MAGNET:
			magnet = true
	ammo_changed.emit()
	state_changed.emit()
	return true


# ----------------------------------------------------------------- input map

func _register_input_actions() -> void:
	_add_keys(&"difficulty_up", [KEY_RIGHT, KEY_EQUAL, KEY_KP_ADD])        # DIV: _right, _plus
	_add_keys(&"difficulty_down", [KEY_LEFT, KEY_MINUS, KEY_KP_SUBTRACT])  # DIV: _left, _minus
	_add_keys(&"start_game", [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_ESCAPE])
	_add_keys(&"back_to_title", [KEY_ESCAPE])  # new: DIV could only quit with Ctrl+Esc
	_add_mouse(&"fire_left", MOUSE_BUTTON_LEFT)
	_add_mouse(&"fire_right", MOUSE_BUTTON_RIGHT)
	_add_keys(&"p2_left", [KEY_LEFT, KEY_KP_4])
	_add_keys(&"p2_right", [KEY_RIGHT, KEY_KP_6])
	_add_keys(&"p2_up", [KEY_UP, KEY_KP_8])
	_add_keys(&"p2_down", [KEY_DOWN, KEY_KP_2])
	_add_keys(&"p2_fire", [KEY_CTRL])


func _add_keys(action: StringName, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key: int in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key as Key
		InputMap.action_add_event(action, event)


func _add_mouse(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)
