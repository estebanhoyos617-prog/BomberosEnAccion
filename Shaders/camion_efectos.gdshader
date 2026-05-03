shader_type canvas_item;

uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rim_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float rim_size : hint_range(1.0, 8.0) = 3.0;
uniform vec4 rim_color : source_color = vec4(1.0, 0.35, 0.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;

	float a_up    = texture(TEXTURE, UV + vec2(0.0, -ps.y * rim_size)).a;
	float a_down  = texture(TEXTURE, UV + vec2(0.0,  ps.y * rim_size)).a;
	float a_left  = texture(TEXTURE, UV + vec2(-ps.x * rim_size, 0.0)).a;
	float a_right = texture(TEXTURE, UV + vec2( ps.x * rim_size, 0.0)).a;
	float rim = (1.0 - tex.a) * ((a_up + a_down + a_left + a_right) / 4.0) * rim_intensity;

	vec3 color = mix(tex.rgb, rim_color.rgb, rim);
	color = mix(color, flash_color.rgb, flash_intensity * tex.a);
	COLOR = vec4(color, tex.a + rim);
}