#define PI 3.14159265359
#define TWO_PI 6.28318530718

varying vec2 vUv;

uniform float time;
uniform float bias;
uniform float frequency;
uniform float ratio;
uniform float frequencyRatio;

// Note: there's not a lot of optimization here, because my goal is to explore stuff in a very clear manner.
// For example, most of perlin noise implementation use precomputed gradients, etc.

// Reference: https://www.shadertoy.com/view/llBSWc
float bias1(float x, float b) {
    b = -log2(1.0 - b);
    return 1.0 - pow(1.0 - pow(x, 1./b), b);
}

float bias2(float x, float b) {
    return smoothstep(b - .1, b + .1, x);
}

// My version of bias, trying to replicate Maya's function
// Basically a step function centered on .5, with a smooth length of b
float bias3(float x, float b)
{
	b *= .5;
	return smoothstep(b, 1.0 - b, x);
}

// We can use a hash as seed for a linear congruential generator
float lcg(float x)
{
	return mod(x * 25214903917.0 + 28411.0, 1306633.0) / 1306633.0;
}

// Canonical hash function with a biger prime
float hash(float x)
{
	return fract(sin(x * 7.13) * 268573.103291);
}

// Projected into 1D, multiplying PI by some prime and using as axis
float hash2D(vec2 x)
{
	float i = dot(x, vec2(123.4031, 46.5244876));
	return fract(sin(i * 7.13) * 268573.103291);
}

// Projected into 1D
float hash3D(vec3 x)
{
	float i = dot(x, vec3(123.4031, 46.5244876, 91.106168));
	return fract(sin(i * 7.13) * 268573.103291);
}

// Projected into 1D
float hash4D(vec4 x)
{
	float i = dot(x, vec4(123.4031, 46.5244876, 91.106168, 128.805272));
	return fract(sin(i * 7.13) * 268573.103291);
}

float fade1(float t)
{
	float t3 = t * t * t;
	return 6.0 * t3 * t * t - 15.0 * t3 * t + 10.0 * t3;
}

// Does not look as good as fade1, probably due to the derivative
float fade2(float t)
{
	return smoothstep(0.0, 1.0, t);
}

vec4 gradient4D(vec4 x)
{
	float h = hash4D(x);
	float r1 = lcg(lcg(h));
	float r2 = lcg(lcg(r1));
	float r3 = lcg(lcg(r2));
	return normalize(vec4(h, r1, r2, r3) * 2.0 - 1.0);
}

