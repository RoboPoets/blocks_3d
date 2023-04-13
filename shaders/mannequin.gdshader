shader_type spatial;

group_uniforms colors;
uniform vec3 highlight_color: source_color = vec3(0.31, 0.61, 0.85);
uniform float color_anim_speed = 0.1;

group_uniforms textures;
uniform sampler2D albedo_texture : repeat_disable, filter_linear_mipmap, source_color;
uniform sampler2D normal_texture : repeat_disable, filter_linear_mipmap, hint_normal;
uniform sampler2D orm_texture : repeat_disable, filter_linear_mipmap;
uniform sampler2D logo_texture : repeat_disable, filter_linear_mipmap, hint_default_black;

// Algorithm adapted from https://www.shadertoy.com/view/XljGzV
vec3 shift_hue(vec3 color, float shift) {
	vec3 p = vec3(0.55735) * dot(vec3(0.55735), color);
	vec3 u = color-p;  
	vec3 v = cross(vec3(0.55735), u);    
	color = u * cos(shift * 6.2832) + v * sin(shift * 6.2832) + p;  
	return color;
}

void fragment() {
	vec3 orm_mask = texture(orm_texture, UV).rgb;
	ROUGHNESS = orm_mask.g;
	METALLIC = orm_mask.b;
	
	vec4 albedo = texture(albedo_texture, UV);
	ALBEDO = mix(highlight_color, albedo.rgb, albedo.a);
	
	float logo_mask = texture(logo_texture, UV2).r;
	vec3 logo_color = shift_hue(vec3(1.0, 0.0, 0.0), TIME * color_anim_speed);
	EMISSION = logo_color * logo_mask;
	
	NORMAL_MAP = texture(normal_texture, UV).rgb;
}
