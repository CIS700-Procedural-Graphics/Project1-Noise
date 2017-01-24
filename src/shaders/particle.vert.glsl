varying vec2 vUv;
varying vec3 vNormal;

uniform float time;
uniform int frequencyBands[64];

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

vec4 fade1_4D(vec4 t)
{
	vec4 t3 = t * t * t;
	vec4 t4 = t3 * t;
	return 6.0 * t4 * t - 15.0 * t4 + 10.0 * t3;
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
	// return normalize(vec4(h, r1, r2, r3) * 2.0 - 1.0);

	// Faking it
	return vec4(h, r1, r2, r3) * 2.0 - vec4(1.0);
}

vec4 perlin4D_Deriv(vec4 p)
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

	vec4 factors = fade1_4D(fract(p));

	vec4 m1 = mix(mix(gd1, gd2, factors.x), mix(gd3, gd4, factors.x), factors.y);
	vec4 m2 = mix(mix(gd5, gd6, factors.x), mix(gd7, gd8, factors.x), factors.y);
	vec4 w1 = mix(m1, m2, factors.z);

	vec4 m3 = mix(mix(gd9, gd10, factors.x), mix(gd11, gd12, factors.x), factors.y);
	vec4 m4 = mix(mix(gd13, gd14, factors.x), mix(gd15, gd16, factors.x), factors.y);
	vec4 w2 = mix(m3, m4, factors.z);

	return normalize(mix(w1, w2, factors.w));
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
	p1 = p - p1;
	p2 = p - p2;
	p3 = p - p3;
	p4 = p - p4;

	p5 = p - p5;
	p6 = p - p6;
	p7 = p - p7;
	p8 = p - p8;

	p9 = p - p9;
	p10 = p - p10;
	p11 = p - p11;
	p12 = p - p12;

	p13 = p - p13;
	p14 = p - p14;
	p15 = p - p15;
	p16 = p - p16;

	// Influences
	float i1 = dot(p1, gd1);	
	float i2 = dot(p2, gd2);
	float i3 = dot(p3, gd3);
	float i4 = dot(p4, gd4);

	float i5 = dot(p5, gd5);
	float i6 = dot(p6, gd6);
	float i7 = dot(p7, gd7);
	float i8 = dot(p8, gd8);

	float i9 = dot(p9, gd9);
	float i10 = dot(p10, gd10);
	float i11 = dot(p11, gd11);
	float i12 = dot(p12, gd12);

	float i13 = dot(p13, gd13);
	float i14 = dot(p14, gd14);
	float i15 = dot(p15, gd15);
	float i16 = dot(p16, gd16);

	// Interpolation factors
	vec4 factors = fade1_4D(p1);

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

	float m1 = mix(mix(i1, i2, factors.x), mix(i3, i4, factors.x), factors.y);
	float m2 = mix(mix(i5, i6, factors.x), mix(i7, i8, factors.x), factors.y);
	float w1 = mix(m1, m2, factors.z);

	float m3 = mix(mix(i9, i10, factors.x), mix(i11, i12, factors.x), factors.y);
	float m4 = mix(mix(i13, i14, factors.x), mix(i15, i16, factors.x), factors.y);
	float w2 = mix(m3, m4, factors.z);

	return mix(w1, w2, factors.w) * 0.707213578 + .5;
}

void main() 
{
    vUv = uv;
    vNormal = normalMatrix * normal;

    vec3 pos = position;
    vec4 tPos = vec4(pos * .05+ vec3(time), time * .25);

    float noise = perlin4D(tPos) * 10.0;
    float radius = length(pos.xz * .045); 

    float f = float(frequencyBands[int(floor(mod(radius * 8.0, 32.0)))]);

    f = smoothstep(0.0, 1.0, f / 256.0);

    float a = (atan(pos.z, pos.x)) / 6.14159265359;
    float angle = abs(.5 - fract(a + time * .2)) / .5;

    float angleSpike = pow(angle, 8.0);

    pos.y *= (1.0 + angleSpike * 1.0);
    pos.y += angleSpike * 10.0;
    pos.y +=  pow(radius, 3.0) + pow(f, 4.0) * 16.0 + noise * .5 * f;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0 );
}