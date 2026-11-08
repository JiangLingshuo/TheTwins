shader_type canvas_item;
render_mode unshaded;
void fragment() {
    vec2 p = UV;
    // A soft diagonal shaft ending at the marker, with dawn behind it.
    vec2 origin = vec2(0.78, -0.15);
    vec2 end = vec2(0.50, 0.60);
    vec2 axis = end - origin;
    float t = dot(p - origin, axis) / dot(axis, axis);
    float distance_to_axis = length((p - origin) - axis * t);
    float width = mix(0.025, 0.13, clamp(t, 0.0, 1.0));
    float shaft = exp(-pow(distance_to_axis / width, 2.0) * 2.5);
    shaft *= smoothstep(-0.15, 0.15, t) * (1.0 - smoothstep(0.83, 1.15, t));
    float halo = exp(-dot((p - vec2(0.50, 0.49)) / vec2(0.15, 0.25), (p - vec2(0.50, 0.49)) / vec2(0.15, 0.25)) * 1.8);
    COLOR = vec4(1.0, 0.86, 0.57, (shaft * 0.55 + halo * 0.45) * COLOR.a);
}