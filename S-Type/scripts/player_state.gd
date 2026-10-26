class_name PlayerState
extends RefCounted
## One entry of the DIV table Player[0..3] (STRUCT Player: Player, Weapon, Center, Lives,
## killed, Powers, Shield, Compains).

var ship: Ship = null            # DIV: Player (process id of the ship)
var center: CenterPoint = null   # DIV: Center (aiming reticle of weapon 4)
var weapon: int = 0              # 0 none, 1 red, 2 gatling, 3 boing, 4 targeting
var lives: int = 0               # -1 = permanently dead
var killed: bool = false         # set by anything that touches the ship
var powers: int = 0              # collected money units = cursor in the buy line
var shield: int = 0
var compains: int = 0            # companion pods (DIV: Compains)
