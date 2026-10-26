class_name LevelScript
extends Node
## The timeline of the original main code (levels 1 and 2) as a list of steps. Each step does
## something (spawn enemies, show a message) and then waits; a step with `until` repeats until its
## condition holds (the original's LOOP). Waits are Timers: DIV FRAME(n) = n/100 frames = n/4000 s.
## Spawn helpers take DIV units (1/100 px) so the numbers match the PRG listing.

signal finished

var hud: Hud
var _steps: Array[Dictionary] = []
var _index := 0
var _timer: Timer
var _text: PixelLabel = null
var _boss: Node = null
var _loop_i := 0


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_timer.timeout.connect(_on_timer)
	add_child(_timer)
	_build()


func start() -> void:
	_index = 0
	_run()


## Debug: continue at the step labelled `label`.
func jump_to(label: String) -> void:
	_timer.stop()
	for i in _steps.size():
		if _steps[i].get("label", "") == label:
			_index = i
			_run()
			return


func _step(wait: float, action: Callable, label := "") -> void:
	_steps.append({"wait": wait, "do": action, "label": label, "until": Callable()})


func _label(label: String) -> void:
	_steps[-1]["label"] = label


func _until(condition: Callable) -> void:
	_steps[-1]["until"] = condition


func _run() -> void:
	if _index >= _steps.size():
		finished.emit()
		return
	var st := _steps[_index]
	(st["do"] as Callable).call()
	_timer.start(maxf(float(st["wait"]) / 4000.0, 0.001))


func _on_timer() -> void:
	var st := _steps[_index]
	var until: Callable = st["until"]
	if until.is_valid() and not until.call():
		_run()
		return
	_index += 1
	_run()


# --- helpers named after the DIV processes (arguments in DIV units)

func _snake(x: int, y: int, xs: int, ys: int, count: int, money: int, art: int, weapon: int, graph: int, life: int) -> Snake:
	return Snake.spawn(x, y, xs, ys, count, money, art, weapon, graph, life)


func _boomer(x: int, y: int, speed: int, money: int, angle: int, near: int, life: int) -> void:
	Boomer.spawn(x, y, speed, money, angle, near, life)


func _jump(x: int, y: int, mov: int, stand: int, dec: int, money: int, art: int, weapon_speed: int, graph: int, life: int) -> void:
	JumpShooter.spawn(x, y, mov, stand, dec, money, art, weapon_speed, graph, life)


func _bomb(x: int, y: int, xs: int, ys: int, time: int, expsize: int, life: int) -> void:
	Bomb.spawn(x, y, xs, ys, time, expsize, life)


func _pick(kind: Pickup.Kind, x: int, y: int) -> void:
	Pickup.spawn(kind, Vector2(x, y) / 100.0)


func _say(text: String, x: int, y: int, align: int) -> void:
	_del()
	_text = hud.say(text, x, y, align)


func _del() -> void:
	if _text != null and is_instance_valid(_text):
		_text.queue_free()
	_text = null


func _show_life(boss: Node) -> void:
	_del()
	_text = hud.show_life(boss)


func _boss_dead() -> bool:
	return _boss == null or not is_instance_valid(_boss) or (_boss as Enemy).life <= 0


