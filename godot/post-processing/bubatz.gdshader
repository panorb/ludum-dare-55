shader_type spatial;
render_mode cull_disabled;

uniform float u_stormStr;
uniform float u_stormSpeed;
uniform float u_stormOpacity;

varying vec3 CAMPOS;
varying flat mat4 modelViewMatrix;

void vertex() {
	CAMPOS = (INV_VIEW_MATRIX * vec4(0, 0, 0, 1)).xyz;
	modelViewMatrix = MODELVIEW_MATRIX;
}

const int NUMSTEPS = 1;
const float MINHIT = 0.02;
const float MAXDIST = 1000.0;
const float infinity = 1.0 / 0.0;

const float baseHeight = .1;

// Thank you Mr. Quilez
// https://iquilezles.org/articles/intersectors/
// cylinder defined by extremes a and b, and radious ra
vec4 cylIntersect( in vec3 ro, in vec3 rd, in vec3 a, in vec3 b, float ra )
{
    vec3  ba = b  - a;
    vec3  oc = ro - a;
    float baba = dot(ba,ba);
    float bard = dot(ba,rd);
    float baoc = dot(ba,oc);
    float k2 = baba            - bard*bard;
    float k1 = baba*dot(oc,rd) - baoc*bard;
    float k0 = baba*dot(oc,oc) - baoc*baoc - ra*ra*baba;
    float h = k1*k1 - k2*k0;
    if( h<0.0 ) return vec4(-1.0);//no intersection
    h = sqrt(h);
    float t = (-k1-h)/k2;
    // body
    float y = baoc + t*bard;
    if( y>0.0 && y<baba ) return vec4( t, (oc+t*rd - ba*y/baba)/ra );
    // caps
    t = ( ((y<0.0) ? 0.0 : baba) - baoc)/bard;
    if( abs(k1+k2*t)<h )
    {
        return vec4( t, ba*sign(y)/sqrt(baba) );
    }
    return vec4(-1.0);//no intersection
}

// normal at point p of cylinder (a,b,ra), see above
vec3 cylNormal( in vec3 p, in vec3 a, in vec3 b, float ra )
{
    vec3  pa = p - a;
    vec3  ba = b - a;
    float baba = dot(ba,ba);
    float paba = dot(pa,ba);
    float h = dot(pa,ba)/baba;
    return (pa - ba*h)/ra;
}

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

//from: https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

//from: https://thebookofshaders.com/13/
float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}
// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)),
                    vec2(-sin(0.5), cos(0.50)));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

float dstSphere(vec3 p, vec3 c, float r)
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

// https://github.com/yiwenl/glsl-fbm/blob/master/3d.glsl
float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod2894f(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm4f(vec4 x){return mod2894f(((x * 34.0) + 1.0) * x);}

float noise3f(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm4f(b.xyxy);
    vec4 k2 = perm4f(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm4f(c);
    vec4 k4 = perm4f(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}


float fbm3f(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise3f(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

vec4 raymarch(vec3 dir, vec3 origin, inout vec3 gnormal, inout bool ghit,inout vec3 gpos,out vec3 flameCol) {
	ghit = false;
	gnormal = vec3(0.);
	
	flameCol = vec3(0.);
	
	float height = .5+.5*sin(TIME)+.1;
	float dist = 0.0;

	float roomHeight = 10.; //TODO uniform
	float roomRadius = 10.;//TODO uniform
	origin += vec3(0.,-roomHeight/2.,0.);

	vec3  capA = vec3(-roomHeight*.5,0.0,0.0);
	vec3  capB = vec3(roomHeight*0.5,0.0,0.0);
	float capR = roomRadius;

	vec3 rotDir = (rotationZ(PI*.5)*vec4(dir,1.)).xyz;
	vec3 rotOrg = (rotationZ(PI*.5)*vec4(origin,1.)).xyz;

	vec4 cylI = cylIntersect( rotOrg, rotDir, capA, capB, capR );
	float begin_dist = cylI.x;
	
	dist = max(0.3,begin_dist);
	vec3 rotCirc = (rotationX(PI*.5)*vec4(origin,1.)).xyz;
	if (dstCylinder(rotCirc,roomRadius,roomHeight) < 0.)
		dist = 0.3;
	 
	for (int i = 0; i < NUMSTEPS; i++) {
		vec3 pos = origin + dist * dir;
		float h = pos.y;

		//storm
		//float stormStr = 1.; //TODO uniform
		//float stime = TIME*2.; //TODO uniform
		float stime = u_stormSpeed*2.;

		pos = (rotationY(PI*.13*h+stime)*vec4(pos,1.)).xyz;

		float time = TIME * u_stormStr*10.;
		float nScale = 2.5;
		//float n = 2.5*fbm(pos.yx*4.*nScale+vec2(time*.2))*fbm(pos.yz*2.*nScale-vec2(.2*time));
		//float n = fbm3f(pos+vec3(0.,0.,0.)*.02);
		float n = 2.5*fbm(pos.yx*4.*nScale+vec2(time*.2));
		
		n = n+.05;
	
		flameCol += .4*vec3(n/float(NUMSTEPS));//*(-h/roomHeight+.3);
		
		dist += n;//len_march/float(NUMSTEPS);
		//if (flameCol.x > 1.) {
		//	gpos = pos;
		//	break;
		//}
	}
	//flameCol = 1.-flameCol;

	return vec4(vec3(0.),0.);
}

void fragment() {
	vec3 CAMDIR = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 1.)).xyz - CAMPOS);
	// Called for every pixel the material is visible on.
	
	vec3 gpos = vec3(0.);
	
	vec3 gnormal = vec3(0.);
	bool ghit = false;
	vec3 flameCol = vec3(0.);
	
	vec4 col = raymarch(CAMDIR,CAMPOS,gnormal,ghit,gpos,flameCol);
	col.w = 1.;
	
	col += 2.*vec4(flameCol,0.);//vec4(gpos-vec3(.5),1.);
	
	ALBEDO = col.xyz*u_stormOpacity;//vec3(0.,1.,0.);
	
	ALPHA = col.x*.5*u_stormOpacity;
	DEPTH = 1./length(gpos-CAMPOS);
	//DEPTH = 1./length(gpos-CAMPOS+vec3(0.,-2.4,0.));
	//DEPTH = 1./length(gpos-CAMPOS+vec3(0.,-2.4,0.));
}

void light() {
	
}
