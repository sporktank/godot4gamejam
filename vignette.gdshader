shader_type canvas_item;

const float R = 320.0/192.0;

//uniform float vignette_intensity = 0.4;
//uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_rgb : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float width : hint_range(0.0, 0.5) = 0.1;
uniform float maximum : hint_range(0.0, 1.0) = 1.0;
uniform float exponent : hint_range(0.1, 10.0) = 1.0;
uniform int steps : hint_range(1, 256) = 256;

float vignette(vec2 uv){
	//uv *= 1.0 - uv.xy;
	//float vignette = uv.x * uv.y * 15.0;
	//return pow(vignette, vignette_intensity * vignette_opacity);
	
	float h = width;
	float v = width * R;
	//float result = min(
	//	min(clamp((uv.x - 0.0) / h, 0, 1), clamp((1.0 - uv.x) / h, 0, 1)),
	//	min(clamp((uv.y - 0.0) / v, 0, 1), clamp((1.0 - uv.y) / v, 0, 1))
	//); 
	float result = (
		min(clamp((uv.x - 0.0) / h, 0, 1), clamp((1.0 - uv.x) / h, 0, 1)) *
		min(clamp((uv.y - 0.0) / v, 0, 1), clamp((1.0 - uv.y) / v, 0, 1))
	); 
	result = pow(result, exponent);
	result = floor(result * float(steps)) / float(steps);
	return result * maximum + (1.0 - maximum);
}

void fragment(){
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 text = texture(TEXTURE, UV);
	
	text.rgba *= (vignette_rgb.rgba);
	text.rgba *= (1.0 - vignette(UV));
	
	COLOR = vec4((text.rgb)*color.rgb,text.a);
}