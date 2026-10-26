class_name PlayerStats
extends RefCounted
## DIV: STRUCT Stat[3] playid; life; Ammo; Weapon; Score.  `changed` drives the HUD.

signal changed

var ship: Ship
var life := 100:
	set(v):
		life = v
		changed.emit()
var ammo := 99:
	set(v):
		ammo = v
		changed.emit()
var weapon := 0:
	set(v):
		weapon = v
		changed.emit()
var score := 0:
	set(v):
		score = v
		changed.emit()
