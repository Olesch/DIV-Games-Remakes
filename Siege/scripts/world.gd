class_name World
extends Node2D
## The battlefield: main code of SIEGE after the splash pages. Every entity is a child of `procs` and runs
## in its own _physics_process (the project runs at the game's 18 ticks per second, DIV set_fps default).

## DIV: the skeleton limit check of the necromancer (art==13 compares the DYING unit's art, never true), so
## the original raises a skeleton for EVERY dying human next to a casting necromancer. false = like the PRG.
const ENFORCE_SKELETON_LIMIT := false

const UNIT_SCENE := preload("res://scenes/unit.tscn")
const SHOT_SCENE := preload("res://scenes/shot.tscn")
const EXPLOSION_SCENE := preload("res://scenes/explosion.tscn")
const ANIM_SCENE := preload("res://scenes/siege_anim.tscn")
const CURSOR_SCENE := preload("res://scenes/field_cursor.tscn")
const CHOOSEN_SCENE := preload("res://scenes/choosen_cursor.tscn")
const GAUGE_SCENE := preload("res://scenes/life_gauge.tscn")

@onready var field_view: FieldView = $FieldView
@onready var locator: UnitLocator = $UnitLocator
@onready var painter: Painter = $Painter
@onready var procs: Node2D = $Procs

var grimoire: Grimoire
## Field cursor of each player; null for a side played by the computer (it does not use its field).
var cursors: Array[FieldCursor] = []


func _ready() -> void:
	grimoire = Grimoire.new(self)
	Game.new_match()
	draw_field(0)
	draw_field(1)
	# players, life gauges (creation order as in the PRG)
	for p in 2:
		if Game.computer[p]:
			cursors.append(null)
			continue
		var c := CURSOR_SCENE.instantiate() as FieldCursor
		c.player = p
		_add_proc(c)
		cursors.append(c)
	for p in 2:
		var g := GAUGE_SCENE.instantiate() as LifeGauge
		g.player = p
		_add_proc(g)
	# DIV: //KI(1);  (commented out in the PRG; started here for every side chosen as "computer")
	for p in 2:
		if Game.computer[p]:
			var ki := ComputerPlayer.new()
			ki.name = "ComputerPlayer%d" % p
			ki.player = p
			ki.world = self
			add_child(ki)
	if OS.get_cmdline_user_args().has("--autotest"):
		add_child(preload("res://scripts/debug/autotest.gd").new())


func _unhandled_key_input(event: InputEvent) -> void:
	# new: Esc returns to the setup page before the splash pages (the original could only be quit with Ctrl+Esc)
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/setup.tscn")


# ---- DIV process creation ------------------------------------------------------------------------------
func _add_proc(p: Proc) -> void:
	p.world = self
	procs.add_child(p)
	p.begin()
	if p.alive:
		p.sync_view()


func units() -> Array[Node]:
	return get_tree().get_nodes_in_group(&"units")


func spawn_unit(art: int, player: int, from_x := 0, from_y := 0) -> Unit:
	var u := UNIT_SCENE.instantiate() as Unit
	u.art = art
	u.player = player
	u.from_x = from_x
	u.from_y = from_y
	_add_proc(u)
	return u


func spawn_shot(art: int, player: int, from_x: int, from_y: int) -> Shot:
	var s := SHOT_SCENE.instantiate() as Shot
	s.art = art
	s.player = player
	s.from_x = from_x
	s.from_y = from_y
	_add_proc(s)
	return s


func spawn_explosion(art: int, player: int, at_x: int, at_y: int) -> Explosion:
	var e := EXPLOSION_SCENE.instantiate() as Explosion
	e.art = art
	e.player = player
	e.x = at_x
	e.y = at_y
	_add_proc(e)
	return e


func spawn_anim(art: int, player: int) -> SiegeAnim:
	var a := ANIM_SCENE.instantiate() as SiegeAnim
	a.art = art
	a.player = player
	_add_proc(a)
	return a


func spawn_choosen_cursor(cursor: FieldCursor) -> ChoosenCursor:
	var c := CHOOSEN_SCENE.instantiate() as ChoosenCursor
	c.x = cursor.x
	c.y = cursor.y
	c.xpos = cursor.xpos
	c.ypos = cursor.ypos
	_add_proc(c)
	return c


## DIV Draw_field(player): show the field on the board and refresh the unit outlines.
func draw_field(player: int) -> void:
	field_view.show_field(player)
	grimoire.search(player, 1)


## A "human" unit died at (at_x, at_y): if the player's necromancer is casting, a skeleton rises there.
func raise_skeleton(player: int, at_x: int, at_y: int, dying_art: int) -> void:
	for hit: Unit in units():
		if hit.art == Defs.UnitArt.TOTENBESCHWOERER and hit.player == player and hit.graph >= 305 and hit.graph <= 308:
			var count := 0
			if ENFORCE_SKELETON_LIMIT:
				for other: Unit in units():
					if other.art == Defs.UnitArt.SKELETT and other.player == player:
						count += 1
			elif dying_art == Defs.UnitArt.SKELETT:
				count = 0   # (the PRG compares its own art here; never true for a "human")
			if count < Defs.PAR_TOTENBESCHWOERER:
				spawn_unit(Defs.UnitArt.SKELETT, player, at_x, at_y)
			return   # DIV: get_id() is exhausted after the inner loop, the outer loop ends
