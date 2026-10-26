extends Node
## Autoload "Settings": values SNIPGAME.PRG hard-codes, adjustable on the options screen (new,
## owner's request 2026-10-26). The defaults are exactly the original game. Kept for the session
## only (each start is the original game again).

## DIV: Sniper(95,370,0) + FROM x=0 TO 768 STEP 50 -> 1 + 16 rifle snipers.
const DEFAULT_SNIPERS := 17
## Snipers 18-21 take the places of the four commented-out Sniper(...) calls.
const MAX_SNIPERS := 21
## Balloons per second. DIV: Ballon(...); FRAME(2400) at 24 fps -> one per second.
const BALLOON_RATES: Array[float] = [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0, 8.0, 12.0]
const DEFAULT_BALLOON_RATE := 1.0

var sniper_count := DEFAULT_SNIPERS
var balloons_per_second := DEFAULT_BALLOON_RATE
## Weapon types in use (Sniper.Mode -> on). The column takes the enabled ones in turn.
var _weapons: Dictionary = {}


func _ready() -> void:
	reset_to_defaults()


func reset_to_defaults() -> void:
	sniper_count = DEFAULT_SNIPERS
	balloons_per_second = DEFAULT_BALLOON_RATE
	_weapons = {Sniper.Mode.NORMAL: true, Sniper.Mode.MINIGUN: false, Sniper.Mode.GRENADE: false}


func is_default() -> bool:
	return (sniper_count == DEFAULT_SNIPERS and is_equal_approx(balloons_per_second, DEFAULT_BALLOON_RATE)
		and enabled_modes() == [Sniper.Mode.NORMAL])


func step_sniper_count(direction: int) -> void:
	sniper_count = clampi(sniper_count + direction, 1, MAX_SNIPERS)


func step_balloon_rate(direction: int) -> void:
	var index := BALLOON_RATES.find(balloons_per_second)
	balloons_per_second = BALLOON_RATES[clampi(index + direction, 0, BALLOON_RATES.size() - 1)]


func is_weapon_on(mode: Sniper.Mode) -> bool:
	return _weapons[mode]


## Switches a weapon type on or off. Returns false (and changes nothing) for the last one in use.
func set_weapon(mode: Sniper.Mode, on: bool) -> bool:
	if not on and enabled_modes() == [mode]:
		return false
	_weapons[mode] = on
	return true


## Enabled weapon types in the order rifle, minigun, grenade launcher.
func enabled_modes() -> Array[Sniper.Mode]:
	var modes: Array[Sniper.Mode] = []
	for mode: Sniper.Mode in [Sniper.Mode.NORMAL, Sniper.Mode.MINIGUN, Sniper.Mode.GRENADE]:
		if _weapons[mode]:
			modes.append(mode)
	return modes
