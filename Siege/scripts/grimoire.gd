@warning_ignore_start("integer_division")
class_name Grimoire
extends RefCounted
## DIV PROCESS Search_Units(player, art) "Das Zauberbuch": the unit recipes.
## The two bottom rows of the player's 6x5 field (rows 3 and 4) are matched against the recipes.
## Tiles: 1 wood, 2 metal, 3 fire, 4 magic, 0 = any. Recipes are written like reading a page: row 3 then row 4.
## mode 1 = only mark complete recipes (outlines drawn by UnitLocator), mode 2 = build the units.
## Recipes are tried in this order; once a 2-column slot is used by a recipe, later ones cannot reuse it.
##   w = recipe width in tiles (6, 4 or 2)   t = tech level needed (always satisfied: tech is 6)
##   unique: [kind, art] -> only one such unit/animation of the player may exist
##   make:   what is created (Unit, Animation or the meteor shower)

const RECIPES := [
	# --- 6x2 ---
	{"name": "Magier", "w": 6, "t": 3, "marker": 200, "make": ["anim", Defs.AnimArt.MAGIER],
		"f": [0, 0, 0, 0, 0, 0, 1, 1, 4, 4, 4, 4]},
	{"name": "Turm", "w": 6, "t": 4, "marker": 230, "make": ["unit", Defs.UnitArt.TURM],
		"unique": ["unit", Defs.UnitArt.TURM], "f": [3, 1, 1, 1, 1, 3, 1, 2, 1, 1, 2, 1]},
	{"name": "Pest", "w": 6, "t": 5, "marker": 250, "make": ["anim", Defs.AnimArt.PEST],
		"f": [0, 0, 1, 1, 0, 0, 4, 4, 4, 4, 4, 4]},
	{"name": "Luftschiff", "w": 6, "t": 5, "marker": 270, "make": ["unit", Defs.UnitArt.LUFTSCHIFF],
		"f": [1, 1, 1, 1, 1, 1, 3, 2, 3, 1, 3, 1]},
	{"name": "Golem", "w": 6, "t": 6, "marker": 280, "make": ["unit", Defs.UnitArt.GOLEM],
		"f": [2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 2]},
	{"name": "Drache", "w": 6, "t": 6, "marker": 290, "make": ["unit", Defs.UnitArt.DRACHE],
		"f": [4, 3, 4, 3, 4, 3, 3, 4, 3, 4, 3, 4]},
	{"name": "Totenbeschwoerer", "w": 6, "t": 6, "marker": 300, "make": ["unit", Defs.UnitArt.TOTENBESCHWOERER],
		"unique": ["unit", Defs.UnitArt.TOTENBESCHWOERER], "f": [4, 3, 4, 1, 4, 2, 4, 4, 4, 4, 4, 4]},
	# --- 4x2 (two possible positions) ---
	{"name": "Katapult", "w": 4, "t": 2, "marker": 150, "make": ["anim", Defs.AnimArt.KATAPULT],
		"f": [3, 3, 3, 3, 1, 2, 2, 1]},
	{"name": "Balliste", "w": 4, "t": 2, "marker": 160, "make": ["anim", Defs.AnimArt.BALLISTE],
		"f": [1, 1, 1, 1, 2, 3, 3, 2]},
	{"name": "Ramme", "w": 4, "t": 1, "marker": 130, "make": ["unit", Defs.UnitArt.RAMME],
		"f": [0, 0, 0, 0, 1, 1, 1, 2]},
	{"name": "Arbeiter", "w": 4, "t": 4, "marker": 210, "make": ["anim", Defs.AnimArt.ARBEITER],
		"unique": ["anim", Defs.AnimArt.ARBEITER], "f": [2, 1, 2, 1, 1, 2, 1, 2]},
	{"name": "Elefant", "w": 4, "t": 4, "marker": 220, "make": ["unit", Defs.UnitArt.ELEFANT],
		"f": [4, 1, 1, 4, 4, 2, 2, 4]},
	# --- 2x2 (three possible positions) ---
	{"name": "Ritter", "w": 2, "t": 3, "marker": 180, "make": ["unit", Defs.UnitArt.RITTER],
		"f": [2, 3, 2, 3]},
	{"name": "Krieger", "w": 2, "t": 1, "marker": 100, "make": ["unit", Defs.UnitArt.KRIEGER],
		"f": [0, 0, 2, 2]},
	{"name": "Bogenschuetze", "w": 2, "t": 1, "marker": 110, "make": ["anim", Defs.AnimArt.BOGENSCHUETZE],
		"f": [0, 0, 1, 3]},
	{"name": "Bomber", "w": 2, "t": 2, "marker": 140, "make": ["unit", Defs.UnitArt.BOMBER],
		"f": [3, 3, 3, 3]},
	{"name": "Ranken", "w": 2, "t": 3, "marker": 170, "make": ["unit", Defs.UnitArt.RANKEN],
		"unique": ["unit", Defs.UnitArt.RANKEN], "f": [4, 4, 1, 1]},
	{"name": "Wolke", "w": 2, "t": 3, "marker": 190, "make": ["unit", Defs.UnitArt.WOLKE],
		"unique": ["unit", Defs.UnitArt.WOLKE], "f": [4, 4, 4, 4]},
	{"name": "Meteor", "w": 2, "t": 5, "marker": 240, "make": ["meteor"],
		"f": [4, 4, 3, 3]},
]

