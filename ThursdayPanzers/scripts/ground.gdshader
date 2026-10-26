shader_type canvas_item;
// DIV: Draw() fills the map with rand(34,37) palette indices. A random R8 texture is
// quantised to those four greens (palette entries 34..37).
const vec3 PAL[4] = vec3[4](vec3(0.0, 85.0, 0.0) / 255.0, vec3(0.0, 109.0, 0.0) / 255.0,
		vec3(0.0, 134.0, 0.0) / 255.0, vec3(0.0, 158.0, 0.0) / 255.0);

void fragment() {
	float r = texture(TEXTURE, UV).r;
	int i = min(int(r * 4.0), 3);
	COLOR = vec4(PAL[i], 1.0);
}
