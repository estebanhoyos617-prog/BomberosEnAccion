shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float flame_speed : hint_range(0.5, 6.0) = 3.0;
uniform float intensity : hint_range(0.0, 3.0) = 1.8;
uniform float flicker : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    vec2 uv = UV;
    float time = TIME * flame_speed;
    
    // Movimiento de llamas con varias capas
    float wave1 = sin(uv.y * 10.0 - time * 4.0) * 0.5 + 0.5;
    float wave2 = sin(uv.x * 15.0 + time * 3.0) * 0.3;
    float wave3 = sin(uv.y * 6.0 - time * 2.5 + uv.x * 8.0) * 0.4;
    
    float fire = (wave1 + wave2 + wave3) * 0.6;
    
    // Máscara más fuerte en la parte superior de la casa
    float mask = pow(1.0 - uv.y, 1.8);
    fire *= mask * intensity;
    
    // Color del fuego
    vec3 base_color = texture(TEXTURE, uv).rgb;
    vec3 flame_color = mix(vec3(1.0, 0.25, 0.0), vec3(1.0, 0.85, 0.1), fire);
    
    // Mezcla con la textura original + glow
    COLOR.rgb = mix(base_color, flame_color, fire * 0.85);
    COLOR.rgb += flame_color * fire * 1.8;  // brillo
    
    COLOR.a = texture(TEXTURE, uv).a;
}
