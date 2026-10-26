class_name AntRule
extends RefCounted
## What an ant does on each colour: turn, and which colour it leaves behind.
## The DIV program keeps this in three tables:
##   KI[state]          turn per state (-1 left, 0 straight, 1 right)
##   Colour[state]      palette colour of a state
##   Anticolour[colour] state of a palette colour
## and on every step does: state = Anticolour[pixel]; dir += KI[state];
## pixel = Colour[(state + 1) mod states].
## Rule strings ("RL", "RLR", ...) build the same tables: letter n is the turn on colour n.

const ORIGINAL := "ORIGINAL"
const MAX_STATES := 16
## Palette colours for the states of rule strings: black, then the original's white (15),
## then bright colours of the DIV default palette.
const STATE_COLOURS: Array[int] = [0, 15, 22, 41, 59, 73, 89, 27, 57, 8, 45, 111, 140, 30, 99, 104]
## Quarter turns clockwise (DIV Dir: 0 up, 1 right, 2 down, 3 left).
const TURNS := {"L": 3, "R": 1, "S": 0, "N": 0, "F": 0, "U": 2}

var label: String
var turns := PackedByteArray()            # DIV: KI (as 0..3 quarter turns)
var colours := PackedByteArray()          # DIV: Colour
var state_of_colour := PackedByteArray()  # DIV: Anticolour (all 256 palette colours)
## Colour written for each state: Colour[(state + 1) mod states].
var paint := PackedByteArray()


## The tables exactly as ANT.PRG has them (the original's bug, kept as an option):
##   KI[2]=0,1;  Colour[2]=0,15;  Anticolour[15]=0,1;   (each table has one more entry than its number)
## KI[0] is 0, so black means "straight on", and Anticolour[1]=1 marks colour 1, not 15 (white),
## so the white the ant paints reads as black again.
static func original() -> AntRule:
	var rule := AntRule.new()
	rule.label = "Original bug (straight line)"
	rule.turns = PackedByteArray([0, 1, 0])
	rule.colours = PackedByteArray([0, 15, 0])
	rule.state_of_colour.resize(256)
	rule.state_of_colour[1] = 1
	rule._build_paint()
	return rule


## ANT.PRG's tables with the slip corrected (owner's decision 2026-10-26): Langton's ant.
##   Anticolour[15]=1 instead of Anticolour[1]=1 (the white the ant paints must read as state 1), and
##   KI[0]=1 instead of 0 (with only that table fixed the ant still never turns on black and
##   draws the same line). KI = 1,-1 = right on black, left on white.
## The result is exactly the rule string "RL" (same tables, same colours 0/15), which the game
## uses as its default; the autotest checks the two are identical.
static func original_fixed() -> AntRule:
	var rule := AntRule.new()
	rule.label = "RL"
	rule.turns = PackedByteArray([1, 3, 0])  # KI = 1,-1,0 (-1 = 3 quarter turns)
	rule.colours = PackedByteArray([0, 15, 0])
	rule.state_of_colour.resize(256)
	rule.state_of_colour[15] = 1
	rule._build_paint()
	return rule


## Parses a rule string such as "RL" (Langton's ant) or "LLRR". Letters: L, R, S (or N/F) = straight,
## U = U-turn. Returns null for invalid text.
static func parse(text: String) -> AntRule:
	var clean := text.strip_edges().to_upper()
	if clean.is_empty() or clean.length() > MAX_STATES:
		return null
	var rule := AntRule.new()
	rule.label = clean
	rule.state_of_colour.resize(256)
	for i in clean.length():
		var letter := clean[i]
		if not TURNS.has(letter):
			return null
		rule.turns.append(TURNS[letter])
		rule.colours.append(STATE_COLOURS[i])
		rule.state_of_colour[STATE_COLOURS[i]] = i
	rule._build_paint()
	return rule


static func from_setting(text: String) -> AntRule:
	return original() if text == ORIGINAL else parse(text)


static func is_valid(text: String) -> bool:
	return text == ORIGINAL or parse(text) != null


func state_count() -> int:
	return turns.size()


## For each state other than 0, a colour that reads as that state (used for the random-dots canvas).
func trigger_colours() -> PackedByteArray:
	var result := PackedByteArray()
	for state in range(1, state_count()):
		for colour in range(1, 256):
			if state_of_colour[colour] == state:
				result.append(colour)
				break
	return result


func _build_paint() -> void:
	paint.resize(state_count())
	for state in state_count():
		paint[state] = colours[(state + 1) % state_count()]