float perlin4D(vec4 p)
{
	// W = 0
	vec4 p1 = floor(p);
	vec4 p2 = p1 + vec4(1.0, 0.0, 0.0, 0.0);
	vec4 p3 = p1 + vec4(0.0, 1.0, 0.0, 0.0);
	vec4 p4 = p1 + vec4(1.0, 1.0, 0.0, 0.0);

	vec4 p5 = p1 + vec4(0.0, 0.0, 1.0, 0.0);
	vec4 p6 = p1 + vec4(1.0, 0.0, 1.0, 0.0);
	vec4 p7 = p1 + vec4(0.0, 1.0, 1.0, 0.0);
	vec4 p8 = p1 + vec4(1.0, 1.0, 1.0, 0.0);

	// W = 1
	vec4 p9 = p1 + vec4(0.0, 0.0, 0.0, 1.0);
	vec4 p10 = p1 + vec4(1.0, 0.0, 0.0, 1.0);
	vec4 p11 = p1 + vec4(0.0, 1.0, 0.0, 1.0);
	vec4 p12 = p1 + vec4(1.0, 1.0, 0.0, 1.0);

	vec4 p13 = p1 + vec4(0.0, 0.0, 1.0, 1.0);
	vec4 p14 = p1 + vec4(1.0, 0.0, 1.0, 1.0);
	vec4 p15 = p1 + vec4(0.0, 1.0, 1.0, 1.0);
	vec4 p16 = p1 + vec4(1.0, 1.0, 1.0, 1.0);

	// Gradients
	vec4 gd1 = gradient4D(p1);
	vec4 gd2 = gradient4D(p2);
	vec4 gd3 = gradient4D(p3);
	vec4 gd4 = gradient4D(p4);

	vec4 gd5 = gradient4D(p5);
	vec4 gd6 = gradient4D(p6);
	vec4 gd7 = gradient4D(p7);
	vec4 gd8 = gradient4D(p8);

	vec4 gd9 = gradient4D(p9);
	vec4 gd10 = gradient4D(p10);
	vec4 gd11 = gradient4D(p11);
	vec4 gd12 = gradient4D(p12);

	vec4 gd13 = gradient4D(p13);
	vec4 gd14 = gradient4D(p14);
	vec4 gd15 = gradient4D(p15);
	vec4 gd16 = gradient4D(p16);

	// Directions
	vec4 d1 = p - p1;
	vec4 d2 = p - p2;
	vec4 d3 = p - p3;
	vec4 d4 = p - p4;

	vec4 d5 = p - p5;
	vec4 d6 = p - p6;
	vec4 d7 = p - p7;
	vec4 d8 = p - p8;

	vec4 d9 = p - p9;
	vec4 d10 = p - p10;
	vec4 d11 = p - p11;
	vec4 d12 = p - p12;

	vec4 d13 = p - p13;
	vec4 d14 = p - p14;
	vec4 d15 = p - p15;
	vec4 d16 = p - p16;

	// Interpolation remapping
	float fX = fade1(p.x - p1.x);
	float fY = fade1(p.y - p1.y);
	float fZ = fade1(p.z - p1.z);
	float fW = fade1(p.w - p1.w);

	// Influences
	float i1 = dot(d1, gd1);
	float i2 = dot(d2, gd2);
	float i3 = dot(d3, gd3);
	float i4 = dot(d4, gd4);

	float i5 = dot(d5, gd5);
	float i6 = dot(d6, gd6);
	float i7 = dot(d7, gd7);
	float i8 = dot(d8, gd8);

	float i9 = dot(d9, gd9);
	float i10 = dot(d10, gd10);
	float i11 = dot(d11, gd11);
	float i12 = dot(d12, gd12);

	float i13 = dot(d13, gd13);
	float i14 = dot(d14, gd14);
	float i15 = dot(d15, gd15);
	float i16 = dot(d16, gd16);

	// Quadrilinear, hypercube
	// W = 0
	// p3 ------------- p4
	// |                |
	// p1 ------------- p2
	// p7 ------------- p8
	// |                |
	// p5 ------------- p6
	//         x
	// W = 1
	// p11 ------------- p12
	// |                |
	// p9 ------------- p10
	// p15 ------------- p16
	// |                |
	// p13 ------------- p14

	float m1 = mix(mix(i1, i2, fX), mix(i3, i4, fX), fY);
	float m2 = mix(mix(i5, i6, fX), mix(i7, i8, fX), fY);
	float w1 = mix(m1, m2, fZ);

	float m3 = mix(mix(i9, i10, fX), mix(i11, i12, fX), fY);
	float m4 = mix(mix(i13, i14, fX), mix(i15, i16, fX), fY);
	float w2 = mix(m3, m4, fZ);

	return mix(w1, w2, fW) * 0.707213578 + .5;;
}

vec3 gradient3D(vec3 x)
{
	float h = hash3D(x);
	float r1 = lcg(lcg(h));
	float r2 = lcg(lcg(r1));
	return normalize(vec3(h, r1, r2) * 2.0 - 1.0);
}

float perlin3D(vec3 p)
{
	// Z = 0
	vec3 p1 = floor(p);
	vec3 p2 = p1 + vec3(1.0, 0.0, 0.0);
	vec3 p3 = p1 + vec3(0.0, 1.0, 0.0);
	vec3 p4 = p1 + vec3(1.0, 1.0, 0.0);

	// Z = 1
	vec3 p5 = p1 + vec3(0.0, 0.0, 1.0);
	vec3 p6 = p1 + vec3(1.0, 0.0, 1.0);
	vec3 p7 = p1 + vec3(0.0, 1.0, 1.0);
	vec3 p8 = p1 + vec3(1.0, 1.0, 1.0);

	// Gradient directions
	vec3 gd1 = gradient3D(p1);
	vec3 gd2 = gradient3D(p2);
	vec3 gd3 = gradient3D(p3);
	vec3 gd4 = gradient3D(p4);

	vec3 gd5 = gradient3D(p5);
	vec3 gd6 = gradient3D(p6);
	vec3 gd7 = gradient3D(p7);
	vec3 gd8 = gradient3D(p8);

	// Directions
	vec3 d1 = p - p1;
	vec3 d2 = p - p2;
	vec3 d3 = p - p3;
	vec3 d4 = p - p4;

	vec3 d5 = p - p5;
	vec3 d6 = p - p6;
	vec3 d7 = p - p7;
	vec3 d8 = p - p8;

	// Interpolation remapping
	float fX = fade1(p.x - p1.x);
	float fY = fade1(p.y - p1.y);
	float fZ = fade1(p.z - p1.z);

	// Influences
	float i1 = dot(d1, gd1);
	float i2 = dot(d2, gd2);
	float i3 = dot(d3, gd3);
	float i4 = dot(d4, gd4);

	float i5 = dot(d5, gd5);
	float i6 = dot(d6, gd6);
	float i7 = dot(d7, gd7);
	float i8 = dot(d8, gd8);

	// Trilinear
	// Z = 0
	// p3 ------------- p4
	// |               |
	// p1 ------------- p2
	//         x
	// Z = 1
	// p7 ------------- p8
	// |                |
	// p5 ------------- p6	
	float m1 = mix(mix(i1, i2, fX), mix(i3, i4, fX), fY);
	float m2 = mix(mix(i5, i6, fX), mix(i7, i8, fX), fY);

	return mix(m1, m2, fZ) * 0.707213578 + .5;
}

