extends Node2D
## DIV: BuyChooser(nummer) - the player's cursor in the buy line (graph 15+nummer); each unit of
## Powers moves it one slot (30 px) to the right.

var index := 0


func _ready() -> void:
	Gfx.apply($Sprite, 15 + index)


func _physics_process(_delta: float) -> void:
	var powers := Game.players[index].powers
	var slot := Vector2((powers - 1) * 30 - 1, 0)
	if powers == 0:
		slot.x = -100
	if slot != position:
		position = slot
		reset_physics_interpolation()  # hop from slot to slot, don't slide
