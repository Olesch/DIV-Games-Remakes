extends Node
## Global state of the match (DIV: GLOBAL Panzersteama / Panzersteamb) plus shared constants.

signal winner_declared(team: int)

const FPS := 24                          # DIV: set_fps(24,0); logic runs once per physics tick (24 Hz)
const WORLD_SIZE := Vector2(1600, 1200)  # DIV: graphic 1 "Landkarte"

## Living tanks per team, index 1 and 2 (DIV: Panzersteama / Panzersteamb). Index 0 unused.
var team_count: Array[int] = [0, 0, 0]
## Tank each human player (index 1 and 2) currently drives; null if none left.
var player_tank: Array[Node2D] = [null, null, null]
## Life of the tank each player drove last (what the original shows with write_int).
var player_life: Array[int] = [0, 0, 0]
var winner: int = 0


func reset() -> void:
	team_count = [0, 0, 0]
	player_tank = [null, null, null]
	player_life = [0, 0, 0]
	winner = 0


func tank_died(team: int) -> void:
	team_count[team] -= 1
	if winner == 0 and team_count[team] <= 0:
		winner = 3 - team
		winner_declared.emit(winner)
