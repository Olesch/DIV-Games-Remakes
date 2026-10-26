extends CanvasLayer
## Everything the original drew above the playfield: money counter, buy menu (child
## BuyButton nodes) and the ammo lights. Sits on its own layer, so it is above all entities.

const AMMO_INDICATOR_SCENE := preload("res://scenes/ammo_indicator.tscn")

@onready var _money_label: PixelLabel = $MoneyLabel


func _ready() -> void:
	for side: Defs.Side in [Defs.Side.LEFT, Defs.Side.RIGHT]:
		for number in range(1, Defs.MAX_AMMO + 1):
			var light := AMMO_INDICATOR_SCENE.instantiate() as AmmoIndicator
			light.setup(side, number)
			add_child(light)
	Game.money_changed.connect(_on_money_changed)
	_on_money_changed(Game.money)


func _on_money_changed(value: int) -> void:
	_money_label.set_value(str(value))
