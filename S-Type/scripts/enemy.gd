class_name Enemy
extends Area2D
## Base for everything player shots can damage (DIV: the TYPEs listed in FindHit).

var life: int = 1


func take_damage(amount: int) -> void:
	life -= amount


## DIV FindHitEnemy: standing in a bomb explosion costs 1 life per frame.
func apply_blast_damage(radius: float) -> void:
	if Blast.touching(global_position, radius):
		life -= 1