var world: World


func _init(w: World) -> void:
	world = w


## Returns true when something was created (mode 2).
func search(player: int, mode: int) -> bool:
	var used := [false, false, false]    # DIV used[0..2]: the three 2-column slots
	var created := false
	if mode == 1:
		world.locator.clear_player(player)   # the DIV code erases the player's 132x44 area of graph 29

	for recipe: Dictionary in RECIPES:
		var w: int = recipe["w"]
		var positions: Array = [0] if w == 6 else ([0, 1] if w == 4 else [0, 1, 2])
		for pos: int in positions:
			var slots: Array = [0, 1, 2] if w == 6 else ([pos, pos + 1] if w == 4 else [pos])
			if not _matches(recipe, player, pos, slots, used):
				continue
			if mode == 1:
				world.locator.add_mark(player, recipe["marker"], player * 188 + pos * 44)
			else:
				created = true
				_make(recipe["make"], player)
			for s: int in slots:
				used[s] = true
	return created


func _matches(recipe: Dictionary, player: int, pos: int, slots: Array, used: Array) -> bool:
	if Game.tech[player] < int(recipe["t"]):
		return false
	if recipe.has("unique") and _exists(recipe["unique"], player):
		return false
	for s: int in slots:
		if used[s]:
			return false
	var w: int = recipe["w"]
	var f: Array = recipe["f"]
	for chpos in w * 2:
		if f[chpos] != 0 and f[chpos] != Game.field[player][chpos % w + pos * 2][chpos / w + 3]:
			return false
	return true


func _exists(unique: Array, player: int) -> bool:
	if unique[0] == "unit":
		for hit: Unit in world.units():
			if hit.art == unique[1] and hit.player == player:
				return true
	else:
		for hit: SiegeAnim in world.get_tree().get_nodes_in_group(&"animations"):
			if hit.art == unique[1] and hit.player == player:
				return true
	return false


func _make(make: Array, player: int) -> void:
	match make[0]:
		"unit":
			world.spawn_unit(make[1], player)
		"anim":
			world.spawn_anim(make[1], player)
		"meteor":
			# one random x for the whole shower; every part gets its own sideways speed
			var shower_x := 160 + randi_range(-10, 10) + (1 - player * 2) * 30
			for i in Defs.PAR_METEOR:
				world.spawn_shot(Defs.ShotArt.METEOR, player, shower_x, 0)
