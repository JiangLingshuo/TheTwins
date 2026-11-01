shader_type canvas_item;
// A symbol carved into a tombstone. Before rubbing it is only slightly darker
// than the stone under it; where the rubbing tool has brushed (reveal_mask),
// it turns into the inverted stone colour (or `revealed_color`). Optionally the brushing also leaves a charcoal smudge on the
// stone around it, like a real rubbing on paper.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform sampler2D reveal_mask : filter_linear;
uniform float darken : hint_range(0.0, 1.0) = 0.1;          // carving vs. stone colour
uniform float complete : hint_range(0.0, 1.0) = 0.0;        // 1 = fully revealed
uniform vec4 revealed_color : source_color = vec4(1.0);
uniform bool reveal_inverted = true;  // revealed symbol = inverted stone colour
uniform float charcoal_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 charcoal_color : source_color = vec4(0.16, 0.15, 0.15, 1.0);
// The tombstone art under the symbol: charcoal only sticks where there is stone.
uniform sampler2D stone_tex : filter_linear;
uniform vec4 stone_uv_rect = vec4(0.0, 0.0, 1.0, 1.0);  // xy = offset, zw = scale
uniform bool use_stone_mask = false;

void fragment() {
	vec3 stone = texture(screen_tex, SCREEN_UV).rgb;
	float symbol = texture(TEXTURE, UV).a;
	float brushed = texture(reveal_mask, UV).r;
	float shown = max(brushed, complete);

	vec3 carved = stone * (1.0 - darken);
	vec3 revealed = reveal_inverted ? vec3(1.0) - stone : revealed_color.rgb;
	vec3 symbol_color = mix(carved, revealed, shown);
	// Only the symbol and the charcoal are drawn; the rest stays transparent.
	// Soft edges, and only on the stone itself.
	float edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float on_stone = use_stone_mask ? texture(stone_tex, stone_uv_rect.xy + UV * stone_uv_rect.zw).a : 1.0;
	float coal = (1.0 - symbol) * brushed * charcoal_strength * smoothstep(0.0, 0.18, edge) * on_stone;
	float alpha = symbol + coal;
	vec3 rgb = alpha > 0.0001 ? (symbol * symbol_color + coal * charcoal_color.rgb) / alpha : vec3(0.0);
	COLOR = vec4(rgb, alpha);
}
