class_name Level
extends Node2D
## The game screen: loads levels, spawns lemmings, handles the player's skills and decides win/lose.
## (DIV: main code + processes Lomminger, Shower, Cursor, Items.)
## Game logic runs once per physics tick = one DIV frame (24 per second).

const LEMMING_SCENE := preload("res://scenes/lemming.tscn")
const GAME_TICK_SECONDS := 1.0  # DIV: FRAME(2400) = 24 frames before the next level

@onready var world: Node2D = $World
@onready var terrain_sprite: Sprite2D = $World/TerrainSprite
@onready var lemmings_root: Node2D = $World/Lemmings
@onready var hud: Hud = $Hud
@onready var cursor: Cursor = $CursorLayer/Cursor

var terrain := Terrain.new()
var lemmings: Array[Lemming] = []
var scroll_x := 0                 # DIV: Levelxpos (0..-320)
var spawn_cell := Vector2i.ZERO
var exit_cell := Vector2i.ZERO

var _wait_new := 0                # DIV: WaitNew (ticks since the last spawn)
var _kill_count := 0              # DIV: KillCount (Backspace nuke progress)
var _time_counter := 0            # DIV: Timecounter
var _anti_fast := false           # DIV: Antifastdig (one action per click for ladder/stopper/dig)
var _busy := false                # banner shown, waiting before the next level
var _game_finished := false
var _target: Lemming = null       # lemming under the pointer
var debug_mouse: Variant = null   # debug: Vector2i replaces the real mouse position


func _ready() -> void:
	terrain_sprite.texture = null
	start_level()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(AutoTest.new())


func start_level() -> void:
	var code: int = Defs.LEVEL_ORDER[Game.level_counter]
	var data: Dictionary = Defs.LEVELS[code]
	var params: Array = data["params"]
	terrain.load_level(code)
	terrain_sprite.texture = terrain.texture
	spawn_cell = data["spawn"]
	exit_cell = data["exit"]
	Game.lemming_total = params[0]
	Game.emerge_max = params[1]
	Game.emerge_interval = Game.emerge_max
	Game.time_left = params[2] * 5
	Game.to_save = params[3]
	for i in 9:
		Game.skill_counts[i + 1] = params[4 + i]
	Game.saved = 0
	_wait_new = 0
	_kill_count = 0
	_time_counter = 0
	_busy = false
	for l in lemmings:
		l.queue_free()
	lemmings.clear()
	# DIV: loops run 0..LommingsNumber inclusive -> number + 1 lemmings
	for i in Game.lemming_total + 1:
		var l := LEMMING_SCENE.instantiate() as Lemming
		lemmings.append(l)
		lemmings_root.add_child(l)
		l.setup(terrain, lemmings, exit_cell)
	hud.hide_banner()
	Game.stats_changed.emit()


func _process(_delta: float) -> void:
	world.position.x = scroll_x
	terrain.flush()


func _physics_process(_delta: float) -> void:
	if _game_finished:
		return
	_scroll()
	if _busy:
		return
	_update_target()
	_apply_mouse_skills()
	_apply_held_keys()
	_advance_clock()
	if not Game.paused:
		for sub in Game.turbo_extra + 1:
			_spawn_step()
			_move_lemmings()
	_check_level_end()
	Game.stats_changed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"back"):
		Game.show_level_select()  # new: Esc leaves the level (the original had no way back)
		return
	if _game_finished:
		if event.is_action_pressed(&"confirm") or event.is_action_pressed(&"click_left"):
			Game.show_level_select()
		return
	for i in 9:
		if event.is_action_pressed("skill_%d" % (i + 1)):
			Game.selected_skill = (i + 1) as Defs.Skill
	if event.is_action_pressed(&"nuke") and _kill_count == 0:
		_kill_count = 1
	if event.is_action_pressed(&"turbo", false, true):
		Game.turbo_extra = 0 if Game.turbo_extra != 0 else Defs.TURBO_EXTRA_STEPS
	if event.is_action_pressed(&"pause", false, true):
		Game.paused = not Game.paused
	if event.is_action_pressed(&"click_left", false, true):
		var m := _mouse()
		if m.y >= Defs.PANEL_Y:
			_panel_click(m)


