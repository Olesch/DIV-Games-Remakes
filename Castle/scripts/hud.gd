class_name Hud
extends CanvasLayer
## DIV: Energyline / Conditionline (the red and green bars sliding in at the top, 800 px = full),
## CurWeap (weapon icon top-left, ghosted when out of arrows/mana) and Statistic (the parchment shown
## while PgDn is held, with live numbers, keys and learned scrolls).
## (Magicline exists in the PRG but its call is commented out, so there is no mana bar.)

var _hero: Hero
var _life_bar: Sprite2D
var _condition_bar: Sprite2D
var _weapon_icon: Sprite2D
var _panel: Sprite2D
var _panel_shown: bool = false
var _panel_origin := Vector2(400, 0)
var _numbers: Array[PixelLabel] = []     # label + getter pairs
var _number_getters: Array[Callable] = []
var _key_sprites: Array[Sprite2D] = []


func start(hero: Hero) -> void:
	_hero = hero
	# z (DIV, lower = on top): Energyline -5, Conditionline -3, panel -10, Picture -15, texts -256
	_condition_bar = _make_sprite(53, 3)
	_life_bar = _make_sprite(51, 5)
	_weapon_icon = _make_sprite(55, 0)
	_weapon_icon.position = Vector2(15, 25)
	_panel = _make_sprite(54, 10)
	_panel.visible = false
	_build_panel_labels()
	_update_bars()
	_update_weapon_icon()


func _make_sprite(code: int, z: int) -> Sprite2D:
	var s := Sprite2D.new()
	Gfx.apply(s, code)
	s.z_index = z
	add_child(s)
	return s


func _add_number(x: float, y: float, align: int, getter: Callable) -> void:
	var l := PixelLabel.create("0", x, y, align)
	l.z_index = 256
	l.visible = false
	add_child(l)
	_numbers.append(l)
	_number_getters.append(getter)


func _build_panel_labels() -> void:
	# DIV Statistic: Write_int(1, dx+x, dy+y, align, OFFSET stat[..].field) - offsets relative to the panel
	var st := Game.stat
	_add_number(121, 61, 5, func() -> int: return st.life)
	_add_number(136, 61, 3, func() -> int: return st.max_life)
	_add_number(121, 96, 5, func() -> int: return st.mana)
	_add_number(136, 96, 3, func() -> int: return st.max_mana)
	_add_number(121, 128, 5, func() -> int: return st.arrows)
	_add_number(121, 166, 5, func() -> int: return st.defense)
	_add_number(119, 210, 5, func() -> int: return st.condition)
	_add_number(135, 210, 3, func() -> int: return st.max_condition)
	_add_number(250, 56, 3, func() -> int: return st.strength)
	_add_number(250, 95, 3, func() -> int: return st.magic)
	_add_number(250, 127, 3, func() -> int: return st.bow)
	_add_number(250, 168, 3, func() -> int: return st.exp)
	_add_number(250, 210, 3, func() -> int: return st.level)
	_add_number(206, 255, 4, func() -> int: return st.flame_learned)
	_add_number(281, 255, 4, func() -> int: return st.ice_learned)
	_add_number(354, 255, 4, func() -> int: return st.heal_learned)


func _physics_process(_delta: float) -> void:
	if _hero == null or not is_instance_valid(_hero):
		return
	_update_bars()
	_update_weapon_icon()
	_update_panel()


func _update_bars() -> void:
	var st := Game.stat
	# DIV: x = (life*800)/maxlife - 800 (graphic is 800 wide, anchored top-left, y = -10 / -5)
	_life_bar.position = Vector2((st.life * 800) / st.max_life - 800, -10)
	_condition_bar.position = Vector2((st.condition * 800) / st.max_condition - 800, -5)


func _update_weapon_icon() -> void:
	var st := Game.stat
	var ghost := false
	var g := _weapon_icon_graph
	if _hero.weap == 0:
		g = 55
	if _hero.weap == 1:
		if st.arrows < 1:
			ghost = true
		g = 56
	if _hero.weap == 2:
		if st.chosen_magic == 1:
			if st.mana < 1:
				ghost = true
			g = 57
		if st.chosen_magic == 2:
			if st.mana < 3:
				ghost = true
			g = 58
		if st.chosen_magic == 3:
			if st.mana < 1:
				ghost = true
			g = 59
	if g != _weapon_icon_graph:
		_weapon_icon_graph = g
		Gfx.apply(_weapon_icon, g)
	_weapon_icon.modulate.a = 0.5 if ghost else 1.0


var _weapon_icon_graph: int = 55


func _unhandled_input(event: InputEvent) -> void:
	if _hero == null or not is_instance_valid(_hero):
		return
	if event.is_action_pressed(&"hero_stats", false, true):
		_open_panel()
	elif event.is_action_released(&"hero_stats"):
		_close_panel()


func _open_panel() -> void:
	if _panel_shown:
		return
	# the panel moves to the other corner when the hero is in the top right quarter
	if _hero.ix > 400 and _hero.iy < 300:
		_panel_origin = Vector2(0, 300)
	else:
		_panel_origin = Vector2(400, 0)
	_panel_shown = true
	_panel.position = _panel_origin
	_panel.visible = true
	for i in _numbers.size():
		_numbers[i].anchor = _panel_origin + _BASE[i]
		_numbers[i].visible = true
	_update_panel()


func _close_panel() -> void:
	_panel_shown = false
	_panel.visible = false
	for l in _numbers:
		l.visible = false
	_clear_keys()


func _update_panel() -> void:
	if not _panel_shown:
		return
	for i in _numbers.size():
		_numbers[i].set_value(str(_number_getters[i].call()))
		_numbers[i]._reposition()
	_draw_keys()


## Label offsets inside the parchment (see _build_panel_labels).
const _BASE := [Vector2(121, 61), Vector2(136, 61), Vector2(121, 96), Vector2(136, 96), Vector2(121, 128),
	Vector2(121, 166), Vector2(119, 210), Vector2(135, 210), Vector2(250, 56), Vector2(250, 95),
	Vector2(250, 127), Vector2(250, 168), Vector2(250, 210), Vector2(206, 255), Vector2(281, 255),
	Vector2(354, 255)]


func _clear_keys() -> void:
	for s in _key_sprites:
		s.queue_free()
	_key_sprites.clear()


## DIV: Picture(127/128, x+counter*10+40, y+250/265) every frame while the panel is open.
func _draw_keys() -> void:
	_clear_keys()
	var st := Game.stat
	for i in maxi(st.gold_keys, 0):
		var s := _make_sprite(127, 15)
		s.position = _panel_origin + Vector2(i * 10 + 40, 250)
		_key_sprites.append(s)
	for i in maxi(st.silver_keys, 0):
		var s := _make_sprite(128, 15)
		s.position = _panel_origin + Vector2(i * 10 + 40, 265)
		_key_sprites.append(s)
