shader_type canvas_item;
// Hover highlight for a gravestone: a soft warm glow around the stone's
// silhouette (from the texture's alpha) and a slight brightening of the stone.
// At highlight = 0 the texture is drawn unchanged.

uniform float highlight : hint_range(0.0, 1.0) = 0.0;  // animated 0 -> 1 on hover
uniform vec4 glow_color : source_color = vec4(1.0, 0.92, 0.66, 0.85);
uniform float glow_width = 10.0;   // in texture pixels
uniform float brighten = 0.08;     // extra brightness on the stone itself


void fragment() {
	vec4 base = COLOR;
	if (highlight > 0.0) {
		// How much of the stone is near this pixel, sampled on two rings.
		float near = 0.0;
		for (int i = 0; i < 12; i++) {
			float angle = float(i) * 6.2831853 / 12.0;
			vec2 dir = vec2(cos(angle), sin(angle)) * TEXTURE_PIXEL_SIZE * glow_width;
			near += texture(TEXTURE, UV + dir).a * 0.5;
			near += texture(TEXTURE, UV + dir * 0.5).a;
		}
		float glow = clamp(near / 12.0, 0.0, 1.0) * glow_color.a * highlight;
		vec3 lit = base.rgb * (1.0 + brighten * highlight);
		// The stone drawn over its glow.
		float alpha = base.a + glow * (1.0 - base.a);
		vec3 rgb = (lit * base.a + glow_color.rgb * glow * (1.0 - base.a)) / max(alpha, 0.0001);
		base = vec4(rgb, alpha);
	}
	COLOR = base;
}
