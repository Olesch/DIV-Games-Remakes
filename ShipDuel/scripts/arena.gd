extends Node2D
## The match (everything the DIV main code does after the settings screen): scatters the stars,
## puts the four ships in the corners and spawns what they fire. The original has no winner and
## no way back; this port shows who is left and lets Esc return to the settings screen.

const SETTINGS_SCENE := "res://scenes/settings.tscn"
const SHIP_SCENE := preload("res://scenes/ship.tscn")
const PLAYER_COUNT := 4
## DIV: initial angles -45000, -135000, -225000, -315000 (every ship looks at the centre)
const START_ANGLES := [-45000, -135000, -225000, -315000]

var _alive: Array[int] = []
var _over := false

@onready var _stars: Sprite2D = $Stars
@onready var _ships: Node2D = $Ships
@onready var _shots: Node2D = $Shots
@onready var _banner: PixelLabel = $Hud/Banner
@onready var _hint: PixelLabel = $Hud/Hint


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_scatter_stars()
	var mx := Game.margin_h
	var my := Game.margin_v
	var w := int(Defs.SCREEN_SIZE.x)
	var h := int(Defs.SCREEN_SIZE.y)
	var corners := [Vector2(mx, my), Vector2(w - mx, my), Vector2(w - mx, h - my), Vector2(mx, h - my)]
	for i in PLAYER_COUNT:
		var ship := SHIP_SCENE.instantiate() as Ship
		ship.setup(i, corners[i], START_ANGLES[i])
		ship.fired.connect(_on_ship_fired)
		ship.died.connect(_on_ship_died)
		_ships.add_child(ship)
		_alive.append(i)
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"back_to_settings") \
			or (_over and event.is_action_pressed(&"confirm")):
		get_tree().change_scene_to_file(SETTINGS_SCENE)


## DIV: 500 x put_pixel(rand(21,618), rand(21,458), 127) onto the background.
func _scatter_stars() -> void:
	var image := Image.create(int(Defs.SCREEN_SIZE.x), int(Defs.SCREEN_SIZE.y), false, Image.FORMAT_RGBA8)
	for i in Defs.STAR_COUNT:
		image.set_pixel(randi_range(21, 618), randi_range(21, 458), Defs.STAR_COLOR)
	_stars.texture = ImageTexture.create_from_image(image)


func _on_ship_fired(weapon: Defs.Weapon, origin: Vector2, angle: int, owner_index: int) -> void:
	if weapon == Defs.Weapon.SHOT:
		Shot.spawn(_shots, origin, angle, owner_index)
	else:
		Exploshot.spawn(_shots, origin, angle, owner_index)


func _on_ship_died(owner_index: int) -> void:
	_alive.erase(owner_index)
	if _over or _alive.size() > 1:
		return
	_over = true
	if _alive.is_empty():
		_banner.set_value("Unentschieden")
	else:
		_banner.set_value("Spieler %d gewinnt" % (_alive[0] + 1))
	_banner.show()
	_hint.show()
