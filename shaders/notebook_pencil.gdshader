shader_type canvas_item;

varying vec2 paper_position;

void vertex() {
	paper_position = VERTEX;
}

void fragment() {
	// Small gaps in graphite where the grain of the paper shows through.
	vec2 grain_cell = floor(paper_position * vec2(1.5, 1.25));
	float grain = fract(sin(dot(grain_cell, vec2(127.1, 311.7))) * 43758.5453);
	COLOR.a *= mix(0.65, 1.0, smoothstep(0.05, 0.55, grain));
}
