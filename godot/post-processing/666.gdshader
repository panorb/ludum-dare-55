shader_type spatial;
render_mode cull_disabled;

//uniform float u_height;

varying vec3 CAMPOS;
varying flat mat4 modelViewMatrix;

void vertex() {
	CAMPOS = (INV_VIEW_MATRIX * vec4(0, 0, 0, 1)).xyz;
	modelViewMatrix = MODELVIEW_MATRIX;
}

const int NUMSTEPS = 32;
const float MINHIT = 0.025;
const float MAXDIST = 1000.0;
const float infinity = 1.0 / 0.0;

const float baseHeight = .1;

//TODO return rotations as mat3
mat4 rotationX(float angle)
{
	return mat4(	vec4(1.0,		0,			0,			0),
					vec4(0, 	cos(angle),	-sin(angle),		0),
					vec4(0, 	sin(angle),	 cos(angle),		0),
					vec4(0, 			0,			  0, 		1));
}

mat4 rotationY(float angle)
{
	return mat4(	vec4(cos(angle),		0,		sin(angle),	0),
			 		vec4(		0,		1.0,			 0,	0),
					vec4(-sin(angle),	0,		cos(angle),	0),
					vec4(		0, 		0,				0,	1));
}

mat4 rotationZ(float angle)
{
	return mat4(	vec4(cos(angle),		-sin(angle),	0,	0),
			 		vec4(sin(angle),		cos(angle),		0,	0),
					vec4(		0,				0,		1,	0),
					vec4(		0,				0,		0,	1));
}

float dstSphere(vec2 p, vec2 c, float r)
{
    return length(p-c)-r;
}

float dstCube2(vec2 p, vec2 halfdim)
{
	vec2 dist = abs(p) - (halfdim);
	return length(max(dist,0.0)) + min(max(dist.x,dist.y),0.0);
}

float dstCube3(vec3 p, vec3 halfdim)
{
	vec3 dist = abs(p) - (halfdim);
	return length(max(dist,0.0)) + min(max(dist.x,max(dist.y,dist.z)),0.0);
}

float dstTorus(vec2 p, float diameter, float center)
{
	vec2 q = vec2(length(p.x)-diameter,p.y);
	return length(q)-center;
}

float dstCylinder( vec3 p, float h, float r )
{
	vec2 d = abs(vec2(length(p.xy),p.z)) - vec2(h,r);
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

// from https://iquilezles.org/articles/distfunctions/
float sdPlane( vec2 p, vec2 n, float h )
{
  // n must be normalized
  return dot(p,n) + h;
}

// from https://iquilezles.org/articles/distfunctions/
float sdCone( vec3 p, vec2 c, float h )
{
  float q = length(p.xz);
  return max(dot(c.xy,vec2(q,p.y)),-h-p.y);
}

float unite( float a, float b){return min(a, b);}
float subtract( float a, float b ){ return max(-a, b); }
float intersect( float a, float b ){ return max(a, b); }

float distFunc(vec3 ray, inout vec3 gpos,float height) {
	float shape = infinity;
	
	{
		vec3 pos = ray;
		gpos = pos;
		
		float heightScale = pos.y*.2;

		pos.y -= height;
		
		vec3 rotCirc = (rotationX(PI*.5)*vec4(pos,1.)).xyz;
		shape = min(shape,dstCylinder(rotCirc,2.6,.06+height));
		shape = subtract(shape,dstCylinder(rotCirc,3.+heightScale,.01+height));
		
		for (int i =0;i<5;++i) {
			float ofst = .9;
			vec3 rotStrip = pos;
			rotStrip = (rotationY(float(i)*2.*PI/5.)*vec4(rotStrip,1.)).xyz;
			rotStrip.x -= ofst;
			shape = min(shape,dstCube3(rotStrip,vec3(0.1+height*.2,0.01+height,2.7+heightScale)));
		}
	}
	
	return shape;
}

float distMarch(vec3 ray, inout vec3 gpos,float height) {
	float shape = infinity;
	
	{
		vec3 pos = ray;
		gpos = pos;
		
		float heightScale = pos.y*.2;

		pos.y -= height;
		
		vec3 rotCirc = (rotationX(PI*.5)*vec4(pos,1.)).xyz;
		shape = min(shape,dstCylinder(rotCirc,2.6,.06+height));
		shape = subtract(shape,dstCylinder(rotCirc,3.+heightScale,.01+height));
		
		for (int i =0;i<5;++i) {
			float ofst = .9;
			vec3 rotStrip = pos;
			rotStrip = (rotationY(float(i)*2.*PI/5.)*vec4(rotStrip,1.)).xyz;
			rotStrip.x -= ofst;
			shape = min(shape,dstCube3(rotStrip,vec3(0.1+height*.2,0.01+height,2.7+heightScale)));
		}
	}
	
	return shape;
}

vec4 raymarch(vec3 dir, vec3 origin, inout vec3 gnormal, inout bool ghit,inout vec3 gpos,out vec3 flameCol) {
	ghit = false;
	gnormal = vec3(0.);
	
	flameCol = vec3(0.);
	
	float u_height = 1.;
	
	vec3 scale = vec3(0.85);
	
	// u_height from 0 to 1 float height = .5+.5*sin(u_time)+.1;
	float dist = 0.0;
	for (int i = 0; i < NUMSTEPS; i++) {
		vec3 pos = origin + dist * dir;

		float closest = distMarch(pos*scale,gpos,u_height+.1);
		if (closest < MINHIT) {
			flameCol += vec3(.02*(2.-.5*pos.y),0.,0.);
			float gradeUp = clamp(pos.y,0.,1.)*.3-.4;
			flameCol += vec3(0.,gradeUp*.1,gradeUp*.1);
			dist += .2;
		} else
			dist += closest;
	}

	dist = 0.0;
	for (int i = 0; i < NUMSTEPS; i++) {
		vec3 pos = origin + dist * dir;
		
		float closest = distFunc(pos*scale,gpos,0.);

		if (closest < MINHIT) {
			float depth = log(log(length(pos-origin)))*0.5;
			ghit = true;
			return vec4(vec3(.5+.5*u_height,0.,0.), 1.);
		}
		if (dist > MAXDIST)
			return vec4(vec3(0.),0.);
		dist += closest;
	}
	
	return vec4(vec3(0.),0.);
}

void fragment() {
	vec3 CAMDIR = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 1.)).xyz - CAMPOS);
	// Called for every pixel the material is visible on.
	
	vec3 gpos = vec3(0.);

	vec3 gnormal = vec3(0.);
	bool ghit = false;
	vec3 flameCol = vec3(0.);
	vec4 col = raymarch(CAMDIR, CAMPOS+vec3(0.,-2.4,0.),gnormal,ghit,gpos,flameCol);
	float alpha = col.w;//length(gpos-CAMPOS);
	//col.w = 1.;
	
	//col += vec4(flameCol,0.);//vec4(gpos-vec3(.5),1.);
	
	//ALPHA = max(0.,flameCol.x); //TODO
	//flameCol.xyz = max(flameCol.xyz,col.www);
	EMISSION = flameCol*.5;
	ALPHA = max(col.w,flameCol.x);
	ALBEDO = col.xyz+flameCol;//vec3(0.,1.,0.);
	DEPTH = 1./length(gpos-CAMPOS+vec3(0.,-2.4,0.));
}

void light() {
	
}
