shader_type canvas_item;

uniform float speed : hint_range(0.1, 5.0) = 1.5;
uniform float intensity : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec2 uv = UV;
	float time = TIME * speed;

	// Ruido de llamas
	float n1 = sin(uv.x * 8.0 + time * 1.3) * 0.5 + 0.5;
	float n2 = sin(uv.x * 14.0 - time * 0.9 + 1.5) * 0.5 + 0.5;
	float n3 = sin(uv.x * 5.0 + time * 2.1 + 3.0) * 0.5 + 0.5;
	float noise = (n1 + n2 + n3) / 3.0;

	// La llama sube desde abajo
	float flame = (1.0 - uv.y) * (0.4 + noise * 0.6);
	flame = pow(flame, 1.8);
	flame *= intensity;

	// Colores: negro → rojo → naranja → amarillo
	vec3 color_base = vec3(0.08, 0.02, 0.0);
	vec3 color_rojo = vec3(0.8, 0.1, 0.0);
	vec3 color_naranja = vec3(1.0, 0.45, 0.0);
	vec3 color_amarillo = vec3(1.0, 0.9, 0.2);

	vec3 color = color_base;
	color = mix(color, color_rojo, smoothstep(0.0, 0.3, flame));
	color = mix(color, color_naranja, smoothstep(0.2, 0.6, flame));
	color = mix(color, color_amarillo, smoothstep(0.5, 1.0, flame));

	COLOR = vec4(color, 1.0);
}
