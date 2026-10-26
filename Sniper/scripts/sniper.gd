class_name Sniper
extends Node2D
## DIV: PROCESS Sniper(x,y,MODE). Aims at the crosshair; Up/Down moves the column (every sniper);
## left mouse fires after the reload. Logic runs per 24 fps tick (one tick = one DIV frame).
## Modes 1 (minigun) and 2 (grenade launcher) are only spawned by the commented-out part of the
## original's main code; here the options screen (`Settings`) puts them into the column.

enum Mode { NORMAL, MINIGUN, GRENADE }

const SHOT_SCENE := preload("res://scenes/shot.tscn")
const MOVE_STEP := 3.0              # DIV y+-=3 per frame
const RELOAD_TICKS := 40            # DIV Schussladezeit=40
const SNIPER_RECOIL := Vector2(-30, -200)
const KICK_OFFSETS: Array[float] = [-5.0, 2.0, 2.0, 1.0]  # DIV x-=5; x+=2; x+=2; x+=1
const MINIGUN_MAX_AMMO := 75
const MINIGUN_SPINUP := 6
const MINIGUN_READY_RPM := 75
const MINIGUN_RELOAD_TICKS := 36    # DIV FRAME(3600)

@export var mode: Mode = Mode.NORMAL

var _reload := 0       # DIV Schussladezeit (fire allowed when < 0)
var _phase := 0        # position inside a multi-frame action (0 = idle)
var _lock_ticks := 0
var _rpm := 0          # DIV Drehzahl
var _ammo := 0
var _base_x := 0.0
var _crosshair: Crosshair

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_base_x = position.x
	Gfx.apply(_sprite, 6)
	_crosshair = get_tree().get_first_node_in_group(&"crosshair") as Crosshair
	add_to_group(&"snipers")


func _physics_process(_delta: float) -> void:
	if _lock_ticks > 0:
		_lock_ticks -= 1
		return
	if _phase > 0:
		_continue_action()
		return
	_aim()
	if _reload < 0:
		if Input.is_action_pressed(&"column_up"):
			position.y -= MOVE_STEP
		if Input.is_action_pressed(&"column_down"):
			position.y += MOVE_STEP
		if Input.is_action_pressed(&"fire"):
			_fire()
		if _phase == 0:
			_check_minigun_reload()
	else:
		_reload -= 1


func _aim() -> void:
	if _crosshair:
		rotation = (_crosshair.aim_position - position).angle()  # DIV get_angle(Fadenkreuz_id)


func _fire() -> void:
	match mode:
		Mode.NORMAL:
			_spawn_shot()
			_crosshair.recoil(SNIPER_RECOIL)
			_phase = 1
		Mode.MINIGUN:
			if _rpm < MINIGUN_READY_RPM + 1:
				_rpm += MINIGUN_SPINUP
			if _rpm > MINIGUN_READY_RPM and _ammo < MINIGUN_MAX_AMMO:
				_spawn_shot()
				position.x = _base_x - 5.0
				_phase = 1
			else:
				_rpm -= 5
		Mode.GRENADE:
			_spawn_shot()
			position.x = _base_x - 8.0
			_phase = 1


## The frames that follow a shot (DIV code after the FRAME inside the fire block).
func _continue_action() -> void:
	match mode:
		Mode.NORMAL:
			if _phase == 1:
				_aim()
				_reload = RELOAD_TICKS
			if _phase <= KICK_OFFSETS.size():
				position.x += KICK_OFFSETS[_phase - 1]
			# phase 5 is the dead frame at the end of the DIV loop iteration
			_phase = _phase + 1 if _phase <= KICK_OFFSETS.size() else 0
		Mode.MINIGUN:
			position.x = _base_x
			_ammo += 1
			_crosshair.recoil(Vector2(-randi_range(30, 50), -randi_range(80, 100)))
			_rpm -= 5
			_phase = 0
			_check_minigun_reload()  # DIV: IF(mouse.right) follows in the same pass
		Mode.GRENADE:
			position.x = _base_x
			_crosshair.recoil(Vector2(-randi_range(70, 90), -randi_range(200, 250)))
			_reload = RELOAD_TICKS
			_phase = 0


## DIV: IF(mouse.right) ... IF(MODE==1) Ammo=0; Drehzahl=0; FRAME(3600); - checked after the fire
## block in the same pass (also while the left button is held).
func _check_minigun_reload() -> void:
	if mode == Mode.MINIGUN and Input.is_action_pressed(&"reload"):
		_ammo = 0
		_rpm = 0
		_lock_ticks = MINIGUN_RELOAD_TICKS


func _spawn_shot() -> void:
	var shot := SHOT_SCENE.instantiate() as Shot
	var angle_deg := -rad_to_deg((_crosshair.aim_position - position).angle())
	shot.setup(position, angle_deg, mode)
	get_parent().add_child(shot)
