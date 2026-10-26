shader_type canvas_item;
// DIV "Graszeichner": every opaque pixel of the graphic gets a random palette colour 32..35
// (dark greens). Applied to the background and to the tank hull and turret graphics.
// Noise is a hash of the texel position, so it sticks to the graphic when it rotates.
uniform vec2 tex_size = vec2(1024.0, 768.0);
uniform float seed = 0.0;
uniform vec3 greens[4];

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	uvec2 p = uvec2(floor(UV * tex_size));
	uint h = p.x * 374761393u + p.y * 668265263u + uint(seed) * 2246822519u;
	h = (h ^ (h >> 13u)) * 1274126177u;
	h = h ^ (h >> 16u);
	int k = int((h >> 7u) & 3u);
	COLOR = vec4(greens[k], base.a);
}
