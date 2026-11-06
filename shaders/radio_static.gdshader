shader_type canvas_item;
// Background of the radio dialogue box: a dark transmission band along the
// bottom of the screen. It stays solid at the sides and bottom and turns
// gradually clear toward the top through a long, soft fade (no hard edge).
// Over it runs dense, randomly flickering radio grain with drifting patches of
// heavier interference, plus a few brighter signal specks.
//
// Drawn on Panel/RadioStatic. The quad is grown in vertex() so the band can
// bleed past the panel (up into the fade, out to the screen sides and bottom);
// dialogue_box.gd keeps `panel_size` up to date. `intensity` scales all of the
// noise together (0 = plain dark band).

uniform vec2 panel_size = vec2(1760.0, 202.0); // set by dialogue_box.gd
uniform bool choice_panel = false;
uniform sampler2D choice_art : source_color, filter_linear, repeat_disable;
uniform float choice_feather = 12.0;

// --- Band ---
uniform vec4 base_color : source_color = vec4(0.012, 0.014, 0.02, 1.0);
uniform float body_alpha : hint_range(0.0, 1.0) = 0.87;    // opacity over most of the box
uniform float bottom_alpha : hint_range(0.0, 1.0) = 0.92;  // slightly deeper toward the bottom
uniform float side_bleed : hint_range(0.0, 400.0) = 80.0;  // px past the panel's sides (reaches screen edge)
uniform float bottom_bleed : hint_range(0.0, 200.0) = 48.0; // px past the panel's bottom (reaches screen edge)

// --- Top fade (clear -> black) ---
uniform float top_fade_height : hint_range(0.0, 600.0) = 220.0; // px the fade reaches above the panel
uniform float top_fade_inset : hint_range(0.0, 150.0) = 30.0;   // px into the panel where it is fully dark
uniform float fade_softness : hint_range(0.0, 1.0) = 0.5;       // 0 = S-curve, 1 = even linear ramp
uniform float fade_curve : hint_range(0.3, 3.0) = 1.0;          // >1 keeps the upper fade lighter for longer
uniform float mist_wobble : hint_range(0.0, 80.0) = 14.0;       // px the fade edge drifts unevenly
uniform float mist_speed : hint_range(0.0, 1.0) = 0.04;

// --- Radio grain ---
uniform float intensity : hint_range(0.0, 2.0) = 1.0;          // master scale for all noise
uniform vec4 noise_color : source_color = vec4(0.86, 0.86, 0.84, 1.0);
uniform float grain_strength : hint_range(0.0, 0.5) = 0.11;    // brightness of the grain
uniform float grain_density : hint_range(0.0, 1.0) = 0.45;     // share of grains lit each frame
uniform float grain_size : hint_range(1.0, 6.0) = 1.5;         // px per grain
uniform float grain_fps : hint_range(1.0, 60.0) = 24.0;        // how often the grain re-rolls
uniform float patchiness : hint_range(0.0, 1.0) = 0.55;        // drifting areas of heavier / lighter static
uniform float row_jitter : hint_range(0.0, 1.0) = 0.3;         // random brighter static rows
uniform float grain_in_fade : hint_range(0.0, 1.0) = 0.1;      // grain kept where the band is clear

// --- Signal specks and interference ---
uniform float speck_strength : hint_range(0.0, 1.0) = 0.45;
uniform float speck_density : hint_range(0.0, 1.0) = 0.3;      // share of cells holding a speck
uniform float speck_spacing : hint_range(12.0, 120.0) = 30.0;  // px, average gap between specks
uniform vec2 speck_drift = vec2(5.0, -7.0);                    // px per second (rising)
uniform float interference_strength : hint_range(0.0, 0.3) = 0.05; // occasional faint shimmer line
uniform float hum_strength : hint_range(0.0, 0.1) = 0.012;         // slow overall brightness waver

varying vec2 local;


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

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += vnoise(p) * a;
		p = p * 2.03 + vec2(17.1, 9.7);
		a *= 0.5;
	}
	return v;
}

// Sparse brighter specks: each cell may hold one soft dot at a random spot,
// blinking and flickering on its own. The layer drifts slowly.
float speck_layer(vec2 p, float spacing, vec2 drift, float seed) {
	vec2 q = (p + drift * TIME) / spacing;
	vec2 id = floor(q) + seed;
	if (hash(id) > speck_density) {
		return 0.0;
	}
	vec2 pos = vec2(hash(id + 1.3), hash(id + 7.1)) * 0.8 + 0.1;
	float radius = mix(0.8, 1.8, hash(id + 3.7)) / spacing;
	float d = length(fract(q) - pos) / radius;
	float blink = pow(max(sin(TIME * mix(0.6, 1.8, hash(id + 5.5)) + hash(id + 9.2) * TAU), 0.0), 2.0);
	float flicker = mix(0.5, 1.0, hash(id + floor(TIME * grain_fps * 0.5)));
	return exp(-d * d) * blink * flicker;
}


