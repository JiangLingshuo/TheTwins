shader_type canvas_item;
// Notebook paper colour: recolours the light paper of the page texture to
// paper_color, keeping its grain and torn edges, and leaves the dark cover board
// and ink lines around it alone. Used for the Day / Night notebook pages.

uniform vec4 paper_color : source_color = vec4(1.0);
uniform float paper_level = 0.84;  // brightness of plain paper in the texture
uniform float mask_low = 0.5;      // darker than this is board or ink: kept as is
uniform float mask_high = 0.72;    // lighter than this is paper: fully recoloured

varying vec4 vertex_color;


void vertex() {
	// Keep the node's modulate apart, so the fold shading of a turning page
	// doesn't change what counts as paper.
	vertex_color = COLOR;
}


void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float level = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	float paper = smoothstep(mask_low, mask_high, level);
	vec3 tinted = paper_color.rgb * (level / paper_level);
	COLOR = vec4(mix(tex.rgb, tinted, paper), tex.a) * vertex_color;
}
