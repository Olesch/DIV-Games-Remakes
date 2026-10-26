class_name ChoosenCursor
extends Proc
## DIV PROCESS Choosen_cursor(player): marks the picked tile (drawn above the cursor, z=-5).

var xpos := 0
var ypos := 0


func begin() -> void:
	graph = 3
	z = -5
	# x/y/xpos/ypos are set by World.spawn_choosen_cursor from the cursor (DIV: father.*)
