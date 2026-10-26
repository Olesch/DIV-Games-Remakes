class_name FieldCursor
extends Proc
## DIV PROCESS Cursor(player, cup, cdown, cleft, cright, cclick, cactiv, cnew): the selection cursor on the
## 6x5 element field of one player. Keys are read through InputMap actions "p<N>_up/down/left/right/click/build/new".
##   click: pick a tile / swap it with the picked one    build: build all units that match a recipe
##   new:   re-roll the whole field (the cursor spins for TIM_RESET frames, the new field appears afterwards)
## Input arrives as InputMap events (_unhandled_input), one action per key press.

var player := 0

var xpos := 0
var ypos := 0
var choosen: ChoosenCursor = null

var _spinning := false
var _held: Dictionary = {}   # click/build/new keys currently held (DIV: anti fast click afc)

var _up: StringName
var _down: StringName
var _left: StringName
var _right: StringName
var _click: StringName
var _build: StringName
var _new: StringName


func begin() -> void:
	_up = StringName("p%d_up" % player)
	_down = StringName("p%d_down" % player)
	_left = StringName("p%d_left" % player)
	_right = StringName("p%d_right" % player)
	_click = StringName("p%d_click" % player)
	_build = StringName("p%d_build" % player)
	_new = StringName("p%d_new" % player)
	graph = 2
	x = player * 188
	y = 0


func _frame() -> void:
	# While the field re-roll spins, the cursor turns 12 degrees per frame (DIV: angle loop of TIM_RESET frames).
	if _spinning:
		angle = maxi(0, angle - 12000)


func _unhandled_input(event: InputEvent) -> void:
	for a in [_click, _build, _new]:
		if event.is_action_released(a):
			_held.erase(a)
	if _spinning:
		return   # the cursor is blocked while the new field spins
	if event.is_echo():
		return
	# movement: one step per key press
	if event.is_action_pressed(_up) and ypos > 0:
		ypos -= 1
	elif event.is_action_pressed(_down) and ypos < Game.FIELD_H - 1:
		ypos += 1
	elif event.is_action_pressed(_left) and xpos > 0:
		xpos -= 1
	elif event.is_action_pressed(_right) and xpos < Game.FIELD_W - 1:
		xpos += 1
	x = xpos * 22 + player * 188
	y = ypos * 22
	sync_view()
	# click / build / new only work when none of the three is already held
	for a in [_click, _build, _new]:
		if event.is_action_pressed(a):
			var free := _held.is_empty()
			_held[a] = true
			if free:
				if a == _new:
					new_field()
				elif a == _click:
					click()
				else:
					build()
			get_viewport().set_input_as_handled()
			return


## Re-roll the field now; it is drawn (and the unit marks refreshed) after the spin.
func new_field() -> void:
	for fx in Game.FIELD_W:
		for fy in Game.FIELD_H:
			Game.field[player][fx][fy] = Game.random_tile()
	_spinning = true
	angle = Defs.TIM_RESET * 12000
	get_tree().create_timer(float(Defs.TIM_RESET) / Game.fps, true, true).timeout.connect(_end_spin)


func _end_spin() -> void:
	_spinning = false
	angle = 0
	world.draw_field(player)
	sync_view()


## Pick a tile, or swap the picked tile with the one under the cursor.
func click() -> void:
	if choosen == null or not is_instance_valid(choosen):
		choosen = world.spawn_choosen_cursor(self)
	else:
		var f: Array = Game.field[player]
		var temp: int = f[choosen.xpos][choosen.ypos]
		f[choosen.xpos][choosen.ypos] = f[xpos][ypos]
		f[xpos][ypos] = temp
		choosen.finish()
		choosen = null
		world.draw_field(player)


## Build every unit whose recipe is on the two bottom rows; the field then moves down two rows.
func build() -> void:
	if world.grimoire.search(player, 2):
		var f: Array = Game.field[player]
		for fx in Game.FIELD_W:
			for fy in range(4, 1, -1):
				f[fx][fy] = f[fx][fy - 2]
		for fx in Game.FIELD_W:
			for fy in range(1, -1, -1):
				f[fx][fy] = Game.random_tile()
		world.draw_field(player)
