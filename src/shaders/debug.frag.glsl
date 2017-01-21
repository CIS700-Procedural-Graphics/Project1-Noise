#define PI 3.14159265359
#define TWO_PI 6.28318530718

varying vec2 vUv;
varying float noise;

uniform float time;

// Reference: https://www.shadertoy.com/view/llBSWc
float bias(float x, float b) {
    b = -log2(1.0 - b);
    return 1.0 - pow(1.0 - pow(x, 1./b), b);
}

float bias2(float x, float b) {
    return smoothstep(b - .1, b + .1, x);
}

// My version of bias, trying to replicate Maya's function
// Basically a step function centered on .5, with a smoooth size of b
float bias3(float x, float b)
{
	b *= .5;
	return smoothstep(b, 1.0 - b, x);
}

// Canonical hash function with a biger prime
float hash(float x)
{
	return fract(sin(x * 7.13) * 268573.103291);
}

// Canonical hash2D function with a biger prime
float hash2D(vec2 x)
{
	float i = dot(x, vec2(123.4031, 46.5244876));
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

float perlin3D(vec3 p)
{
	return p.x;
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

	// Bilinear
	// p3 ------------- p4
	// |       x        |
	// p1 ------------- p2
	float fX = fade1(x.x - p1.x);
	float fY = fade1(x.y - p1.y);

	float i1 = dot(d1, gd1);
	float i2 = dot(d2, gd2);
	float i3 = dot(d3, gd3);
	float i4 = dot(d4, gd4);

	return mix(mix(i1, i2, fX), mix(i3, i4, fX), fY) * 0.707213578 + .5;
}

float grid2D(vec2 x)
{
	vec2 p = floor(x);
	float fX = fade1(x.x - p.x);
	float fY = fade1(x.y - p.y);
	return step(fY, .0001) + step(fX, .0001);
}

// Argument names are inspired on Maya's solidFractal node
float fractal2D(vec2 x, float frequency, float amplitude, float ratio, float frequencyRatio, float b)
{
	float accum = 0.0;

	float result = bias3(perlin2D(x * frequency), b) * amplitude;
	frequency *= frequencyRatio;
	accum += amplitude;
	amplitude *= ratio;

	result += bias3(perlin2D(x * frequency), b) * amplitude;
	frequency *= frequencyRatio;
	accum += amplitude;
	amplitude *= ratio;

	result += bias3(perlin2D(x * frequency), b) * amplitude;
	frequency *= frequencyRatio;
	accum += amplitude;
	amplitude *= ratio;

	result += bias3(perlin2D(x * frequency), b) * amplitude;
	frequency *= frequencyRatio;
	accum += amplitude;
	amplitude *= ratio;

	result += bias3(perlin2D(x * frequency), b) * amplitude;
	frequency *= frequencyRatio;
	accum += amplitude;
	amplitude *= ratio;

	result += bias3(perlin2D(x * frequency), b) * amplitude;
	frequency *= frequencyRatio;
	accum += amplitude;
	amplitude *= ratio;

	result += bias3(perlin2D(x * frequency), b) * amplitude;
	frequency *= frequencyRatio;
	accum += amplitude;
	amplitude *= ratio;

	result += bias3(perlin2D(x * frequency), b) * amplitude;
	accum += amplitude;

	return result / accum;
}

void main() 
{
	vec2 p = vUv + vec2(time * .1);
	// gl_FragColor = vec4(perlin2D(p) * .5 + perlin2D(p * 4.0) * .5 + perlin2D(p * 8.0) * .25 + perlin2D(p * 16.0) * .125);
	// gl_FragColor = vec4(perlin2D(p * 16.0) + grid2D(p * 16.0));

	gl_FragColor = vec4(fractal2D(p, 1.0, 1.0, .707, 2.0, .5));
}