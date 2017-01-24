#define M_PI 3.14159265

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying float noise;
uniform float time;
varying float vTime;

float persistence = 4.0;
const int octaves = 3;

float noise_gen2(int x, int y, int z) {
	return fract(sin(dot(vec3(x, y, z), vec3(12.9898, 78.233, 43.29179))) * 43758.5453);
}
	
// Smooth Noise
// Takes into account the surrounding noise
float smoothNoise(int x, int y, int z) {
	return noise_gen2(x, y, z);

	
	float center = noise_gen2(x, y, z) / 8.0;	
	float adj = (noise_gen2(x + 1, y, z) + noise_gen2(x - 1, y, z) 
	   + noise_gen2(x, y + 1, z) + noise_gen2(x, y - 1, z) 
	   + noise_gen2(x, y, z + 1) + noise_gen2(x, y, z - 1)) / 16.0;
	float diag = (noise_gen2(x + 1, y + 1, z)
		+ noise_gen2(x + 1, y - 1, z)
		+ noise_gen2(x - 1, y + 1, z)
		+ noise_gen2(x - 1, y - 1, z)
		+ noise_gen2(x + 1, y, z + 1)
		+ noise_gen2(x + 1, y, z - 1)
		+ noise_gen2(x - 1, y, z + 1)
		+ noise_gen2(x - 1, y, z - 1)
		+ noise_gen2(x, y + 1, z + 1)
		+ noise_gen2(x, y + 1, z - 1)
		+ noise_gen2(x, y - 1, z + 1)
		+ noise_gen2(x, y - 1, z - 1)) / 32.0;
	float corners = (noise_gen2(x + 1, y + 1, z + 1)
		+ noise_gen2(x + 1, y + 1, z - 1) 
		+ noise_gen2(x + 1, y - 1, z + 1) 
		+ noise_gen2(x + 1, y - 1, z - 1) 
		+ noise_gen2(x - 1, y + 1, z + 1) 
		+ noise_gen2(x - 1, y + 1, z - 1) 
		+ noise_gen2(x - 1, y - 1, z + 1) 
		+ noise_gen2(x - 1, y - 1, z - 1)) / 64.0;
		
	return center + adj + diag + corners;
}

// Cosine Interpolation
// Interpolates x, between [a, b]
// Typically use [-1, 1]
float cerp(float a, float b, float x) {
	float y = x * M_PI;
	y = (1.0 - cos(y)) * 0.5; // y is inbetween [0, 1]
	return a * (1.0 - y) + b * y; // map y between and b
}

float cerpNoise(float x, float y, float z) {
	int x_whole = int(x);
	float x_fract = fract(x);

	int y_whole = int(y);	
	float y_fract = fract(y);
		
	int z_whole = int(z);
	float z_fract = fract(z);

	float v1 = smoothNoise(x_whole,     y_whole,     z_whole);		
	float v2 = smoothNoise(x_whole + 1, y_whole,     z_whole);

	float v3 = smoothNoise(x_whole,     y_whole + 1, z_whole);		
	float v4 = smoothNoise(x_whole + 1, y_whole + 1, z_whole);

	float v5 = smoothNoise(x_whole,     y_whole,     z_whole + 1);
	float v6 = smoothNoise(x_whole + 1, y_whole,     z_whole + 1);
				
	float v7 = smoothNoise(x_whole,     y_whole + 1, z_whole + 1);
	float v8 = smoothNoise(x_whole + 1, y_whole + 1, z_whole + 1);

		
	// Cerp over the x axis
		
	float x00 = cerp(v1, v2, x_fract);
	float x01 = cerp(v3, v4, x_fract);
	float x10 = cerp(v5, v6, x_fract);
	float x11 = cerp(v7, v8, x_fract);

	float y0 = cerp(x00, x01, y_fract);	
	float y1 = cerp(x10, x11, y_fract);

		
	return cerp(y0, y1, z_fract);
}

// Noise
// Perlin Noise
// Fractional Brownian Motion
float fnoise(float x, float y, float z) {
	float total = 0.0;
	float p = persistence;
	 	
	for (int i = 0; i < octaves - 1; i++) {
		float frequency = pow(2.0, float(i)); 	
		float amplitude = pow(p, float(i)); 	
		total = total + cerpNoise(x * frequency, y * frequency, z * frequency) * amplitude;
	}

	return total;
}

void main() {
    vUv = uv;
    vNormal = normal;
    vTime = time;

    vec3 time_vector = vec3(time);
    noise = fnoise(position[0], position[1], position[2]);
    vec3 displacement = (noise + time) * normal; 
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position + displacement, 1.0 );
    vPosition = vec3(gl_Position);
}