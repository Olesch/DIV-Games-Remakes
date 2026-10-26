class_name HeroStats
extends RefCounted
## DIV: GLOBAL STRUCT Stat[0] (one record). Field order matches the save file layout
## (Hero_id comes first in the file but is a process id and is not kept here).

var max_life: int = 0        # Maxlife
var life: int = 0            # Life
var max_mana: int = 0        # Maxmana
var mana: int = 0            # Mana
var arrows: int = 0          # Arrows
var defense: int = 0         # Defense
var strength: int = 0        # Strength (sword)
var strength_exp: int = 0    # Strengthexp
var magic: int = 0           # Magic
var magic_exp: int = 0       # Magicexp
var bow: int = 0             # Bow
var bow_exp: int = 0         # Bowexp
var exp: int = 0             # Exp
var level: int = 0           # level
var condition: int = 0       # Condition (stamina)
var max_condition: int = 0   # maxCondition
var gold_keys: int = 0       # Goldkeys
var silver_keys: int = 0     # Silverkeys
var chosen_magic: int = 0    # ChoosenMagic: 0 none, 1 flame ball, 2 ice around, 3 heal
var heal_learned: int = 0    # HealLearned
var flame_learned: int = 0   # FlameBalllearned
var ice_learned: int = 0     # IceAroundLearned

## Number of ints the record occupies in a save file, including the leading Hero_id.
const FILE_INTS := 23


## Start values for a new game (DIV main code, `difficulty` = -3..3). `/` truncates like DIV.
static func new_game(difficulty: int) -> HeroStats:
	var s := HeroStats.new()
	s.max_life = 80 - difficulty * 10
	s.life = 10
	s.max_mana = 8 - difficulty
	s.mana = 4
	s.arrows = 3
	s.defense = 2
	s.strength = 3 - difficulty / 2
	s.magic = 8 - difficulty
	s.bow = 4 - difficulty / 2
	s.level = 1
	s.condition = 50 - difficulty * 8
	s.max_condition = 50 - difficulty * 8
	return s


## Fields in file order after Hero_id.
func to_ints() -> Array[int]:
	return [max_life, life, max_mana, mana, arrows, defense, strength, strength_exp, magic, magic_exp,
		bow, bow_exp, exp, level, condition, max_condition, gold_keys, silver_keys, chosen_magic,
		heal_learned, flame_learned, ice_learned]


func from_ints(v: PackedInt32Array, offset: int) -> void:
	max_life = v[offset]; life = v[offset + 1]; max_mana = v[offset + 2]; mana = v[offset + 3]
	arrows = v[offset + 4]; defense = v[offset + 5]; strength = v[offset + 6]
	strength_exp = v[offset + 7]; magic = v[offset + 8]; magic_exp = v[offset + 9]
	bow = v[offset + 10]; bow_exp = v[offset + 11]; exp = v[offset + 12]; level = v[offset + 13]
	condition = v[offset + 14]; max_condition = v[offset + 15]; gold_keys = v[offset + 16]
	silver_keys = v[offset + 17]; chosen_magic = v[offset + 18]; heal_learned = v[offset + 19]
	flame_learned = v[offset + 20]; ice_learned = v[offset + 21]
