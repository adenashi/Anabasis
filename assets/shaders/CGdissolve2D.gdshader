shader_type canvas_item;
render_mode unshaded;

// Used for the dissolve effect
uniform sampler2D noise_texture;

// Using a GradientTexture1D
uniform sampler2D burn_texture;

instance uniform float integrity : hint_range(0.0, 1.0) = 1.0;

// How large the burn is.
uniform float burn_size: hint_range(1.0, 1.5) = 1.3;

// For canvas group
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float inverse_lerp(float a, float b, float v) {
	return (v - a) / (b - a);
}

// Called for every pixel the material is visible on
void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	// Sample the noise texture
	// Multiply by UV.y to make the effect scale vertically
	float noise = texture(noise_texture, UV).r * UV.y;
	// Step returns 0 when noise > integrity or 1 when noise < integrity
	vec4 base_color = texture(TEXTURE, UV) * step(noise, integrity);
	// Compute UVs for the burn texture. Converts it to a range between 0 and 1.
	vec2 burn_uv = vec2(inverse_lerp(integrity, integrity * burn_size, noise), 0.0);
	// Sample the burn texture
	vec4 burn_color = texture(burn_texture, burn_uv) * step(noise, integrity * burn_size);
	// Lerp between the two end colors.
	
	COLOR = mix(burn_color, base_color, base_color.a);
	COLOR *= c;
}
