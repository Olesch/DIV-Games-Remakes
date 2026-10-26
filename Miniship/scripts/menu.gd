class_name Menu
extends Node2D
## Option menu (DIV process Moover + the texts of the main code).
## Up/Down move the cursor, Left/Right change the highlighted value, Enter starts (needs 2+ players).
## Cursor rows: -4..-1 = ship D..A (OFF/ON/PC levels), 0 energy, 1 gravity, 2 particles,
## 3 laser, 4 energy load, 5 game type, 6 asteroids.

const WORLD_SCENE := "res://scenes/world.tscn"

## Cursor position per row (DIV x,y of Moover)
const CURSOR_POS := {
	-4: Vector2(485, 145), -3: Vector2(425, 145), -2: Vector2(365, 145), -1: Vector2(313, 145),
	0: Vector2(130, 533), 1: Vector2(130, 544), 2: Vector2(130, 555),
	3: Vector2(330, 536), 4: Vector2(330, 547), 5: Vector2(330, 558),
	6: Vector2(530, 534),
}
## X of the ship-mode texts for players A..D (DIV write at y=145, centred)
const PLAYER_TEXT_X := [333, 385, 445, 505]

@onready var background: Sprite2D = $Background
@onready var cursor: Sprite2D = $Cursor
@onready var effects: Effects = $Effects

var row := 0
var _player_labels: Array[PixelLabel] = []
var _energy_label: PixelLabel
var _gravity_label: PixelLabel
var _particle_label: PixelLabel
var _laser_label: PixelLabel
var _load_label: PixelLabel
var _play_label: PixelLabel
var _asteroid_label: PixelLabel


func _ready() -> void:
	Game.effects = effects
	Gfx.apply(background, Gfx.MENU_PLAIN)
	Gfx.apply(cursor, Gfx.ROCKET)
	cursor.centered = true
	cursor.offset = Vector2.ZERO
	for i in 4:
		_player_labels.append(_make_label(PLAYER_TEXT_X[i], 145, 4))
	_energy_label = _make_label(145, 533, 3)
	_gravity_label = _make_label(145, 544, 3)
	_particle_label = _make_label(145, 555, 3)
	_laser_label = _make_label(340, 536, 3)
	_load_label = _make_label(340, 547, 3)
	_play_label = _make_label(340, 558, 3)
	_asteroid_label = _make_label(545, 534, 3)
	_refresh()
	_move_cursor()
	if "--autotest" in OS.get_cmdline_user_args():
		get_tree().root.add_child.call_deferred(AutoTest.new())


func _make_label(x: int, y: int, align: int) -> PixelLabel:
	var label := PixelLabel.new()
	label.position = Vector2(x, y)
	label.align_code = align
	add_child(label)
	return label


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"menu_down", true) and row < 6:
		_cursor_step(1)
	elif event.is_action_pressed(&"menu_up", true) and row > -4:
		_cursor_step(-1)
	elif event.is_action_pressed(&"menu_left", true):
		_change(-1)
	elif event.is_action_pressed(&"menu_right", true):
		_change(1)
	elif event.is_action_pressed(&"menu_start") and _player_count() > 1:
		get_tree().change_scene_to_file(WORLD_SCENE)
	elif event.is_action_pressed(&"back") and not OS.has_feature("web"):
		get_tree().quit()    # DIV Esc: exit("May the force be with you!")


func _player_count() -> int:
	var sum := 0
	for m in Game.ship_mode:
		sum += m
	return sum


func _cursor_step(dir: int) -> void:
	effects.particles(int(cursor.position.x) * 100, int(cursor.position.y) * 100, 5, 300)
	row += dir
	_move_cursor()


func _move_cursor() -> void:
	cursor.position = CURSOR_POS[row]
	cursor.reset_physics_interpolation()  # jump to the row, don't slide there


func _change(dir: int) -> void:
	match row:
		-4, -3, -2, -1:
			var player := row + 4          # row -1 = ship A ... -4 = ship D
			player = 3 - player
			Game.ship_mode[player] = clampi(Game.ship_mode[player] + dir, 0, 5)
		0:
			Game.max_energy = clampi(Game.max_energy + 50 * dir, 200, 3000)
		1:
			Game.gravity = clampi(Game.gravity + 200 * dir, 3000, 16000)
		2:
			Game.particles = clampi(Game.particles + dir, 0, 2)
		3:
			Game.laser_type = clampi(Game.laser_type + dir, 0, 6)
		4:
			Game.load_type = clampi(Game.load_type + dir, 0, 4)
		5:
			Game.play_type = clampi(Game.play_type + dir, 0, 2)
		6:
			Game.asteroids = clampi(Game.asteroids + dir, 0, 9)
	_refresh()


func _refresh() -> void:
	for i in 4:
		_player_labels[i].set_value(Game.PLAYER_TEXT[Game.ship_mode[i]])
	_energy_label.set_value(str(Game.max_energy))
	_gravity_label.set_value(str(Game.gravity))
	_particle_label.set_value(Game.PARTICLE_TEXT[Game.particles])
	_laser_label.set_value(Game.LASER_TEXT[Game.laser_type])
	_load_label.set_value(Game.LOAD_TEXT[Game.load_type])
	_play_label.set_value(Game.PLAY_TEXT[Game.play_type])
	_asteroid_label.set_value(str(Game.asteroids))
	match Game.play_type:
		0: Gfx.apply(background, Gfx.MENU_PLAIN)
		1: Gfx.apply(background, Gfx.MENU_SIMPLE)
		2: Gfx.apply(background, Gfx.MENU_FLAG)
