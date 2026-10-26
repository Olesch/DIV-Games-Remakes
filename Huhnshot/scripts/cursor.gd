class_name Cursor
extends Node2D
## DIV: PROCESS cursor() + Cursordeko. Aiming, shooting, reloading and edge/key scrolling.

const SCROLL_SPEED := 8              # DIV: scroll[0].x0 +-= 8 per frame
const MACHINEGUN_INTERVAL := 3       # DIV: autofire every 3rd frame (MGWAIT>2)
const EDGE := 3

## Tests set this to aim without a real mouse.
var override_pos: Variant = null
var _mg_wait: int = 0

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	Gfx.apply(sprite, 2)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_viewport().warp_mouse(Vector2(400, 300))
	position = Vector2(400, 300)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Pointer in screen pixels, clamped like the original (mouse.x/y limited to the screen).
func aim() -> Vector2:
	var p: Vector2 = override_pos if override_pos != null else get_viewport().get_mouse_position()
	return Vector2(clampf(p.x, 0.0, 800.0), clampf(p.y, 0.0, 600.0))


func _process(_delta: float) -> void:
	position = aim().round()


func _unhandled_input(event: InputEvent) -> void:
	if Game.over:
		return
	if event.is_action_pressed(&"fire"):
		shoot()
	elif event.is_action_pressed(&"reload"):
		reload()


@warning_ignore("integer_division")
func _physics_process(_delta: float) -> void:
	if Game.over:
		return
	if Game.shots > 1:
		Game.accuracy = (Game.hits * 100) / maxi(Game.shots, 1)
	var m := aim()
	if Input.is_action_pressed(&"scroll_left") or m.x < EDGE:
		Game.scroll_by(-SCROLL_SPEED)
	if Input.is_action_pressed(&"scroll_right") or m.x > 800 - EDGE:
		Game.scroll_by(SCROLL_SPEED)
	if Game.bonus_master == 1 and Input.is_action_pressed(&"machinegun_m") and Input.is_action_pressed(&"machinegun_g"):
		_mg_wait += 1
		if _mg_wait > MACHINEGUN_INTERVAL - 1:
			_mg_wait = 0
			if Input.is_action_pressed(&"fire"):
				shoot()
		if Game.ammo < 1:
			Game.ammo = Game.max_ammo
			Game.add_score(-10)


## Left click: one shot at the pointer (needs ammo). Hits the first bird and the first
## special target under the pointer (DIV: two separate collision() calls).
func shoot() -> void:
	if Game.ammo <= 0:
		return
	var m := aim()
	if m.x < 50 and m.y < 25 and Game.time_bonus == 0:
		Game.time += 10
		Game.time_bonus = -1
		Game.popup_screen("100", Vector2(400, 300))
		Game.popup_screen("Uhr abgeknallt!", Vector2(400, 250))
		Game.add_score(100)
		Game.max_ammo += 1
	Game.shots += 1
	Game.ammo -= 1
	var world_point := Vector2(m.x + Game.scroll_x0, m.y)
	for bird: Bird in get_tree().get_nodes_in_group(&"birds"):
		if bird.contains_point(world_point):
			bird.hit()
			break
	for item: SpecialItem in get_tree().get_nodes_in_group(&"specials"):
		if item.contains_point(world_point):
			item.hit()
			break


## Right click: refill the magazine for a score penalty.
func reload() -> void:
	Game.ammo = Game.max_ammo
	Game.add_score(-(50 + Game.flowers))
