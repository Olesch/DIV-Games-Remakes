class_name Board
extends Node2D
## Draws the 32x24 grid of 10x10 tiles (DIV: REPAINT() with Map_Put onto the background graphic).
## Redraws only when the game state changes.

const DIR := "res://assets/fpg/undworld/"
const TILE := 10

const FLOOR_GRAPH := {
	Game.GRASS: 206, Game.DUG: 204, Game.HOLE: 210, Game.DIRT: 201, Game.LEAF: 209,
	Game.BRANCH: 208, Game.AIR: 211,
}
const UNIT_GRAPH := {
	1: 101, 2: 102, 3: 103, 4: 106, 5: 104, 6: 105,
	11: 111, 12: 112, 13: 113, 14: 116, 15: 114, 16: 115,
}
const BLOOD_P1 := 107
const BLOOD_P2 := 117
const AP_FULL := 90      # green dot
const AP_SOME := 91      # yellow dot
const AP_NONE := 92      # red dot

var _textures: Dictionary = {}


func _ready() -> void:
	Game.board_changed.connect(queue_redraw)


func _tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


func _floor_graph(i: int) -> int:
	var f := Game.floor_[i]
	var used := Game.stat[i] > 0
	match f:
		Game.FOOD_STORE:
			return 220 if used else 217
		Game.BIRTH_PLACE:
			return 216 if used else 218
		Game.TRAINER:
			return 221 if used else 219
	return FLOOR_GRAPH.get(f, 0)


func _draw() -> void:
	for y in Game.H:
		for x in Game.W:
			var i := y * Game.W + x
			var pos := Vector2(x * TILE, y * TILE)
			var g := _floor_graph(i)
			if g != 0:
				draw_texture(_tex(g), pos)
			var t := Game.typ[i]
			if t == 0 or not UNIT_GRAPH.has(t):
				continue
			draw_texture(_tex(UNIT_GRAPH[t]), pos)
			if Game.life[i] <= Game.life_max[i] / 2 and Game.life[i] > 0:
				draw_texture(_tex(BLOOD_P2 if t > 10 else BLOOD_P1), pos)
			if Game.move[i] < Game.move_max[i]:
				draw_texture(_tex(AP_NONE if Game.move[i] == 0 else AP_SOME), pos)
			elif Game.move_max[i] != 0:
				draw_texture(_tex(AP_FULL), pos)
