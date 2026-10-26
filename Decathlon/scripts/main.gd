class_name Main
extends Node2D
## Game flow of DECATLON.PRG's main code: wind-up (Space advances the stage), throw (the hammer
## flies on a ballistic path drawn pixel by pixel), result (hiscore), wait for Space, repeat.

enum Phase { WINDUP, RELEASED, FLYING, RESULT }

const ARM_SCENE := preload("res://scenes/arm_segment.tscn")
const ARM_POSITION := Vector2(400, 400)       # DIV: Arma(400,400)
const THROW_START := Vector2i(80, 580)        # DIV: x=80; y=580
const GRAVITY := 1                            # DIV: accy+=1 per frame
const FLOOR_Y := 600
const RELEASE_DELAY := 2.0 / Game.TICKS_PER_SECOND   # DIV: FRAME(200)
const RESTART_DELAY := 5.0 / Game.TICKS_PER_SECOND   # DIV: FRAME(500)

signal throw_finished(distance: int, new_record: bool)

@onready var trail: TrailCanvas = $TrailCanvas
@onready var arms: Node2D = $Arms
@onready var ghosts: Node2D = $Ghosts
@onready var hint: PixelLabel = $HUD/Hint

var phase := Phase.WINDUP
var _upper: ArmSegment
var _pos := Vector2i.ZERO
var _velocity := Vector2i.ZERO
var _input_locked := false


func _ready() -> void:
	_start_attempt()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func _unhandled_input(event: InputEvent) -> void:
	if _input_locked or not event.is_action_pressed(&"stage_advance"):
		return
	match phase:
		Phase.WINDUP:
			Game.stage += 1
		Phase.RESULT:
			_start_attempt()


func _start_attempt() -> void:
	trail.clear()
	Game.reset_attempt()
	for ghost in ghosts.get_children():
		ghost.queue_free()
	_upper = _spawn_arm(ArmSegment.Kind.UPPER)
	var lower := _spawn_arm(ArmSegment.Kind.LOWER)
	lower.attach(_upper)
	lower.released.connect(_on_released)
	phase = Phase.WINDUP
	hint.set_value("SPACE: start / next stage    LEFT, RIGHT alternately: speed")
	# The 5 frames after a restart ignore Space (DIV: FRAME(500)).
	_input_locked = true
	get_tree().create_timer(RESTART_DELAY).timeout.connect(func() -> void: _input_locked = false)


func _spawn_arm(kind: ArmSegment.Kind) -> ArmSegment:
	var arm := ARM_SCENE.instantiate() as ArmSegment
	arm.setup(kind, ARM_POSITION, ghosts)
	arms.add_child(arm)
	return arm


func _on_released(velocity: Vector2i) -> void:
	phase = Phase.RELEASED
	_velocity = velocity
	_upper.finish()
	await get_tree().create_timer(RELEASE_DELAY).timeout
	_pos = THROW_START
	phase = Phase.FLYING


func _physics_process(_delta: float) -> void:
	if phase != Phase.FLYING:
		return
	_fly_one_tick()


## One DIV frame of the throw loop.
func _fly_one_tick() -> void:
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			trail.put_pixel(_pos.x + dx, _pos.y + dy, 15 - absi(dx) * 3 - absi(dy) * 3)
	@warning_ignore("integer_division")
	trail.put_pixel((2 * _pos.x + _velocity.x) / 2, (2 * _pos.y + _velocity.y) / 2, 5)
	_pos += _velocity
	_velocity.y += GRAVITY
	if _pos.y > FLOOR_Y:
		_land()
	else:
		Game.distance = _pos.x - THROW_START.x


func _land() -> void:
	phase = Phase.RESULT
	var record := Game.submit_distance(_pos.x - THROW_START.x)
	hint.set_value("SPACE: new throw")
	throw_finished.emit(Game.distance, record)
