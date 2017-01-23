#define M_PI 3.14159265

varying vec2 vUv;
varying vec3 vNormal;
varying float noise;
uniform sampler2D image;


void main() {
  gl_FragColor = vec4(vNormal, 1.0);
}



float rand(float seed) {
	return 0.0;
}

// Cosine Interpolation
// Interpolates x, between [a, b]
// Typically use [-1, 1]
float cerp(float a, float b, float x) {
	float y = x * M_PI;
	y = (1.0 - cos(y)) * 0.5; // y is inbetween [0, 1]

	return a * (1.0 - y) + b * y; // map y between and b
}

// Noise
// Perlin Noise
// Fractional Brownian Motion
float fnoise(float x, float y, float z) {
	return 0.0;
}

float smoothNoise(float x, float y, float z) {
	float center = fnoise(x, y, z) / 8.0;
	float adj = (fnoise(x + 1.0, y, z) + fnoise(x - 1.0, y, z) 
			   + fnoise(x, y + 1.0, z) + fnoise(x, y - 1.0, z) 
			   + fnoise(x, y, z + 1.0) + fnoise(x, y, z - 1.0)) / 16.0;
	float diag = (fnoise(x + 1.0, y + 1.0, z)
				+ fnoise(x + 1.0, y - 1.0, z)
				+ fnoise(x - 1.0, y + 1.0, z)
				+ fnoise(x - 1.0, y - 1.0, z)
				+ fnoise(x + 1.0, y, z + 1.0)
				+ fnoise(x + 1.0, y, z - 1.0)
				+ fnoise(x - 1.0, y, z + 1.0)
				+ fnoise(x - 1.0, y, z - 1.0)
				+ fnoise(x, y + 1.0, z + 1.0)
				+ fnoise(x, y + 1.0, z - 1.0)
				+ fnoise(x, y - 1.0, z + 1.0)
				+ fnoise(x, y - 1.0, z - 1.0)) / 32.0;
	float corners = (fnoise(x + 1.0, y + 1.0, z + 1.0)
				+ fnoise(x + 1.0, y + 1.0, z - 1.0) 
				+ fnoise(x + 1.0, y - 1.0, z + 1.0) 
				+ fnoise(x + 1.0, y - 1.0, z - 1.0) 
				+ fnoise(x - 1.0, y + 1.0, z + 1.0) 
				+ fnoise(x - 1.0, y + 1.0, z - 1.0) 
				+ fnoise(x - 1.0, y - 1.0, z + 1.0) 
				+ fnoise(x - 1.0, y - 1.0, z - 1.0)) / 64.0;
	return center + adj + diag + corners;
}

// float noise_gen1(int x) {
// 	x = (x << 13) ^ x;
// 	return (1.0f - (x * (x * x * 15731 + 789221) + 1376312589) & 7fffffff) / 10737741824.0;
// }

// float noise_gen2(int x, int y) {
// 	return fractional_component(sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5453);
// }