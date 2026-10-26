class_name BuyButton
extends Control
## DIV: PROCESS KaufMenuKnoepfe(graph) plus its click zone from PROCESS Kaufmenu.
## One entry of the top buy menu: icon, price and the click zone (60 px wide, y < 61).

const ICONS := {
	Defs.Item.LEFT_CANNON: 200, Defs.Item.RIGHT_CANNON: 201, Defs.Item.DUK: 202,
	Defs.Item.POTION: 203, Defs.Item.BIRD: 211, Defs.Item.ATOM: 204,
	Defs.Item.SECOND_PLAYER: 218, Defs.Item.RELOAD: 215, Defs.Item.ROCKET: 210,
	Defs.Item.BIRD_BREEDING: 214, Defs.Item.POTION_LIMIT: 216, Defs.Item.MAGNET: 217,
}
## The rocket button changes its picture with every upgrade level.
const ROCKET_ICONS := [210, 212, 213]

@export var item: Defs.Item = Defs.Item.LEFT_CANNON
## Horizontal centre of the button on screen (DIV: x)
@export var center_x: float = 30.0

@onready var _icon: Sprite2D = $Icon
@onready var _cost_label: PixelLabel = $CostLabel


func _ready() -> void:
	position = Vector2(center_x - 30.0, 0.0)
	Game.state_changed.connect(refresh)
	gui_input.connect(_on_gui_input)
	refresh()


func refresh() -> void:
	visible = not Game.is_hidden(item)
	if not visible:
		return
	var icon_code: int = ICONS[item]
	if item == Defs.Item.ROCKET:
		icon_code = ROCKET_ICONS[clampi(Game.super_rocket, 0, 2)]
	Gfx.apply(_icon, icon_code)
	_cost_label.set_value(str(Game.cost_of(item)))
	# DIV flags = 4: drawn half transparent while it cannot be bought
	_icon.modulate.a = 1.0 if Game.can_buy(item) else 0.5


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Game.try_buy(item)