void vertex() {
	// Grow the rect: up into the fade, out to the sides and below.
	vec2 corner = step(panel_size * 0.5, VERTEX);
	if (!choice_panel) {
		VERTEX += vec2(mix(-side_bleed, side_bleed, corner.x), mix(-top_fade_height - mist_wobble, bottom_bleed, corner.y));
	}
	local = VERTEX;
}


void fragment() {
	vec2 p = local;
	float live = intensity;

	// Long top fade, clear -> black, with a slightly uneven edge.
	float wobble = (fbm(vec2(p.x * 0.004 + TIME * mist_speed, TIME * mist_speed * 0.6)) - 0.5) * 2.0 * mist_wobble;
	float f = clamp((p.y + top_fade_height + wobble) / max(top_fade_height + top_fade_inset, 1.0), 0.0, 1.0);
	f = pow(mix(smoothstep(0.0, 1.0, f), f, fade_softness), fade_curve);
	float wisp = fbm(p * 0.006 + vec2(TIME * mist_speed * 2.0, -TIME * mist_speed * 3.0));
	f = clamp(f * mix(1.0, 0.85 + 0.3 * wisp, 1.0 - f), 0.0, 1.0);
	float alpha = body_alpha * f;

	// Slightly deeper toward the bottom; sides stay solid.
	float low = smoothstep(panel_size.y * 0.3, panel_size.y + bottom_bleed, p.y);
	alpha = mix(alpha, max(alpha, bottom_alpha), low);

	vec3 rgb = base_color.rgb + (vnoise(vec2(TIME * 2.3, 4.0)) - 0.5) * hum_strength * live;

	// Dense radio grain: re-rolled every frame step, unevenly spread.
	float frame = floor(TIME * grain_fps);
	vec2 cell = floor(p / grain_size);
	float g = hash(cell + vec2(frame * 13.17, frame * 7.31));
	float lit = smoothstep(1.0 - grain_density, 1.0, g);
	float patches = fbm(vec2(p.x * 0.006, p.y * 0.02) + vec2(TIME * 0.35, -TIME * 0.2));
	lit *= mix(1.0, smoothstep(0.2, 0.75, patches) * 1.6, patchiness);
	float row = hash(vec2(floor(p.y / (grain_size * 1.5)), frame));
	lit *= 1.0 + step(1.0 - row_jitter * 0.25, row) * 0.8;
	// Dark grains too, so the band itself looks textured, not flat.
	rgb *= 1.0 - (1.0 - g) * 0.5 * grain_strength * live;

	// Occasional thin shimmer line, like a signal dropping.
	float slot = floor(TIME * 0.8);
	float line_on = step(0.6, hash(vec2(slot, 2.0)));
	float line_y = hash(vec2(slot, 5.0)) * (panel_size.y + bottom_bleed);
	float line = exp(-pow((p.y - line_y) / 2.0, 2.0)) * vnoise(vec2(p.x * 0.05 + TIME * 40.0, slot));
	line *= line_on * sin(fract(TIME * 0.8) * 3.14159);

	float specks = speck_layer(p, speck_spacing, speck_drift, 0.0)
			+ 0.6 * speck_layer(p, speck_spacing * 1.7, speck_drift * vec2(-0.6, 0.7), 41.0);

	// Noise follows the band: full where it is dark, reduced where it has faded clear.
	float keep = choice_panel ? 1.0 : mix(grain_in_fade, 1.0, f * f);
	float na = (lit * grain_strength + specks * speck_strength + line * interference_strength) * live * keep;
	na = clamp(na, 0.0, 1.0);

	float out_a = na + alpha * (1.0 - na);
	vec3 out_rgb = (noise_color.rgb * na + rgb * alpha * (1.0 - na)) / max(out_a, 1e-4);
	if (choice_panel) {
		vec2 edge = min(p, panel_size - p);
		float soft_edge = smoothstep(0.0, choice_feather, edge.x) * smoothstep(0.0, choice_feather, edge.y);
		float art = texture(choice_art, vec2(UV.x, mix(0.80, 1.0, UV.y))).a;
		COLOR = vec4(out_rgb, soft_edge * (na + art * (1.0 - na)));
	} else {
		COLOR = vec4(out_rgb, out_a * base_color.a);
	}
}