## Skill panel buttons are mouse clickable too (new; the original only used the keys 1-9, O, P, Backspace, +/-).
func _panel_click(m: Vector2i) -> void:
	if m.x < 180:
		Game.selected_skill = (m.x / 20 + 1) as Defs.Skill
	elif m.y < 208:
		if m.x >= 222 and m.x < 244:
			Game.turbo_extra = 0 if Game.turbo_extra != 0 else Defs.TURBO_EXTRA_STEPS
		elif m.x >= 244 and m.x < 258:
			Game.paused = not Game.paused
		elif m.x >= 258 and m.x < 279:
			Game.emerge_interval = maxi(Defs.MIN_EMERGE, Game.emerge_interval - 5)
		elif m.x >= 279 and m.x < 300:
			Game.emerge_interval = mini(Game.emerge_max, Game.emerge_interval + 5)
		elif m.x >= 300 and _kill_count == 0:
			_kill_count = 1


func _mouse() -> Vector2i:
	if debug_mouse != null:
		return debug_mouse
	return Vector2i(get_viewport().get_mouse_position().floor())


func _scroll() -> void:
	# DIV: Shower process
	if Input.is_action_pressed(&"scroll_left") and scroll_x < 0:
		scroll_x += Defs.SCROLL_STEP
	if Input.is_action_pressed(&"scroll_right") and scroll_x > Defs.SCROLL_MIN:
		scroll_x -= Defs.SCROLL_STEP


## Nearest lemming to the pointer (DIV: Cursor, shortestdist < 8).
func _update_target() -> void:
	var m := _mouse()
	var best_dist := 500
	var best: Lemming = null
	for l in lemmings:
		if l.state == Lemming.State.IDLE:
			continue  # (original also considered not yet emerged lemmings sitting at 0,0)
		var dx := m.x - scroll_x - l.cell.x
		var dy := m.y - l.cell.y
		var dist := int(sqrt(float(dx * dx + dy * dy)))
		if dist < best_dist:
			best_dist = dist
			best = l
	_target = best if best_dist < Defs.PICK_RADIUS else null
	cursor.near_lemming = _target != null
	cursor.override_position = Vector2(m) if debug_mouse != null else null


func _apply_mouse_skills() -> void:
	var left := Input.is_action_pressed(&"click_left")
	var right := Input.is_action_pressed(&"click_right")
	if _target != null and _mouse().y < Defs.PANEL_Y:
		if left:
			_left_click_skill(_target)
		if right:
			_right_click_skill(_target)
	if not left and not right:
		_anti_fast = false


func _take(skill: Defs.Skill) -> void:
	Game.skill_counts[skill] -= 1


func _has(skill: Defs.Skill) -> bool:
	return Game.skill_counts[skill] > 0 and Game.selected_skill == skill


## DIV: Cursor, IF(mouse.left) block.
func _left_click_skill(l: Lemming) -> void:
	var walking := l.state == Lemming.State.WALK
	if _has(Defs.Skill.CLIMB) and not l.can_climb:
		_take(Defs.Skill.CLIMB)
		l.can_climb = true
	if _has(Defs.Skill.UMBRELLA) and not l.has_umbrella:
		_take(Defs.Skill.UMBRELLA)
		l.has_umbrella = true
	if _has(Defs.Skill.JUMP) and not l.can_jump:
		_take(Defs.Skill.JUMP)
		l.can_jump = true
	if _has(Defs.Skill.EXPLODE) and l.countdown == 0:
		_take(Defs.Skill.EXPLODE)
		l.countdown = 1
	if not _anti_fast and _has(Defs.Skill.LADDER) and (walking or (l.is_working() and l.fallen > 15)):
		_take(Defs.Skill.LADDER)
		l.command_state(Lemming.State.BUILD)
		_anti_fast = true
	if _has(Defs.Skill.STOPPER) and not _anti_fast:
		if walking or l.is_working():
			_take(Defs.Skill.STOPPER)
			l.command_state(Lemming.State.STOP)
			_anti_fast = true
		elif l.state == Lemming.State.STOP:
			_take(Defs.Skill.STOPPER)  # (un-stopping costs another stopper, as in the original)
			l.command_state(Lemming.State.WALK)
			_anti_fast = true
	_try_dig(l, Defs.Skill.DIG_FRONT, Lemming.State.DIG_FRONT)
	_try_dig(l, Defs.Skill.DIG_DIAGONAL, Lemming.State.DIG_DIAGONAL)
	_try_dig(l, Defs.Skill.DIG_DOWN, Lemming.State.DIG_DOWN)


