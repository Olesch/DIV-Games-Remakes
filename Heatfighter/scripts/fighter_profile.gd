class_name FighterProfile
extends RefCounted
## Per-character tuning. The original has two near-identical blocks of code: "Template" (used by the
## Template and Chain graphics) and "Eigen". Everything that differs in numbers lives here; the few
## structural differences are branches on `kind` in fighter.gd.

enum Kind { TEMPLATE, EIGEN }


## One punch/kick: a window of animation ticks in which it can hit once (DIV: Punchwait).
class Attack:
	var duration: int          # state ends when frame_var > duration
	var hit_after: int = -1    # may hit while frame_var > hit_after and < hit_before
	var hit_before: int
	var reach: int             # hit centre is x + reach * facing
	var x_limit: int           # |dx| < x_limit and |dy| < y_limit
	var y_offset: int
	var y_limit: int
	var advance: int = 0       # lunges forward while the hit window is open
	var recoil: int = 0        # attacker is pushed back on a hit
	var slz: int               # SLZ (stun) taken off the victim
	var damage: int
	var fly_x: int             # launch speed added to the victim
	var fly_y: int
	var push: int              # instant displacement of the victim
	var type: int              # Defs.AttackType
	var spark_dx: int          # where the hit spark appears
	var spark_dy: int
	var spark_size: int
	var spark_graph: int = 4
	var graph_base: int = -1   # graphic (-1: keep the previous one)
	var graph_rules: Array = []  # [[frame_var_below, graphic], ...] applied in order


var kind: Kind = Kind.TEMPLATE
var gfx_set: String = "hfchain"

# Walking / jumping (per tick, DIV units)
var walk_speed: int
var jump_speed: int
var walk_jump_lr: int
var air_steer: int
# Graphics (DIV codes inside the FPG)
var graph_duck: int
var graph_hit: int
var graph_fly: int
var graph_lie: int
# Recovery
var fly_recovery_divisor: int  # SLZ -= recovery_speed / divisor while flying
var fly_up_jump: int           # get-up jumps (from flying)
var fly_side_jump: int
var fly_side_lr: int
# Special moves
var special1_dir: int          # LookForMove()*facing must equal this (Template: -1 = down,back; Eigen: 1)
var special1_cost: int
var special2_dir: int = 99     # Eigen only: back,down,forward
var special2_cost: int = 0
# Mana regeneration per tick = base + (6000 - life) / life_divisor
var mana_base: int
var mana_life_divisor: int

var attacks: Dictionary = {}   # Defs.State -> Attack


static func make(character: int) -> FighterProfile:
	var p := FighterProfile.new()
	p.gfx_set = Gfx.CHARACTER_SETS[character]
	if character == Defs.Character.EIGEN:
		_fill_eigen(p)
	else:
		_fill_template(p)
	return p


static func _attack(duration: int, after: int, before: int, reach: int, xl: int, yo: int, yl: int,
		slz: int, dmg: int, fx: int, fy: int, push: int, type: int,
		sdx: int, sdy: int, ssize: int, sgraph: int = 4) -> Attack:
	var a := Attack.new()
	a.duration = duration
	a.hit_after = after
	a.hit_before = before
	a.reach = reach
	a.x_limit = xl
	a.y_offset = yo
	a.y_limit = yl
	a.slz = slz
	a.damage = dmg
	a.fly_x = fx
	a.fly_y = fy
	a.push = push
	a.type = type
	a.spark_dx = sdx
	a.spark_dy = sdy
	a.spark_size = ssize
	a.spark_graph = sgraph
	return a


