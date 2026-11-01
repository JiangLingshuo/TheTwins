shader_type canvas_item;
// Flashlight lens: everything drawn before this node is darkened outside a
// feathered circle and lit with a warm, brightening yellow filter inside it.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;

uniform vec2 rect_size = vec2(1280.0, 720.0);  // size of the lens rect, in pixels
uniform vec2 center_px = vec2(640.0, 360.0);   // circle centre, in lens-rect pixels
uniform float radius_px = 150.0;               // circle radius
uniform float feather_px = 45.0;               // width of the soft edge
uniform float darkness : hint_range(0.0, 1.0) = 0.6;  // darkening outside the beam
uniform vec4 light_tint : source_color = vec4(1.0, 0.86, 0.58, 1.0);
uniform float brightness = 1.35;               // brightening inside the beam
uniform float glow = 0.06;                     // warm light added inside the beam

void fragment() {
	vec3 base = texture(screen_tex, SCREEN_UV).rgb;
	float dist = distance(UV * rect_size, center_px);
	float beam = 1.0 - smoothstep(radius_px - feather_px, radius_px, dist);
	vec3 inside = base * light_tint.rgb * brightness + light_tint.rgb * glow;
	vec3 outside = base * (1.0 - darkness);
	COLOR = vec4(mix(outside, inside, beam), 1.0);
}
