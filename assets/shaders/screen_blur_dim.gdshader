shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float strength = 1.25;
uniform float dim = 0.25;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = 1.0 / vec2(textureSize(screen_texture, 0));
	vec2 o = px * strength;

	vec4 c = texture(screen_texture, uv) * 0.36;
	c += texture(screen_texture, uv + vec2(o.x, 0.0)) * 0.16;
	c += texture(screen_texture, uv - vec2(o.x, 0.0)) * 0.16;
	c += texture(screen_texture, uv + vec2(0.0, o.y)) * 0.16;
	c += texture(screen_texture, uv - vec2(0.0, o.y)) * 0.16;

	c.rgb *= (1.0 - clamp(dim, 0.0, 0.85));
	COLOR = vec4(c.rgb, 1.0);
}

