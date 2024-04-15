shader_type canvas_item;

uniform sampler2D level_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D environment_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float u_invert;
uniform float u_vignette;
uniform float u_filmgrain;

uniform float u_abbrLevel;
uniform float u_abbrEnv;

uniform float u_shakeX;
uniform float u_shakeY;

float exp2m1( in float x ) { return exp2(x)-1.0; }

// Different approximations to pow(x,2.2)
float my_pow_22( float x )
{
	// By iq, f(x) = (2ˣ-1 - x·ln2)/(1-ln2)
    return (exp2m1(x)-x*0.693147)*3.258891;

    // Same idea (one extra mul), but better match. By Marc B.Reynolds
    // return (exp2m1(0.718151*x)-0.503456*x)*7.07342;

    // By BigWIngs (see comments), probably best tradeof perf and accuracy
    // return x*x*(0.75 + 0.25*x);

    // By iq (see comments)
    // return x*(1.12*x - 0.12);

    // By Marc B.Reynolds (http://marc-b-reynolds.github.io/math/2019/12/10/GammaRamp.html)
    // return (0.5*x*x)*(sqrt(x)+1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 col = vec4(0.);

	vec2 uv = SCREEN_UV+vec2(u_shakeX,u_shakeY);

	//vec4 env = texture(environment_texture, SCREEN_UV);
	//vec4 level = texture(level_texture, SCREEN_UV);

	// chromatic abberation
	vec2 distFromCenter = uv - 0.5;

	float aberrationAmountEnv = .5;
	float aberrationAmountLevel = .3;

	vec2 p = vec2(my_pow_22(distFromCenter.x),my_pow_22(distFromCenter.y));
	vec2 aberratedEnv = aberrationAmountEnv * p*u_abbrEnv;
	vec4 env = vec4
	(
		texture(environment_texture, uv - aberratedEnv).r,
		texture(environment_texture, uv).g,
		texture(environment_texture, uv + aberratedEnv).b,
		1.0
	);

	vec2 aberratedLevel = aberrationAmountLevel * p*u_abbrLevel;
	vec4 level = vec4
	(
		texture(level_texture, uv - aberratedLevel).r,
		texture(level_texture, uv).g,
		texture(level_texture, uv + aberratedLevel).b,
		1.0
	);

	col = level;
	col.xyz = col.xyz*(1.-env.a) + env.a*env.xyz;

	// grain from https://www.shadertoy.com/view/4sXSWs
	float strength = 16.0; //TODO uniform
    float x = (uv.x + 4.0 ) * (uv.y + 4.0 ) * (TIME * 10.0);
	vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;

	col = col + 1.5*u_filmgrain*grain;

	// vingette
	col.xyz *= 1.-1.5*u_vignette*min(1.,-.25+length(SCREEN_UV*2.-1.));

	// invert
	col.xyz = col.xyz*(1.-u_invert)+u_invert*(vec3(1.)-col.xyz);

	COLOR = col;
}
