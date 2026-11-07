shader_type canvas_item;
// Tool button icons (toolbox, notebook, radio, rubbing, searchlight, camera):
// matches the soft, grainy look of the dialogue boxes. The crisp vector art is
// blurred a touch so its lines and rim lose their sharpness, then a coarse,
// *static* paper grain is laid over it (it is fixed to the picture and never
// flickers, unlike the radio static) and the outline is roughened slightly.

uniform float soften : hint_range(0.0, 4.0) = 1.15;          // px blur radius
uniform float grain_strength : hint_range(0.0, 0.6) = 0.07;   // how visible the paper grain is
uniform float grain_size : hint_range(1.0, 6.0) = 1.7;       // px per grain
uniform float fibre_strength : hint_range(0.0, 1.0) = 0.5;   // share of broader, cloudy mottling
uniform float edge_rough : hint_range(0.0, 1.0) = 0.12;       // grain eaten into the soft edge

varying vec4 vmod;

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	vmod = COLOR;
}

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE * soften;
	// 3x3 gaussian on premultiplied colour, so the rim never gains a dark fringe.
	vec4 sum = vec4(0.0);
	float total = 0.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			float w = (x == 0 ? 2.0 : 1.0) * (y == 0 ? 2.0 : 1.0);
			vec4 t = texture(TEXTURE, UV + vec2(float(x), float(y)) * px);
			sum += vec4(t.rgb * t.a, t.a) * w;
			total += w;
		}
	}
	sum /= total;
	float a = sum.a;
	vec3 rgb = sum.rgb / max(a, 1e-4);

	// Static grain, tied to the picture's own pixels.
	vec2 p = UV / TEXTURE_PIXEL_SIZE;
	float fine = hash(floor(p / grain_size)) - 0.5;
	float cloud = vnoise(p / (grain_size * 4.0)) - 0.5;
	float g = mix(fine, cloud, fibre_strength * 0.6) * 2.0;
	// Pencil-dark where it goes dark, a little lighter on the paper.
	rgb = clamp(rgb + g * grain_strength * mix(0.5, 1.0, 1.0 - dot(rgb, vec3(0.33))), 0.0, 1.0);
	// Roughen the soft rim: grain bites into partly transparent pixels.
	float rim = a * (1.0 - a) * 4.0;
	a = clamp(a + fine * edge_rough * rim, 0.0, 1.0);

	COLOR = vec4(rgb, a) * vmod;
}
