class_name Gfx
extends RefCounted
## Access to the converted DIV graphics (assets/fpg/<set>[_p2]/<code>.png).
## DIV places a graphic by its control point 0; Sprite2D nodes use offset = -cp0.
## Sizes and control points are baked into gfx_data.gd by tools/bake_assets.py.

const SET_EFFECTS := "heatfigh"   # Heatfigh.fpg = file 0 (hit sparks, charge ring)
const CHARACTER_SETS := {
	Defs.Character.TEMPLATE: "hftemp",
	Defs.Character.CHAIN: "hfchain",
	Defs.Character.EIGEN: "hfeigen",
}

static var _textures: Dictionary = {}


## True when the graphic exists (a fighter FPG may lack a graphic, then nothing is drawn, like DIV).
static func has(set_name: String, code: int) -> bool:
	return GfxData.DATA.has(set_name) and GfxData.DATA[set_name].has(code)


## `recoloured` selects the palette-swapped copy (DIV convert_palette on player 2's FPG).
static func texture(set_name: String, code: int, recoloured: bool = false) -> Texture2D:
	if not has(set_name, code):
		return null
	var key := "%s%s/%d" % [set_name, "_p2" if recoloured and set_name != SET_EFFECTS else "", code]
	if not _textures.has(key):
		_textures[key] = load("res://assets/fpg/%s.png" % key)
	return _textures[key]


static func cp0(set_name: String, code: int) -> Vector2:
	if not has(set_name, code):
		return Vector2.ZERO
	var entry: Array = GfxData.DATA[set_name][code]
	return Vector2(entry[2], entry[3])


## Show graphic `code` on a Sprite2D so that the node position is the DIV (x, y).
static func apply(sprite: Sprite2D, set_name: String, code: int, recoloured: bool = false) -> void:
	sprite.centered = false
	sprite.texture = texture(set_name, code, recoloured)
	sprite.offset = -cp0(set_name, code)