func _build() -> void:
	# ---------------------------------------------------------------- LEVEL 1
	_step(12000, func(): _say("Level 1 - Get Started", 400, 300, 4), "L1")
	_step(18000, func():
		_del()
		_snake(80000, 30000, 500, 0, 5 + Game.psh * 2, 0, 1, 0, 200, 10))
	_step(18000, func():
		_snake(80000, 40000, 500, -100, 5, 5, 1, 0, 200, 10)
		_snake(80000, 20000, 500, 100, 5, 5, 1, 0, 200, 10))
	_step(18000, func():
		_snake(80000, 10000, 500, 0, 2, 5, 0, 0, 200, 10)
		_snake(80000, 20000, 500, 0, 2, 5, 0, 0, 200, 10)
		_snake(96000, 30000, 500, 0, 0, 5, 0, 2, 200, 10)
		for y in [40000, 50000, 15000, 25000, 35000, 45000]:
			_snake(80000, y, 500, 0, 2, 5, 0, 0, 200, 10))
	_step(18000, func(): _snake(80000, 30000, 500, 0, 1, 5, 1, 1, 200, 10))
	_step(36000, func():
		_boomer(80000, 20000, 650, 1, 180000, 2000, 100)
		_boomer(80000, 40000, 650, 1, 180000, 2000, 100))
	_step(18000, func(): _snake(80000, 30000, 300, 0, Game.psh, 101, 0, 0, 200, 1))
	_step(18000, func():
		for y in [10000, 30000, 50000]:
			_snake(80000, y, 500, 0, 3, 5, 1, 1, 200, 10))
	_step(18000, func():
		_snake(80000, 30000, 300, 0, 0 + Game.psh / 2, 100, 1, 4, 200, 50)
		_snake(80000, 10000, 500, 0, 3, 5, 1, 2, 200, 10)
		_snake(80000, 50000, 500, 0, 3, 5, 1, 2, 200, 10))
	_step(8000, func(): _say("Careful!", 400, 300, 4))
	for round in 2:
		_step(500, func(): _say(">", 700, 300, 5))
		_step(500, func(): _say("V", 400, 500, 7))
		_step(500, func(): _say("<", 100, 300, 3))
		_step(500, func(): _say("^", 400, 150, 1))
	_step(18000, func():
		_del()
		_boomer(80000, 30000, 800, 1, 180000, 4000, 100)
		_boomer(0, 30000, 800, 1, 0, 4000, 100)
		_boomer(40000, 0, 800, 1, 270000, 4000, 100)
		_boomer(40000, 60000, 800, 1, 90000, 4000, 100))
	_step(18000, func():
		_snake(80000, 10000, 500, 0, 2, 4, 0, 2, 200, 11)
		_snake(80000, 50000, 500, 0, 2, 4, 0, 2, 200, 11)
		_snake(80000, 30000, 500, 0, 2, 4, 0, 1, 200, 11))
	_step(4000, func():
		_snake(80000, 10000, 500, 500, 0, 2, 7, 5, 200, 30)
		_snake(80000, 50000, 500, 500, 0, 2, 7, 5, 200, 30))
	_step(18000, func(): _boomer(80000, 5000, 650, 1, 225000, 2000, 100))
	_step(24000, func():
		for y in [10000, 20000, 30000, 40000, 50000]:
			_snake(80000, y, 150, 400, 1, 6, 7, Div.rand(1, 2), 200, 40))
	_step(18000, func(): _say("Danger! Danger!", 400, 300, 4))
	_step(18000, func():
		_del()
		if Game.psh >= 2:
			_boss = _snake(80000, 30000, 100, 900, 0, 100, 6, 7, 203, 1000 + Game.psh * 500)
		else:
			_boss = _snake(80000, 30000, 100, 900, 0, 100, 6, 5, 203, 1000 + Game.psh * 500)
		_show_life(_boss))
	_label("L1_boss")
	_step(7000, func():
		if not _boss_dead():
			_snake(80000, Div.rand(10000, 50000), 500, Div.rand(-500, 500), Div.rand(0, 2), 30,
					Div.rand(0, 3), Div.rand(0, 4), 200, Div.rand(15, 30)))
	_until(func() -> bool: return _boss_dead())
	_step(15000, func(): _say("Level 1 Won!!", 400, 300, 4))
	# ---------------------------------------------------------------- LEVEL 2
	_step(1200, func(): _say("Level 2 - Far away from home", 400, 300, 4), "L2")
	_step(6000, func():
		_del()
		_snake(80000, 30000, 500, 0, 5 + Game.psh * 2, 0, 1, 0, 204, 10))
	_step(24000, func():
		_jump(30000, 0, 700, 70, 20, 5, 1, 30, 207, 30)
		_jump(30000, 60000, 700, 70, 20, 5, 1, 30, 207, 30))
	_step(20000, func():
		_snake(80000, 15000, 400, 200, 5, 5, 8, 1, 200, 25)
		_snake(80000, 55000, 400, -200, 5, 5, 8, 1, 204, 25))
	_step(24000, func():
		_snake(80000, 50000, 300, -200, 4, 5, 9, 0, 209, 15)
		_snake(80000, 10000, 300, 200, 4, 5, 10, 0, 208, 15))
	_step(24000, func():
		_snake(80000, 10000, 300, 0, 1, 5, 2, 1, 204, 15)
		_snake(80000, 20000, 400, 0, 1, 5, 2, 1, 204, 15)
		_snake(96000, 30000, 500, 0, 0, 5, 2, 4, 204, 15)
		_snake(80000, 40000, 400, 0, 1, 5, 2, 1, 204, 15)
		_snake(80000, 50000, 300, 0, 1, 5, 2, 1, 204, 15)
		_snake(80000, 15000, 350, 0, 1, 5, 2, 2, 200, 15)
		_snake(80000, 25000, 450, 0, 1, 5, 2, 2, 200, 15)
		_snake(80000, 35000, 450, 0, 1, 5, 2, 2, 200, 15)
		_snake(80000, 45000, 350, 0, 1, 5, 2, 2, 200, 15))
	for life in [1, 10, 22]:
		_step(10000, func(): _snake(40000, 0, 0, 400, 6, 5, 11, 1, 220, life))
		_step(10000 if life != 22 else 24000, func(): _snake(40000, 60000, 0, -400, 6, 5, 11, 1, 220, life))
	_step(24000, func():
		_bomb(80000, 20000, 100, 0, 6, 550, 50)
		_bomb(80000, 30000, 100, 0, 9, 550, 50)
		_bomb(80000, 40000, 100, 0, 3, 550, 50))
	_step(24000, func():
		for p in [[55000, 0], [55000, 60000], [25000, 0], [25000, 60000], [80000, 20000], [80000, 40000], [0, 20000], [0, 40000]]:
			_jump(p[0], p[1], 700, 70, 20, 5, 0, 70, 207, 30))
	_step(24000, func():
		_boomer(80000, 30000, 800, 5, 180000, 1500, 200)
		_bomb(80000, 10000, 300, 200, 4, 550, 50)
		_bomb(80000, 50000, 300, -200, 4, 550, 50))
	_step(1000, func():
		if _loop_i == 25:
			_pick(Pickup.Kind.COMPANION, 80000, 30000)
			_snake(80000, 30000, 1500, 0, 25, 20, 0, 0, 220, 20)
		for i in 3:
			_snake(80000, Div.rand(0, 60000), 1500, Div.rand(-50, 50), 0, 2, 0, 0, 220, 70)
		_loop_i += 1)
	_until(func() -> bool: return _loop_i >= 50)
	_step(18000, func():
		_say("Danger! Danger!", 400, 300, 4)
		for y in [20000, 25000, 35000, 40000]:
			_pick(Pickup.Kind.MONEY, 85000, y)
		for y in [20000, 25000, 30000, 35000, 40000]:
			_pick(Pickup.Kind.MONEY, 90000, y)
		if Game.psh > 1:
			for y in [20000, 25000, 30000, 35000, 40000]:
				_pick(Pickup.Kind.MONEY, 95000, y)
		for y in [20000, 25000, 35000, 40000]:
			_pick(Pickup.Kind.SHIELD, 80000, y)
		_pick(Pickup.Kind.LIFE, 80000, 30000)
		_pick(Pickup.Kind.LIFE, 85000, 30000))
	_step(1, func():
		_del()
		_boss = Boss.spawn(0, 1000, 30000)
		_show_life(_boss), "L2_boss")
	_step(100, func(): pass)
	_until(func() -> bool: return _boss_dead())
	_step(0, func(): _say("Level 2 Won!!", 400, 300, 4))
