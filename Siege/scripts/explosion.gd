class_name Explosion
extends Proc
## DIV PROCESS Explode(art, player). Position = position of the creator at creation time.
## Damage is applied to ALL units in range (own, enemy, flying) at the 4th frame of the animation,
## except art 6 (tower arrow) which only hurts enemies.
##   0 blood, 1 arrow blast, 2 purely graphic, 3 bomber, 4 catapult, 5 ballista, 6 tower arrow,
##   7 meteor, 8 airship bomb, 9 dragon shot

var art := 0
var player := 0

# art -> [damage, radius]  (art 0 and 2 have no damage)
const BLAST := {
	1: [Defs.DAM_PFEIL, Defs.EXP_PFEIL],
	3: [Defs.DAM_BOMBER, Defs.EXP_BOMBER],
	4: [Defs.DAM_KATAPULT, Defs.EXP_KATAPULT],
	5: [Defs.DAM_BALLISTE, Defs.EXP_BALLISTE],
	6: [Defs.DAM_TURM, Defs.EXP_TURM],
	7: [Defs.DAM_METEOR, Defs.EXP_METEOR],
	8: [Defs.DAM_LUFTSCHIFF, Defs.EXP_LUFTSCHIFF],
	9: [Defs.DAM_DRACHE, Defs.EXP_DRACHE],
}


func begin() -> void:
	match art:
		0:
			var steps: Array = []
			for g in range(90, 98):
				steps.append([func() -> void: graph = g, 1])
			play(steps)
		2:
			var steps: Array = []
			for g in [120, 119, 118, 117]:
				steps.append([func() -> void: graph = g, 1])
			play(steps)
		_:
			match art:
				3: size = 130
				4:
					size = 120
					x += randi_range(-(Defs.EXP_KATAPULT * 3) / 2, (Defs.EXP_KATAPULT * 3) / 2)
				5: size = 120
				9:
					size = 140
					x += randi_range(-(Defs.EXP_DRACHE * 3) / 2, (Defs.EXP_DRACHE * 3) / 2)
			var steps: Array = []
			for g in [119, 118, 117]:
				steps.append([func() -> void: graph = g, 1])
			steps.append([func() -> void:
				graph = 117
				_damage(), 1])
			for g in [118, 119, 120]:
				steps.append([func() -> void: graph = g, 1])
			play(steps)



func _damage() -> void:
	var blast: Array = BLAST[art]
	for u: Unit in world.units():
		if art == 6 and u.player == player:
			continue
		if Vector2(x - u.x, y - u.y).length() < blast[1]:
			u.lp -= blast[0]
