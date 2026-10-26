class_name Ship
extends Area2D
## DIV: Ship(Nummer,links,rechts,oben,unten,Schuss,Kauf,Waffewechsel) - one player's ship.
## All timers are counted in physics ticks (= DIV frames at 40 fps). The order of the checks inside
## _physics_process follows the original loop.

var index := 0                  # DIV: Nummer
var ship_speed := 500           # DIV: Ship_Speed in 1/100 px per frame
var fire_held := false          # DIV: key(Schuss), also read by the companion pods

var _pict := 0
var _normal_wait := 0
var _rear := 0                  # Reargun level 0-4
var _rear_wait := 0
var _red := 0                   # Redgun
var _red_wait := 0
var _gatling := 0
var _gatling_wait := 0
var _boing := 0                 # Boinggun
var _boing_wait := 0
var _boing_ani_wait := 0
var _center := 0                # Centergun
var _center_wait := 0
var _flak := 0
var _flak_wait := 0
var _flame := 0
var _flame_wait := 0
var _kill_wait := 0
var _flame_visible := false     # DIV: Flameda
var _flak_visible := false      # DIV: Flakda
var _shield_wait := 0
var _pods: Array[Compain] = []

@onready var _sprite: Sprite2D = $Sprite
@onready var _shape: CollisionShape2D = $Shape
@onready var _shield_sprite: Sprite2D = $ShieldAnimation
@onready var _flak_sprite: Sprite2D = $FlakAddition
@onready var _flame_sprite: Sprite2D = $FlameAddition


func _ready() -> void:
	Game.psh += 1
	var ps := Game.players[index]
	ps.lives = 5
	Gfx.apply(_sprite, 20 + index * 2)
	Gfx.apply(_shield_sprite, 10)
	Gfx.apply(_flak_sprite, 3)
	Gfx.apply(_flame_sprite, 4)
	_shield_sprite.visible = false
	_flak_sprite.visible = false
	_flame_sprite.visible = false
	var r := RectangleShape2D.new()
	r.size = Vector2(34, 14)
	_shape.shape = r
	_shape.position = Vector2(0, -2)
	# four companion pods chained behind the ship (DIV: Compain(nummer,0) creates 1..3)
	var leader: Node2D = self
	for c in 4:
		var pod := Scenes.COMPAIN.instantiate() as Compain
		pod.index = index
		pod.count = c
		pod.leader = leader
		pod.ship = self
		Game.add_entity(pod)
		_pods.append(pod)
		leader = pod
	tree_exiting.connect(_on_leaving)


func _on_leaving() -> void:
	for p in _pods:
		if is_instance_valid(p):
			p.queue_free()


func _act(action: String) -> StringName:
	return StringName("p%d_%s" % [index + 1, action])


func _physics_process(_delta: float) -> void:
	var ps := Game.players[index]
	fire_held = Input.is_action_pressed(_act("fire"))
	var step := ship_speed / 100.0

	# --- movement (the reticle of weapon 4 moves 3x as fast while the fire key is NOT held)
	if Input.is_action_pressed(_act("up")):
		position.y -= step
		if not fire_held:
			ps.center.position.y -= 3.0 * step
	if Input.is_action_pressed(_act("down")):
		position.y += step
		if not fire_held:
			ps.center.position.y += 3.0 * step
	if Input.is_action_pressed(_act("left")):
		position.x -= step
		if not fire_held:
			ps.center.position.x -= 3.0 * step
	if Input.is_action_pressed(_act("right")):
		position.x += step
		if not fire_held:
			ps.center.position.x += 3.0 * step

	if fire_held:
		_fire(ps)
	elif _boing_wait > 0:
		# releasing the fire key discharges the boing gun: power = charge / 15
		var power := _boing_wait / 15
		if power != 0:
			BoingLaser.fire(position, 0, power, null)
		_boing_wait = 0

	if ps.powers == 11:
		ps.compains += 1  # slot 11 of the original gives a companion automatically
		ps.powers = 0
	if Input.is_action_pressed(&"cheat_max"):
		_cheat_max(ps)
	_sanitize_weapon(ps)

	_normal_wait += 1
	_red_wait += 1
	_gatling_wait += 1
	_rear_wait += 1
	_center_wait += 1
	_flak_wait += 1
	_flame_wait += 1

	position.x = clampf(position.x, 50.0, 750.0)
	position.y = clampf(position.y, 80.0, 550.0)

	if ps.killed:
		_handle_kill(ps)

	# --- animation (DIV: after FRAME)
	_pict = (_pict % 11) + 1
	Gfx.apply(_sprite, _pict / 6 + 20 + index * 2)
	_shield_sprite.visible = ps.shield > 0
	_shield_wait = (_shield_wait + 1) % 20
	_shield_sprite.modulate.a = 0.5 if _shield_wait > 10 else 1.0  # DIV: flags=4 flicker
	_flak_sprite.visible = _flak_visible
	_flame_sprite.visible = _flame_visible


