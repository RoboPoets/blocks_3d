shader_type spatial;
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

group_uniforms albedo;
uniform vec3 albedo_color : source_color = vec3(1.0);

group_uniforms textures;
uniform sampler2D albedo_texture : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D roughness_texture : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform vec3 uv_scale = vec3(0.5);
uniform bool use_triplanar_mapping = true;

varying vec3 uv_triplanar_pos;
varying vec3 uv_power_normal;

vec3 triplanar_texture(sampler2D sampler, vec3 pos) {
	if (use_triplanar_mapping) {
		vec4 samp = vec4(0.0);
		samp += texture(sampler,pos.xy) * uv_power_normal.z;
		samp += texture(sampler,pos.xz) * uv_power_normal.y;
		samp += texture(sampler,pos.zy * vec2(-1.0, 1.0)) * uv_power_normal.x;
		return samp.rgb;
	}
	return texture(sampler, pos.xy).rgb;
}

void vertex() {
	if (use_triplanar_mapping) {
		TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
		TANGENT += vec3(1.0,0.0,0.0) * abs(NORMAL.y);
		TANGENT += vec3(1.0,0.0,0.0) * abs(NORMAL.z);
		TANGENT = normalize(TANGENT);
		BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
		BINORMAL += vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
		BINORMAL += vec3(0.0,1.0,0.0) * abs(NORMAL.z);
		BINORMAL = normalize(BINORMAL);
		uv_power_normal = pow(abs(mat3(MODEL_MATRIX) * NORMAL),vec3(8.0));
		uv_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		uv_power_normal /= dot(uv_power_normal,vec3(1.0));
		uv_triplanar_pos *= vec3(1.0,-1.0, 1.0);
	} else {
		uv_triplanar_pos.xy = UV;
	}
}

void fragment() {
	vec3 albedo_tex = triplanar_texture(albedo_texture,uv_triplanar_pos * uv_scale);
	ALBEDO = albedo_color.rgb * albedo_tex.rgb;
	ROUGHNESS = pow(triplanar_texture(roughness_texture,uv_triplanar_pos * uv_scale).r, 2.0);
}
