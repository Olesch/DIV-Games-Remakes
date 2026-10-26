class_name Camo
extends RefCounted
## Builds the "grass" material (DIV process Graszeichner) for a graphic.

const SHADER := preload("res://scripts/camo_grass.gdshader")
## Palette colours 32..35 of PANZERS.FPG
const GREENS: Array[Color] = [
	Color8(0, 40, 0), Color8(0, 60, 0), Color8(0, 85, 0), Color8(0, 109, 0),
]
## Palette colours 1..4 (dark greys): the same speckle for a burnt-out wreck (new).
const ASH: Array[Color] = [
	Color8(16, 16, 16), Color8(32, 32, 32), Color8(48, 48, 48), Color8(65, 65, 65),
]


static func material_for(texture: Texture2D, colours: Array[Color] = GREENS) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter(&"tex_size", Vector2(texture.get_size()))
	mat.set_shader_parameter(&"seed", float(randi() % 1000))
	var greens := PackedVector3Array()
	for c in colours:
		greens.append(Vector3(c.r, c.g, c.b))
	mat.set_shader_parameter(&"greens", greens)
	return mat