func _fire(ps: PlayerState) -> void:
	var x := position.x
	var y := position.y
	if _normal_wait > 13:
		Shot.create(Shot.Kind.NORMAL, Vector2(x, y + 6.0), 0)
		_normal_wait = 0
	if _red > 0 and _red_wait > 10 and ps.weapon == 1:
		Shot.create(Shot.Kind.RED, position, 0)
		if _red >= 2:
			Shot.create(Shot.Kind.RED, position, -30000)
			Shot.create(Shot.Kind.RED, position, 30000)
		if _red >= 3:
			Shot.create(Shot.Kind.RED, position, 15000)
			Shot.create(Shot.Kind.RED, position, -15000)
		if _red >= 4:
			Shot.create(Shot.Kind.RED, position, 45000)
			Shot.create(Shot.Kind.RED, position, -45000)
		_red_wait = 0
	if _gatling > 0 and _gatling_wait > 3 and ps.weapon == 2:
		_gatling_shot(Div.rand(-300, 300), Div.rand(-1500, 1500))
		if _gatling >= 2:
			_gatling_shot(Div.rand(5700, 6300), Div.rand(-1500, 1500))
		if _gatling >= 3:
			_gatling_shot(Div.rand(3700, 4300), Div.rand(-1500, 1500))
		if _gatling >= 4:
			_gatling_shot(Div.rand(3700, 4300), Div.rand(-1500, 1500))
		_gatling_wait = 0
	if _rear > 0 and _rear_wait > 20:
		Shot.create(Shot.Kind.REAR, position, -180000)
		if _rear >= 2:
			Shot.create(Shot.Kind.REAR, position, -210000)
			Shot.create(Shot.Kind.REAR, position, -150000)
		if _rear >= 3:
			Shot.create(Shot.Kind.REAR, position, -240000)
			Shot.create(Shot.Kind.REAR, position, -120000)
		if _rear >= 4:
			Shot.create(Shot.Kind.REAR, position, -270000)
			Shot.create(Shot.Kind.REAR, position, -90000)
		_rear_wait = 0
	if _flak > 0 and _flak_wait > 20 - _flak * 3:
		Shot.create(Shot.Kind.FLAK, Vector2(x - 15.0, y - 10.0), 60000)
		if _flak >= 3:
			Shot.create(Shot.Kind.FLAK, Vector2(x - 15.0 + Div.rand(-500, 500) / 100.0,
					y - 10.0 + Div.rand(-500, 500) / 100.0), 60000 + Div.rand(-7000, 7000))
		_flak_wait = 0
	if _flame > 0 and _flame_wait > 3:
		FlameShot.fire(Vector2(x + Div.rand(-500, 500) / 100.0, y + 6.0 + Div.rand(-500, 500) / 100.0),
				-60000 + Div.rand(-7000, 7000), _flame, self)
		if _flame >= 3:
			FlameShot.fire(Vector2(x + Div.rand(-500, 500) / 100.0, y + 6.0 + Div.rand(-500, 500) / 100.0),
					-60000 + Div.rand(-7000, 7000), _flame - 1, self)
		_flame_wait = 0
	if _boing > 0 and ps.weapon == 3:
		_boing_ani_wait += 1
		_boing_wait += 1
		if _boing_ani_wait > 1:
			if _boing >= 3:
				_boing_wait += 1
			if _boing_wait > 60:
				Charger.spawn(self, 105, 150)
			elif _boing_wait > 45:
				Charger.spawn(self, 105, 110)
			elif _boing_wait > 30:
				Charger.spawn(self, 105, 80)
			elif _boing_wait > 15:
				Charger.spawn(self, 105, 50)
			_boing_ani_wait = 0
		if _boing_wait > _boing * 15:
			_boing_wait = _boing * 15
	if _center > 0 and _center_wait > 23 and ps.weapon == 4:
		var aim := ps.center.position
		var angles: Array[int] = []
		if _center == 1 or _center == 3:
			angles.append_array([180000, -60000, 60000])
		if _center == 2 or _center == 4:
			angles.append_array([180000, -90000, 90000, 0])
		if _center == 3:
			angles.append_array([0, -120000, 120000])
		if _center == 4:
			angles.append_array([45000, -45000, 135000, -135000])
		for a in angles:
			CenterMissile.launch(position, a, aim)
		_center_wait = 0


func _gatling_shot(dx: int, dy: int) -> void:
	Shot.create(Shot.Kind.GATLING, position + Vector2(dx, dy) / 100.0, 0)


