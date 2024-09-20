shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


uniform float x;
uniform float y;

void fragment() {
	
	vec2 uv = SCREEN_UV;
	uv -= mod(uv, vec2(x/100.0, y/100.0));
	COLOR.rgb = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;
}
