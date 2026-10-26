class_name Tiles
extends RefCounted
## What the level values mean and how the editor shows them (DIV: PROCESS Levelzeichner and
## PROCESS get_Object of CASTEDIT.PRG, plus the value list in the comment at the end of the PRG).

## Value painted when an empty slot of a chooser is picked. In DIV get_Object then ended without
## RETURN(value), so it returned its own process id (an odd number); the shipped LEVEL1/2.DAT really contain
## such values (90143, 90241) in the object layer. Like those, it is stored but never drawn.
const EMPTY_PICK := -1

## Floor chooser (graphic 851), top row, slot x -> floor value. DIV: get_Object(x, 0, 0)
const FLOOR_ROW := [6, 22, 26, 28, 71, 11, 212, 214, 211, 213, 40, 20]
## Object chooser (graphic 852): row 0 = items, row 3 = enemies. DIV: get_Object(x, y, 1)
const ITEM_ROW := [22, 20, 54, 52, 118, 116, 7, 250, 74, 71, 11, 120, 121, 122, 59, 60, 61]
const ENEMY_ROW := [41, 39, 40, 17, 38, 13, 18]

const FLOOR_NAMES := {
	0: "nothing (shown as wall)", 6: "Floor", 22: "Wall", 26: "Arrow slit", 28: "Thin arrow slit",
	71: "Door, needs gold key", 11: "Door, needs silver key", 212: "Shut trapdoor",
	214: "Trapdoor opener (2 fields)", 211: "Trapdoor closer", 213: "Open trapdoor", 40: "Slime",
	20: "Secret passage",
}
const OBJECT_NAMES := {
	0: "nothing", 7: "Shield+", 10: "editor help: secret passage field", 11: "Silver key", 13: "Ghost",
	15: "editor help: walkable field", 17: "Ogre", 18: "Ogre stone thrower", 20: "Strong potion",
	22: "Potion", 38: "Ork hero", 39: "Ork archer", 40: "Helmet ork", 41: "Ork", 52: "Strong mana potion",
	54: "Mana potion", 59: "Sword skill+", 60: "Bow skill+", 61: "Mana skill+", 71: "Gold key",
	74: "All-healer", 116: "Many arrows", 118: "Arrows", 120: "Flame scroll", 121: "Ice scroll",
	122: "Heal scroll", 250: "Save point",
}

## Object value -> graphic of its marker (DIV: Potion(graph,...) / Enemy(Initgraph,...) calls).
const OBJECT_GRAPHS := {
	7: 69, 22: 60, 20: 61, 54: 63, 52: 64, 118: 66, 116: 67, 71: 127, 74: 74, 11: 128, 250: 72,
	120: 75, 121: 76, 122: 77, 59: 78, 60: 79, 61: 80,
	41: 200, 40: 210, 39: 205, 38: 220, 17: 215, 18: 230, 13: 225,
}


## Floor value -> tile graphic, 0 = no case (the cell keeps whatever was drawn there before).
## Floor and wall get a random variant 1 time in 11, re-rolled on every redraw.
static func floor_picture(value: int) -> int:
	match value:
		0:
			return 110   # and the editor turns the cell into a wall (22), see RoomView.redraw()
		22:
			return randi_range(110, 112) if randi_range(0, 10) == 0 else 110
		6:
			return randi_range(101, 104) if randi_range(0, 10) == 0 else 101
		20:
			return 136   # "Nur Editor": secret passage marker
		26:
			return 120
		28:
			return 121
		71:
			return 125
		40:
			return 132
		212:
			return 130
		211:
			return 134   # editor-only: trapdoor closer
		213:
			return 135   # editor-only: open trapdoor
		214:
			return 131
		11:
			return 126
	return 0


## DIV: get_Object(x, y, Picture) - the value under chooser cell (x, y).
static func pick(floor_layer: bool, x: int, y: int) -> int:
	if floor_layer:
		if y == 0 and x < FLOOR_ROW.size():
			return FLOOR_ROW[x]
	else:
		if y == 0 and x < ITEM_ROW.size():
			return ITEM_ROW[x]
		if y == 3 and x < ENEMY_ROW.size():
			return ENEMY_ROW[x]
	return EMPTY_PICK


static func describe(layer: int, value: int) -> String:
	var names: Dictionary = FLOOR_NAMES if layer == Game.Layer.FLOOR else OBJECT_NAMES
	if names.has(value):
		return "%s (%d)" % [names[value], value]
	if value == EMPTY_PICK:
		return "empty chooser slot (invisible)"
	return "unknown value %d (invisible)" % value
