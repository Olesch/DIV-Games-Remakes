shader_type canvas_item;
// Draws a texture of palette indices (R8) with the DIV palette; index 0 is transparent.

uniform sampler2D palette : filter_nearest;

void fragment() {
	int index = int(round(texture(TEXTURE, UV).r * 255.0));
	if (index == 0) {
		discard;
	}
	COLOR = texelFetch(palette, ivec2(index, 0), 0);
}
