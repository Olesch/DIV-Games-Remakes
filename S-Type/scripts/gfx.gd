class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/s-type).
## DIV places a graphic by its control point 0; Sprite2D nodes use offset = -cp0.

const DIR := "res://assets/fpg/s-type/"

## Control point 0 of every graphic (from assets/fpg/s-type/meta.json; centre if undefined).
const CP0 := {
	1: Vector2(20, 15),
	2: Vector2(20, 15),
	3: Vector2(20, 15),
	4: Vector2(20, 15),
	5: Vector2(0, 0),
	6: Vector2(0, 0),
	7: Vector2(15, 15),
	8: Vector2(15, 15),
	9: Vector2(15, 15),
	10: Vector2(20, 15),
	11: Vector2(0, 0),
	15: Vector2(0, 0),
	16: Vector2(0, 0),
	17: Vector2(0, 0),
	18: Vector2(0, 0),
	20: Vector2(20, 15),
	21: Vector2(20, 15),
	22: Vector2(20, 15),
	23: Vector2(20, 15),
	24: Vector2(20, 15),
	25: Vector2(20, 15),
	26: Vector2(20, 15),
	27: Vector2(20, 15),
	30: Vector2(14, 15),
	31: Vector2(14, 15),
	100: Vector2(5, 2),
	101: Vector2(5, 3),
	102: Vector2(1, 1),
	103: Vector2(5, 3),
	104: Vector2(11, 5),
	105: Vector2(15, 15),
	106: Vector2(10, 5),
	107: Vector2(15, 15),
	108: Vector2(15, 15),
	109: Vector2(15, 15),
	110: Vector2(15, 15),
	200: Vector2(10, 15),
	201: Vector2(20, 15),
	202: Vector2(20, 15),
	203: Vector2(10, 15),
	204: Vector2(10, 15),
	205: Vector2(7, 7),
	206: Vector2(7, 7),
	207: Vector2(10, 15),
	208: Vector2(17, 0),
	209: Vector2(17, 89),
	210: Vector2(15, 15),
	211: Vector2(15, 15),
	212: Vector2(15, 15),
	213: Vector2(15, 15),
	214: Vector2(15, 15),
	215: Vector2(15, 15),
	216: Vector2(15, 15),
	217: Vector2(15, 15),
	218: Vector2(15, 15),
	219: Vector2(55, 55),
	220: Vector2(10, 15),
	300: Vector2(50, 50),
	301: Vector2(50, 50),
	302: Vector2(50, 50),
	303: Vector2(50, 50),
	304: Vector2(50, 50),
	305: Vector2(50, 50),
	306: Vector2(50, 50),
	307: Vector2(50, 50),
	308: Vector2(50, 50),
	309: Vector2(50, 50),
	400: Vector2(30, 45),
	401: Vector2(5, 5),
	402: Vector2(55, 55),
	403: Vector2(799, 7),
	404: Vector2(30, 45),
	405: Vector2(5, 3),
	406: Vector2(15, 15)
}
## Opaque bounding box of each graphic relative to control point 0 (x0, y0, x1, y1).
const BBOX := {
	1: Rect2(-19, -11, 39, 19),
	2: Rect2(-19, -11, 39, 19),
	3: Rect2(-18, -14, 8, 12),
	4: Rect2(-9, 7, 13, 6),
	5: Rect2(0, 0, 780, 30),
	6: Rect2(0, 0, 32, 32),
	7: Rect2(-15, -15, 30, 30),
	8: Rect2(-14, -15, 29, 29),
	9: Rect2(-14, -15, 29, 29),
	10: Rect2(-4, -11, 24, 18),
	11: Rect2(0, 0, 1599, 599),
	15: Rect2(0, 0, 32, 32),
	16: Rect2(0, 0, 32, 32),
	17: Rect2(3, 3, 26, 26),
	18: Rect2(3, 3, 26, 26),
	20: Rect2(-19, -11, 39, 19),
	21: Rect2(-19, -11, 39, 19),
	22: Rect2(-19, -11, 39, 19),
	23: Rect2(-19, -11, 39, 19),
	24: Rect2(-19, -11, 39, 19),
	25: Rect2(-19, -11, 39, 19),
	26: Rect2(-19, -11, 39, 19),
	27: Rect2(-19, -11, 39, 19),
	30: Rect2(-9, -5, 19, 12),
	31: Rect2(-7, -5, 17, 12),
	100: Rect2(-4, -1, 8, 3),
	101: Rect2(-5, -3, 10, 6),
	102: Rect2(-1, -1, 3, 3),
	103: Rect2(-5, -3, 10, 6),
	104: Rect2(-11, -5, 22, 10),
	105: Rect2(-15, -15, 30, 30),
	106: Rect2(-10, -5, 20, 10),
	107: Rect2(-15, -15, 30, 30),
	108: Rect2(-15, -15, 30, 30),
	109: Rect2(-15, -15, 30, 30),
	110: Rect2(-15, -15, 30, 30),
	200: Rect2(-10, -15, 40, 30),
	201: Rect2(-19, -15, 38, 30),
	202: Rect2(-19, -15, 38, 30),
	203: Rect2(-10, -15, 40, 30),
	204: Rect2(-10, -15, 40, 30),
	205: Rect2(-2, -2, 10, 5),
	206: Rect2(-2, -2, 10, 5),
	207: Rect2(-10, -15, 40, 30),
	208: Rect2(-17, 60, 40, 30),
	209: Rect2(-17, -89, 40, 30),
	210: Rect2(-15, -15, 30, 30),
	211: Rect2(-15, -15, 30, 30),
	212: Rect2(-15, -15, 30, 30),
	213: Rect2(-15, -15, 30, 30),
	214: Rect2(-15, -15, 30, 30),
	215: Rect2(-15, -15, 30, 30),
	216: Rect2(-15, -15, 30, 30),
	217: Rect2(-15, -15, 30, 30),
	218: Rect2(-15, -15, 30, 30),
	219: Rect2(-55, -55, 110, 110),
	220: Rect2(-10, -7, 14, 14),
	300: Rect2(-49, -48, 98, 98),
	301: Rect2(-49, -49, 97, 98),
	302: Rect2(-49, -49, 98, 98),
	303: Rect2(-48, -48, 97, 97),
	304: Rect2(-48, -48, 97, 97),
	305: Rect2(-48, -48, 97, 97),
	306: Rect2(-48, -48, 96, 97),
	307: Rect2(-48, -47, 96, 96),
	308: Rect2(-49, -46, 95, 95),
	309: Rect2(-48, -40, 95, 87),
	400: Rect2(-27, -38, 57, 76),
	401: Rect2(-4, -4, 10, 9),
	402: Rect2(-52, -52, 104, 104),
	403: Rect2(-799, -7, 800, 15),
	404: Rect2(-12, -29, 35, 58),
	405: Rect2(-5, -3, 10, 6),
	406: Rect2(-15, -15, 30, 30)
}

