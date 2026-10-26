class_name LifeGauge
extends Proc
## DIV PROCESS Life_gauge(player): castle life bar (graphs 20..26).

var player := 0


func begin() -> void:
	if player == 0:
		x = 137
		y = 86
	else:
		x = 140
		y = 49
	_update()


func _frame() -> void:
	_update()


func _update() -> void:
	var life: int = Game.life[player]
	graph = 25 - (life * 6) / 100
	if life <= 0:
		graph = 26
	graph = clampi(graph, 20, 26)
