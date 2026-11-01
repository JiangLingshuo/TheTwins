shader_type canvas_item;
// Flashlight lens: draws the scene behind it, darkened outside a feathered circle.
// Inside the circle, a hidden "clue" layer is composited on top (picture-in-picture),
// blurred by `blur_px` when out of focus, and everything is lit with a warm yellow tint.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform sampler2D clue_tex : filter_linear, repeat_disable;

uniform vec2 rect_size = vec2(1280.0, 720.0);  // size of the lens rect, in pixels
uniform vec2 center_px = vec2(640.0, 360.0);   // circle centre, in lens-rect pixels
uniform float radius_px = 150.0;               // circle radius
uniform float feather_px = 45.0;               // width of the soft edge
uniform float blur_px = 0.0;                   // defocus blur radius
uniform float reveal : hint_range(0.0, 1.0) = 1.0;    // opacity of the clue layer
uniform float darkness : hint_range(0.0, 1.0) = 0.6;  // darkening outside the beam
uniform vec4 light_tint : source_color = vec4(1.0, 0.86, 0.58, 1.0);
uniform float brightness = 1.35;               // brightening inside the beam
uniform float glow = 0.06;                     // warm light added inside the beam
uniform bool clue_premultiplied = true;        // true for a SubViewport texture, false for a normal image

const int BLUR_TAPS = 48;
const float GOLDEN_ANGLE = 2.39996323;

vec4 sample_clue(vec2 uv) {
	if (blur_px < 0.5) {
		return texture(clue_tex, uv);
	}
	// Spiral disc sampling ("bokeh" style blur).
	vec4 sum = vec4(0.0);
	for (int i = 0; i < BLUR_TAPS; i++) {
		float r = sqrt((float(i) + 0.5) / float(BLUR_TAPS)) * blur_px;
		float a = float(i) * GOLDEN_ANGLE;
		vec2 offset = vec2(cos(a), sin(a)) * r / rect_size;
		sum += texture(clue_tex, uv + offset);
	}
	return sum / float(BLUR_TAPS);
}

void fragment() {
	vec3 base = texture(screen_tex, SCREEN_UV).rgb;
	vec2 px = UV * rect_size;
	float dist = distance(px, center_px);
	float beam = 1.0 - smoothstep(radius_px - feather_px, radius_px, dist);

	// Picture-in-picture: the hidden clue layer on top of the scene.
	vec4 clue = sample_clue(UV);
	if (!clue_premultiplied) {
		clue.rgb *= clue.a;
	}
	float clue_alpha = clamp(clue.a, 0.0, 1.0) * reveal;
	vec3 clue_rgb = clue.a > 0.001 ? clue.rgb / max(clue.a, 0.001) : vec3(0.0);
	vec3 inside = mix(base, clue_rgb, clue_alpha);

	// Warm, brightening "flashlight" filter.
	inside = inside * light_tint.rgb * brightness + light_tint.rgb * glow;

	vec3 outside = base * (1.0 - darkness);
	COLOR = vec4(mix(outside, inside, beam), 1.0);
}