static var _textures: Dictionary = {}


static func tex(code: int) -> Texture2D:
	if not _textures.has(code):
		_textures[code] = load("%s%d.png" % [DIR, code])
	return _textures[code]


static func cp0(code: int) -> Vector2:
	return CP0.get(code, Vector2.ZERO)


## Show graphic `code` on a Sprite2D so that the node position is the DIV (x, y).
static func apply(sprite: Sprite2D, code: int) -> void:
	sprite.centered = false
	if code > 0:
		sprite.texture = tex(code)
		sprite.offset = -cp0(code)
		sprite.visible = true
	else:
		sprite.visible = false


## Collision rectangle for graphic `code` (opaque bounding box relative to control point 0),
## shrunk by `shrink` pixels on every side. DIV tested sprite pixels; this approximates them.
static func hit_rect(code: int, shrink: float = 2.0) -> Rect2:
	var r: Rect2 = BBOX.get(code, Rect2(-4, -4, 8, 8))
	r = r.grow(-minf(shrink, minf(r.size.x, r.size.y) * 0.3))
	return r


## Give a CollisionShape2D a rectangle fitting graphic `code`.
static func fit_shape(shape_node: CollisionShape2D, code: int, shrink: float = 2.0) -> void:
	var r := hit_rect(code, shrink)
	var rs := RectangleShape2D.new()
	rs.size = r.size
	shape_node.shape = rs
	shape_node.position = r.get_center()
