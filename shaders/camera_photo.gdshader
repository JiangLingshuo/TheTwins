shader_type canvas_item;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){vec4 c=texture(TEXTURE,UV);float n=hash(floor(UV*vec2(1280.0,720.0))+floor(TIME*6.0));float vignette=1.0-0.23*length(UV-vec2(0.5));COLOR=vec4((c.rgb+(n-0.5)*0.07)*vignette,c.a);}