func _try_dig(l: Lemming, skill: Defs.Skill, dig_state: Lemming.State) -> void:
	if _anti_fast or not _has(skill):
		return
	if (l.state == Lemming.State.WALK or l.is_working()) and l.state != dig_state:
		_take(skill)
		l.command_state(dig_state)
		_anti_fast = true


## DIV: Cursor, IF(mouse.right) block: jump right now / turn around.
func _right_click_skill(l: Lemming) -> void:
	var digging := l.state in [Lemming.State.DIG_FRONT, Lemming.State.DIG_DIAGONAL, Lemming.State.DIG_DOWN]
	if _has(Defs.Skill.JUMP) and (l.state == Lemming.State.WALK or digging):
		_take(Defs.Skill.JUMP)
		l.command_state(Lemming.State.JUMP)
	if _has(Defs.Skill.STOPPER) and not _anti_fast:
		_take(Defs.Skill.STOPPER)
		l.dir = -l.dir
		_anti_fast = true


func _apply_held_keys() -> void:
	# DIV: Backspace nuke - makes one lemming after the other explode (4 frames apart)
	if _kill_count != 0:
		var index := _kill_count / 4
		if index <= Game.lemming_total:
			lemmings[index].countdown = 1
			_kill_count += 1
			Game.emerge_interval = Defs.MIN_EMERGE
		else:
			_kill_count = 0
	if Input.is_action_pressed(&"emerge_slower") and Game.emerge_interval < Game.emerge_max:
		Game.emerge_interval += 1
	if Input.is_action_pressed(&"emerge_faster") and Game.emerge_interval > Defs.MIN_EMERGE:
		Game.emerge_interval -= 1


func _advance_clock() -> void:
	if not Game.paused:
		_time_counter += Game.turbo_extra + 1
	if _time_counter > 24:
		Game.time_left -= 1
		_time_counter -= 25


func _spawn_step() -> void:
	_wait_new += 1
	if _wait_new > Game.emerge_interval:
		for l in lemmings:
			if l.state == Lemming.State.IDLE:
				l.spawn(spawn_cell)
				_wait_new = 0
				break


func _move_lemmings() -> void:
	for l in lemmings:
		if l.state == Lemming.State.IDLE:
			break  # DIV: "CASE 0: BREAK" leaves the whole lemming loop (lemmings emerge in order)
		l.tick()


func _check_level_end() -> void:
	var saved := 0
	var away := 0
	for l in lemmings:
		if l.state == Lemming.State.SAVED:
			saved += 1
			away += 1
		elif l.state == Lemming.State.DEAD:
			away += 1
	# DIV cheat: O+G wins the level (O alone is the turbo key)
	if Input.is_action_pressed(&"turbo") and Input.is_action_pressed(&"cheat_g"):
		saved = 500
		away = 0
		Game.time_left = 0
	Game.saved = saved
	if Game.time_left < 1 or away > Game.lemming_total:
		_busy = true
		if saved > Game.to_save:
			Game.level_counter += 1
			if Defs.LEVEL_ORDER[Game.level_counter] == Defs.END_LEVEL:
				# DIV: EXIT("BYE!  YOUR LEVEL:", Levelcounter)
				hud.show_banner("BYE!  YOUR LEVEL: %d" % Game.level_counter)
				_game_finished = true
				return
			hud.show_banner("Next Level!")
		else:
			hud.show_banner("Try again!")  # new: the original silently restarted the level
		get_tree().create_timer(GAME_TICK_SECONDS).timeout.connect(start_level)

