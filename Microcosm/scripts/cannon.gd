class_name Cannon
extends Node2D
## DIV: Canonleft/Canonleftfr/Canonleftbe (and the Right ones) - one cannon in a bottom corner.
## The barrel aims at the crosshair; the mouse button of its side fires a rocket and ammo
## slowly reloads.

const SHOT_SCENE := preload("res://scenes/shot.tscn")

@export var side: Defs.Side = Defs.Side.LEFT

var _click_latched := false  # DIV: ANTIFASTCLICK - one shot per click

@onready var _behind: Sprite2D = $Behind
@onready var _barrel: Sprite2D = $Barrel
@onready var _front: Sprite2D = $Front
@onready var _reload_timer: Timer = $ReloadTimer


func _ready() -> void:
	var left := side == Defs.Side.LEFT
	position = Vector2(0.0 if left else Defs.SCREEN_SIZE.x, Defs.SCREEN_SIZE.y)
	Gfx.apply(_behind, 10 if left else 15)
	Gfx.apply(_barrel, 12)
	Gfx.apply(_front, 11 if left else 16)
	_behind.z_index = -3  # DIV: z = 3 (behind everything)
	_barrel.z_index = 2   # DIV: z = -2
	_front.z_index = 3    # DIV: z = -3
	_reload_timer.one_shot = true
	_reload_timer.timeout.connect(_on_reload_timer_timeout)
	Game.ammo_changed.connect(_update_reload)
	_update_reload()


func _physics_process(_delta: float) -> void:
	var target := _aim_position()
	_barrel.rotation = (target - global_position).angle()
	var action := &"fire_left" if side == Defs.Side.LEFT else &"fire_right"
	var pressed := Input.is_action_pressed(action)
	# The left button also drives the buy menu, so the left cannon only fires below it.
	var may_fire := side == Defs.Side.RIGHT or target.y > Defs.MENU_HEIGHT - 1.0
	if pressed and may_fire and not _click_latched and Game.use_ammo(side):
		_fire()
		_click_latched = true
	if not pressed:
		_click_latched = false


func _aim_position() -> Vector2:
	var crosshair := get_tree().get_first_node_in_group(&"crosshair") as Node2D
	return crosshair.position if crosshair != null else get_global_mouse_position()


func _fire() -> void:
	var shot := SHOT_SCENE.instantiate() as Shot
	shot.setup(global_position, _barrel.rotation, Game.super_rocket, false)
	get_parent().add_child(shot)


## DIV (Canon*fr): while ammo < max, wait the reload time, then add one round.
func _update_reload() -> void:
	if _reload_timer.is_stopped() and Game.ammo[side] < Game.ammo_max[side]:
		_reload_timer.start(Game.reload_seconds(side))


func _on_reload_timer_timeout() -> void:
	Game.add_ammo(side)
	_update_reload()
