extends Node
## Autoload "Game": the GLOBAL section of the DIV program (score, time, ammo, bonus flags).
## Bonus flags keep the original semantics: 0 = not yet reached, -1 = collected.

## Show a floating text at a screen position (DIV: Text / Textb processes).
signal popup(text: String, screen_pos: Vector2)

const PANORAMA_WIDTH := 2400
const VIEW_WIDTH := 800
const MAX_SCROLL := PANORAMA_WIDTH - VIEW_WIDTH

var score: int = 0                # DIV: Score
var time: int = 90                # DIV: Time (seconds left, game ends when < 0)
var ammo: int = 6                 # DIV: AmmoAmount
var max_ammo: int = 6             # DIV: Maxmunition (magazine size, grows with every bonus)
var shots: int = 0                # DIV: Schuesse
var hits: int = 0                 # DIV: Treffer
var birds_killed: int = 0         # DIV: Birdskillamount
var accuracy: int = 0             # DIV: Accuracy (percent)
var combo_bar: int = 0            # DIV: Combobalken
var flowers: int = 15             # DIV: Flowers (flowers left, -1 = bonus paid)
var hills: int = 2                # DIV: Berge
var castle: int = 4               # DIV: Burg
var combo_bonus: int = 0          # DIV: Combobonus
var time_bonus: int = 0           # DIV: Timebonus (clock shot)
var dead_bird_bonus: int = 0      # DIV: Deadbirdtext
var bonus_master: int = 0         # DIV: Bonusmaster (machine gun unlocked)
var scroll_x0: int = 0            # DIV: scroll[0].x0
var final_score: int = 0          # DIV: ENDSCORE
var over: bool = false


func reset() -> void:
	score = 0
	time = 90
	ammo = 6
	max_ammo = 6
	shots = 0
	hits = 0
	birds_killed = 0
	accuracy = 0
	combo_bar = 0
	flowers = 15
	hills = 2
	castle = 4
	combo_bonus = 0
	time_bonus = 0
	dead_bird_bonus = 0
	bonus_master = 0
	scroll_x0 = 0
	final_score = 0
	over = false


func add_score(value: int) -> void:
	score = maxi(score + value, 0)


## Text at a world position of the panorama (converted to the screen like DIV's Text()).
func popup_world(text: String, world_pos: Vector2) -> void:
	popup.emit(text, world_pos - Vector2(scroll_x0, 0))


func popup_screen(text: String, screen_pos: Vector2) -> void:
	popup.emit(text, screen_pos)


func scroll_by(dx: int) -> void:
	scroll_x0 = clampi(scroll_x0 + dx, 0, MAX_SCROLL)
