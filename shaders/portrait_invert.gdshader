shader_type canvas_item;
// Inverts the portrait's colours (a black silhouette turns light) so it reads
// on dark backgrounds. Set by DialogueBox when the screen behind it is dark.

uniform float invert : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0) - COLOR.rgb, invert);
}
