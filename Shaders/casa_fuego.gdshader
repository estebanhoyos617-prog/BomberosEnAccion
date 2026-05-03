shader_type canvas_item;
render_mode unshaded;

uniform float time_scale : hint_range(0.5, 5.0) = 2.5;
uniform float intensity : hint_range(0.0, 3.0) = 1.8;

void fragment() {
    vec2 uv = UV;
    float t = TIME * time_scale;
    
    // Simple flame movement using sine waves
    float flame = sin(uv.y * 8.0 - t * 3.0) * 0.5 + 0.5;
    flame *= sin(uv.x * 12.0 + t * 2.0) * 0.3 + 0.7;
    
    // Mask - more fire at top
    float mask = 1.0 - uv.y;
    flame *= mask * intensity;
    
    // Color
    vec3 fire_color = mix(vec3(1.0, 0.3, 0.0), vec3(1.0, 0.85, 0.2), flame);
    
    // Add to base texture
    vec3 base = texture(TEXTURE, uv).rgb;
    COLOR.rgb = mix(base, fire_color, flame * 0.75);
    COLOR.rgb += fire_color * flame * 1.5; // glow
    COLOR.a = texture(TEXTURE, uv).a;
}