static func _fill_template(p: FighterProfile) -> void:
	p.kind = Kind.TEMPLATE
	p.walk_speed = 300
	p.jump_speed = 1500
	p.walk_jump_lr = 300
	p.air_steer = 50
	p.graph_duck = 5
	p.graph_hit = 7
	p.graph_fly = 8
	p.graph_lie = 9
	p.fly_recovery_divisor = 2
	p.fly_up_jump = 800
	p.fly_side_jump = 500
	p.fly_side_lr = 300
	p.special1_dir = -1
	p.special1_cost = 1000
	p.mana_base = 8
	p.mana_life_divisor = 500
	var T := Defs.AttackType
	# duration, after, before, reach, xlim, yoff, ylim, slz, dmg, flyx, flyy, push, type, spark dx, dy, size, graph
	var light := _attack(6, 2, 5, 1000, 2500, 0, 2000, 250, 50, 50, 600, 200, T.MID, 1100, 0, 100)
	light.recoil = 250
	light.graph_base = 10
	var heavy := _attack(15, 8, 14, 2000, 3000, 0, 2500, 499, 100, 75, 800, 900, T.MID, 2100, 0, 150)
	heavy.advance = 500
	heavy.recoil = 350
	heavy.graph_base = 10
	heavy.graph_rules = [[8, 11]]
	var air_light := _attack(13, 4, 8, 2000, 3000, -1000, 3500, 350, 75, 125, 700, 600, T.HIGH, 2100, 1200, 125)
	air_light.graph_base = 12
	var air_heavy := _attack(19, -1, 18, 2000, 2500, 2200, 3000, 350, 150, 150, 700, 600, T.HIGH, 2100, 2200, 175, 6)
	air_heavy.graph_base = 13
	var duck_light := _attack(12, 2, 8, 1200, 3500, 0, 2500, 150, 45, 50, 400, 150, T.LOW, 1100, 2000, 100)
	duck_light.graph_base = 14
	var duck_heavy := _attack(25, 12, 17, 1200, 3500, -800, 3000, 350, 90, 10, 1000, 150, T.LOW, 1100, 2000, 130)
	duck_heavy.graph_base = 15
	duck_heavy.graph_rules = [[12, 14]]
	p.attacks = {
		Defs.State.LIGHT: light, Defs.State.HEAVY: heavy,
		Defs.State.AIR_LIGHT: air_light, Defs.State.AIR_HEAVY: air_heavy,
		Defs.State.DUCK_LIGHT: duck_light, Defs.State.DUCK_HEAVY: duck_heavy,
	}


static func _fill_eigen(p: FighterProfile) -> void:
	p.kind = Kind.EIGEN
	p.walk_speed = 200
	p.jump_speed = 1200
	p.walk_jump_lr = 200
	p.air_steer = 55
	p.graph_duck = 9
	p.graph_hit = 10
	p.graph_fly = 11
	p.graph_lie = 12
	p.fly_recovery_divisor = 1
	p.fly_up_jump = 1000
	p.fly_side_jump = 800
	p.fly_side_lr = 400
	p.special1_dir = 1
	p.special1_cost = 2500
	p.special2_dir = 2
	p.special2_cost = 5000
	p.mana_base = 4
	p.mana_life_divisor = 1000
	var T := Defs.AttackType
	var light := _attack(19, 7, 15, 1000, 2500, 0, 2500, 350, 50, 50, 600, 200, T.MID, 1100, 0, 100)
	light.recoil = 250
	light.graph_rules = [[19, 15], [15, 14], [7, 13]]
	var heavy := _attack(39, 9, 22, 2750, 3400, 0, 2500, 499, 200, 1300, 1000, 900, T.MID, 2750, 0, 250)
	heavy.recoil = 350
	heavy.graph_rules = [[39, 16], [33, 18], [19, 17], [9, 16]]
	var air_light := _attack(12, 4, 11, 1700, 3500, 0, 3500, 350, 50, 175, 700, 600, T.HIGH, 1700, 0, 60)
	air_light.graph_rules = [[12, 20], [4, 19]]
	var air_heavy := _attack(19, -1, 18, 2000, 3500, 2200, 3500, 500, 200, 750, 1300, 600, T.HIGH, 2000, 2200, 175, 6)
	air_heavy.graph_base = 21
	var duck_light := _attack(15, 10, 15, 1200, 3500, 0, 2500, 150, 45, 50, 400, 150, T.LOW, 1100, 2000, 100)
	duck_light.graph_rules = [[15, 24], [10, 23], [5, 22]]
	var duck_heavy := _attack(32, 13, 19, 5000, 2500, 0, 5000, 580, 300, 500, 1300, 150, T.LOW, 5000, 0, 200)
	duck_heavy.graph_rules = [[32, 27], [15, 26], [10, 25]]
	p.attacks = {
		Defs.State.LIGHT: light, Defs.State.HEAVY: heavy,
		Defs.State.AIR_LIGHT: air_light, Defs.State.AIR_HEAVY: air_heavy,
		Defs.State.DUCK_LIGHT: duck_light, Defs.State.DUCK_HEAVY: duck_heavy,
	}