## DIV: the Kauf block. `powers` = number of money units collected, the buy line cursor.
func _buy(ps: PlayerState) -> void:
	match ps.powers:
		1:
			if ship_speed < 1030:
				ship_speed += ship_speed / 4
				ps.powers = 0
		2:
			if _rear < 4:
				_rear += 1
				ps.powers = 0
		3:
			if _red < 4:
				_red += 1
				ps.powers = 0
		4:
			if _gatling < 4:
				_gatling += 1
				ps.powers = 0
		5:
			if _flak < 4:
				if _flak == 0 and not _flak_visible:
					_flak_visible = true
				_flak += 1
				ps.powers = 0
		6:
			if _boing < 4:
				_boing += 1
				ps.powers = 0
		7:
			if _flame < 4:
				if _flame == 0 and not _flame_visible:
					_flame_visible = true
				_flame += 1
				ps.powers = 0
		8:
			if _center < 4:
				_center += 1
				ps.powers = 0
		9:
			ps.shield += 3
			ps.powers = 0
		11:
			ps.lives += 1
			ps.powers = 0


## DIV: the O cheat (once O+L+E+G). Runs every frame while O is held, for every ship, so lives
## keep climbing and the speed grows up to its cap.
func _cheat_max(ps: PlayerState) -> void:
	_gatling = 4
	_red = 4
	_boing = 4
	_center = 4
	_rear = 4
	ps.shield = 4
	_flame_visible = true
	_flak_visible = true
	_flak = 4
	_flame = 4
	if ship_speed < 1030:
		ship_speed += ship_speed / 4
	ps.lives += 1
	ps.compains = 4


## DIV: the Killed==1 block at the end of the loop (about 2.9 s of ghost mode after each hit).
func _handle_kill(ps: PlayerState) -> void:
	if _kill_wait == 0:
		modulate.a = 0.5  # DIV flags=4
		Explosion.spawn(position, 150, 2)
		_kill_wait = 120
		if Game.shared_lives == 0:
			if ps.lives < 1:
				ps.lives = -1
				Game.psh -= 1
				if Game.psh == -1:
					Game.world.game_over(position, true)
					set_physics_process(false)
					return
				queue_free()  # this player is out; the others fly on
				return
			ps.lives -= 1
		else:
			var p0 := Game.players[0]
			if p0.lives < 1:
				p0.lives = -1
				Game.psh = -1
				Game.world.game_over(position, false)
				set_physics_process(false)
				return
			p0.lives -= 1
		if ps.shield > 0:
			ps.shield -= 1
		else:
			# lose the active weapons one level (passive ones too if the menu option says so)
			_red -= 1
			_gatling -= 1
			_boing -= 1
			_center -= 1
			ps.compains -= 1
			if Game.passive_loss == 1:
				_flak -= 1
				_flame -= 1
				_rear -= 1
			_rear = maxi(_rear, 0)
			_red = maxi(_red, 0)
			_gatling = maxi(_gatling, 0)
			_boing = maxi(_boing, 0)
			_center = maxi(_center, 0)
			_flak = maxi(_flak, 0)
			_flame = maxi(_flame, 0)
			ps.compains = maxi(ps.compains, 0)
	_kill_wait -= 1
	if _kill_wait < 5:
		modulate.a = 1.0
		ps.killed = false
		_kill_wait = 0


## Buy / weapon-change / direct weapon keys arrive as single presses (DIV: Antifastshift/-enter).
func _unhandled_input(event: InputEvent) -> void:
	var ps := Game.players[index]
	if event.is_action_pressed(_act("buy"), false, true):
		_buy(ps)
	elif event.is_action_pressed(_act("weapon"), false, true):
		ps.weapon = (ps.weapon + 1) % 5
		if _red == 0 and ps.weapon == 1:
			ps.weapon += 1
		if _gatling == 0 and ps.weapon == 2:
			ps.weapon += 1
		if _boing == 0 and ps.weapon == 3:
			ps.weapon += 1
		if _center == 0 and ps.weapon == 4:
			ps.weapon = 0
		if ps.weapon == 4:
			ps.center.position = position
			ps.center.reset_physics_interpolation()  # the reticle jumps to the ship
		_red_wait = 0
		_gatling_wait = 0
		_boing_wait = 0
		_center_wait = 0
	elif index == 0:
		if event.is_action_pressed(&"p1_select_1") and _red > 0:
			ps.weapon = 1
		elif event.is_action_pressed(&"p1_select_2") and _gatling > 0:
			ps.weapon = 2
		elif event.is_action_pressed(&"p1_select_3") and _boing > 0:
			ps.weapon = 3
		elif event.is_action_pressed(&"p1_select_4") and _center > 0:
			ps.weapon = 4
			ps.center.position = position
			ps.center.reset_physics_interpolation()  # the reticle jumps to the ship


## A weapon that was lost (killed) cannot stay selected.
func _sanitize_weapon(ps: PlayerState) -> void:
	if _red == 0 and ps.weapon == 1:
		ps.weapon = 0
	if _gatling == 0 and ps.weapon == 2:
		ps.weapon = 0
	if _boing == 0 and ps.weapon == 3:
		ps.weapon = 0
	if _center == 0 and ps.weapon == 4:
		ps.weapon = 0
