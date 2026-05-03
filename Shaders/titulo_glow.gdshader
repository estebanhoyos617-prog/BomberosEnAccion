shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.4, 0.0, 1.0);
uniform float glow_speed : hint_range(0.5, 5.0) = 2.0;
uniform float glow_min : hint_range(0.0, 1.0) = 0.6;
uniform float glow_max : hint_range(0.0, 2.0) = 1.4;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Parpadeo suave tipo fuego
	float pulse = sin(TIME * glow_speed) * 0.5 + 0.5;
	float brightness = mix(glow_min, glow_max, pulse);

	// Mezcla el color original con el glow naranja
	vec3 glowed = mix(tex.rgb, glow_color.rgb, tex.a * 0.4);
	glowed *= brightness;

	COLOR = vec4(glowed, tex.a);
}
