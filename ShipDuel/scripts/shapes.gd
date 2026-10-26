class_name Shapes
extends RefCounted
## Builds collision polygons from the opaque pixels of a graphic (instead of DIV's pixel collision).

static var _cache: Dictionary = {}


## Adds one CollisionPolygon2D per opaque region of `texture` to `area`, positioned so that the
## texture's centre is the area's origin (control point 0 = centre for all graphics here).
static func add_alpha_polygons(area: CollisionObject2D, texture: Texture2D) -> void:
	var key := texture.resource_path
	if not _cache.has(key):
		var image := texture.get_image()
		var bitmap := BitMap.new()
		bitmap.create_from_image_alpha(image, 0.1)
		_cache[key] = bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, bitmap.get_size()), 1.5)
	var half := texture.get_size() * 0.5
	for points: PackedVector2Array in _cache[key]:
		var polygon := CollisionPolygon2D.new()
		var shifted := PackedVector2Array()
		for p in points:
			shifted.append(p - half)
		polygon.polygon = shifted
		area.add_child(polygon)
