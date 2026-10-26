extends Node
## Global state (DIV GLOBAL: Pointsa, Pointsb, Activity). Autoload "Game".
## Naming: the original's Pointsb belongs to the LEFT player (player 1) and Pointsa to the RIGHT
## player (player 2): a ball leaving on the right side gives Pointsb points, and the win texts point
## "< Wins" (left) when Pointsb leads and "Wins >" (right) when Pointsa leads.
## Match options (new, owner's request 2026-10-26) live here too; their defaults are the values the
## original hard-codes, so an untouched options screen plays exactly like the original.

signal winner_declared(player: int)

const POINTS_LEADING := 2     # awarded when the scorer is not behind
const POINTS_TRAILING := 3    # awarded when the scorer is behind (catch-up bonus)

const DEFAULT_BALLS := 70             # DIV: FOR(x=0; x<35; x++) two balls
const DEFAULT_ACTIVITY := 4           # DIV: Activity=4
const DEFAULT_WIN_MARGIN := 500       # DIV: pointsa-500>pointsb
## Ball counts offered (always even: the original releases pairs).
const BALL_CHOICES: Array[int] = [2, 4, 6, 8, 10, 14, 20, 30, 40, 50, 60, 70, 80, 100, 120, 160, 200]
## Activity values offered. 5, 7 and 8+ are left out: with those steps the balls' x positions skip
## past the bats (DIV and the port test the overlap only at whole frames), so some balls can never be hit.
const ACTIVITY_CHOICES: Array[int] = [1, 2, 3, 4, 6]
const WIN_MARGIN_CHOICES: Array[int] = [50, 100, 200, 300, 500, 750, 1000, 2000]

var points: Array[int] = [0, 0]   # index 0 = player 1 (left, DIV Pointsb), 1 = player 2 (right, DIV Pointsa)
var winner: int = 0               # 0 = nobody yet, else 1 or 2

var ball_count := DEFAULT_BALLS
var activity := DEFAULT_ACTIVITY  # DIV Activity: speed factor of balls and bats (4*Activity px per frame)
var win_margin := DEFAULT_WIN_MARGIN
var one_ball_mode := false        # the original's commented-out "single balls at random" LOOP
var computer: Array[bool] = [false, false]   # per bat: DIV Ki=2 (computer) instead of Ki=1 (keys)


func reset() -> void:
	points = [0, 0]
	winner = 0


func reset_options() -> void:
	ball_count = DEFAULT_BALLS
	activity = DEFAULT_ACTIVITY
	win_margin = DEFAULT_WIN_MARGIN
	one_ball_mode = false
	computer = [false, false]


func options_are_original() -> bool:
	return (ball_count == DEFAULT_BALLS and activity == DEFAULT_ACTIVITY
		and win_margin == DEFAULT_WIN_MARGIN and not one_ball_mode and computer == [false, false])


## Pixels per frame of balls and bats (DIV: 4*Activity).
func step() -> int:
	return 4 * activity


## A ball left the field. `side` is -1 for the left edge (player 1 missed), +1 for the right edge.
func ball_out(side: int) -> void:
	var scorer := 0 if side > 0 else 1  # leaving on the right scores for player 1 (DIV: Pointsb+=)
	var other := 1 - scorer
	points[scorer] += POINTS_TRAILING if points[other] > points[scorer] else POINTS_LEADING
	_check_win()


func _check_win() -> void:
	if winner != 0:
		return
	if points[1] - win_margin > points[0]:
		winner = 2
	elif points[0] - win_margin > points[1]:
		winner = 1
	if winner != 0:
		winner_declared.emit(winner)
