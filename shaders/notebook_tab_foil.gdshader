shader_type canvas_item;

// Flecks stay attached to the tab while it moves. Only the paper is shaded.
uniform vec2 tab_size = vec2(60.0, 112.0);
varying vec2 paper_position;

float grain(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	paper_position = VERTEX;
}

void fragment() {
	vec2 cell = floor(paper_position * 1.4);
	float fleck = grain(cell);
	float shade = grain(floor(paper_position * 0.65) + 19.0);
	float edge = min(min(paper_position.x, tab_size.x - paper_position.x),
		min(paper_position.y, tab_size.y - paper_position.y));
	float strength = mix(0.10, 0.36, 1.0 - smoothstep(0.0, 6.0, edge));
	vec3 paper = COLOR.rgb * mix(0.92, 1.04, shade);
	vec3 foil = mix(vec3(0.22, 0.24, 0.53), vec3(0.83, 0.70, 0.39),
		step(0.58, grain(cell + 47.0)));
	paper = mix(paper, foil, step(0.94, fleck) * strength);
	paper = mix(paper, vec3(0.97, 0.91, 0.73), step(0.994, fleck) * 0.38);
	COLOR.rgb = paper;
}
