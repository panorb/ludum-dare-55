shader_type canvas_item;

uniform sampler2D level_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D environment_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 col = vec4(0.);
	
	vec2 uv = SCREEN_UV;
	
	//vec4 env = texture(environment_texture, SCREEN_UV);
	//vec4 level = texture(level_texture, SCREEN_UV);
	
	// chromatic abberation
	vec2 distFromCenter = SCREEN_UV - 0.5;
	
	float aberrationAmountEnv = .5; //TODO uniform
	float aberrationAmountLevel = .3; //TODO uniform
	
	vec2 aberratedEnv = aberrationAmountEnv * pow(distFromCenter, vec2(3.0, 3.0));
	vec4 env = vec4
	(
		texture(environment_texture, SCREEN_UV - aberratedEnv).r,
		texture(environment_texture, SCREEN_UV).g,
		texture(environment_texture, SCREEN_UV + aberratedEnv).b,
		1.0
	);
	
	vec2 aberratedLevel = aberrationAmountLevel * pow(distFromCenter, vec2(3.0, 3.0));
	vec4 level = vec4
	(
		texture(level_texture, SCREEN_UV - aberratedLevel).r,
		texture(level_texture, SCREEN_UV).g,
		texture(level_texture, SCREEN_UV + aberratedLevel).b,
		1.0
	);
	
	col = level;
	col.xyz = col.xyz*col.a + (1.-col.a)*level.xyz;
	
	// grain from https://www.shadertoy.com/view/4sXSWs
	float strength = 16.0; //TODO uniform
    float x = (uv.x + 4.0 ) * (uv.y + 4.0 ) * (TIME * 10.0);
	vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;
	
	col = col + grain;
	
	// vingette
	col.xyz *= 1.-min(1.,-.25+length(SCREEN_UV*2.-1.));
	
	//TODO uniform
	// invert
	col.xyz = vec3(1.)-col.xyz;
	
	COLOR = col;
}