float perlin2D(vec2 x)
{
	// Grid points
	vec2 p1 = floor(x);
	vec2 p2 = p1 + vec2(1.0, 0.0);
	vec2 p3 = p1 + vec2(0.0, 1.0);
	vec2 p4 = p1 + vec2(1.0, 1.0);

	// Gradient angles
	float g1 = hash2D(p1) * TWO_PI;
	float g2 = hash2D(p2) * TWO_PI;
	float g3 = hash2D(p3) * TWO_PI;
	float g4 = hash2D(p4) * TWO_PI;

	// Gradient directions
	vec2 gd1 = vec2(cos(g1), sin(g1));
	vec2 gd2 = vec2(cos(g2), sin(g2));
	vec2 gd3 = vec2(cos(g3), sin(g3));
	vec2 gd4 = vec2(cos(g4), sin(g4));

	// Directions to grid points
	vec2 d1 = x - p1;
	vec2 d2 = x - p2;
	vec2 d3 = x - p3;
	vec2 d4 = x - p4;

	// Interpolation remapping
	float fX = fade1(x.x - p1.x);
	float fY = fade1(x.y - p1.y);

	// Influences
	float i1 = dot(d1, gd1);
	float i2 = dot(d2, gd2);
	float i3 = dot(d3, gd3);
	float i4 = dot(d4, gd4);

	// Bilinear
	// p3 ------------- p4
	// |       x        |
	// p1 ------------- p2
	return mix(mix(i1, i2, fX), mix(i3, i4, fX), fY) * 0.707213578 + .5;
}

float grid2D(vec2 x)
{
	vec2 p = floor(x);
	float fX = fade1(x.x - p.x);
	float fY = fade1(x.y - p.y);
	return step(fY, .0001) + step(fX, .0001);
}

float grid3D(vec3 x)
{
	vec3 p = floor(x);
	float fX = fade1(x.x - p.x);
	float fY = fade1(x.y - p.y);
	float fZ = fade1(x.z - p.z);
	return step(fY, .0001) + step(fX, .0001) + step(fZ, .0001);
}

// Argument names are inspired on Maya's solidFractal node
float fractal2D(vec2 x, float b)
{
	float accum = 0.0;
	float freq = frequency;
	float ampl = 1.0; // Because we later remap stuff, initial amplitude is always 1

	float result = bias3(perlin2D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin2D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin2D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin2D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin2D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin2D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin2D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin2D(x * freq), b) * ampl;
	accum += ampl;

	return result / accum;
}


// Argument names are inspired on Maya's solidFractal node
float fractal3D(vec3 x, float b)
{
	float accum = 0.0;
	float freq = frequency;
	float ampl = 1.0; // Because we later remap stuff, initial amplitude is always 1

	float result = bias3(perlin3D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin3D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin3D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin3D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin3D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin3D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin3D(x * freq), b) * ampl;
	freq *= frequencyRatio;
	accum += ampl;
	ampl *= ratio;

	result += bias3(perlin3D(x * freq), b) * ampl;
	accum += ampl;

	return result / accum;
}

void main() 
{
	vec2 p = vUv + vec2(time * .1);

	// 2D
	// gl_FragColor = vec4(fractal2D(p, 10.0, 1.0, .8, 2.0, .8) + grid2D(p * 8.0));

	// 3D projected into 2D
	gl_FragColor = vec4(fractal3D(vec3(vUv, time * .1) * 1.0, bias));
}