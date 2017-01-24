varying vec2 vUv;
varying vec3 color;
uniform float time;
varying float noise;
varying float noise2;
uniform bool pixelate;
uniform float pixelPower;

float M_PI = 3.14159265358979323;

/*
 * Generates pseudo-random noise from (x, y, z)
 * From http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
 */
float noise_gen1(float x, float y, float z) {
	return fract(sin(dot(vec3(x, y, z) ,vec3(12.9898,78.233, 34.2838))) * 43758.5453);
}

/**
 * Cosine interpolates t between a and b
 * From the noise lecture (slide 26)
 */
float cosine_interp(float a, float b, float t) {
	float cos_t = (1.0 - cos(t * M_PI)) * 0.5;
	return a * (1.0 - cos_t) + b * cos_t;
}

/**
 * Interpolates the noise at (x, y, z) based on the 8 surrounding lattice 
 * values (determined by the frequency)
 */
float interp_noise(float x, float y, float z, float freq) { 
	float x0 = floor(x * freq) / freq,
		y0 = floor(y * freq) / freq,
		z0 = floor(z * freq) / freq,
	 	x1 = (x0 * freq + 1.0) / freq,
	 	y1 = (y0 * freq + 1.0) / freq,
	 	z1 = (z0 * freq + 1.0) / freq;

	float p1 = noise_gen1(x0, y0, z0),
		p2 = noise_gen1(x1, y0, z0),
		p3 = noise_gen1(x0, y1, z0),
		p4 = noise_gen1(x0, y0, z1),
		p5 = noise_gen1(x0, y1, z1),
		p6 = noise_gen1(x1, y1, z0),
		p7 = noise_gen1(x1, y0, z1),
		p8 = noise_gen1(x1, y1, z1);

	float dx = (x - x0) / (x1 - x0),
		dy = (y - y0) / (y1 - y0),
		dz = (z - z0) / (z1 - z0);

	// Interpolate along x
	float a1 = cosine_interp(p1, p2, dx),
		a2 = cosine_interp(p4, p7, dx), 
		a3 = cosine_interp(p3, p6, dx),
		a4 = cosine_interp(p5, p8, dx);

	// Interpolate along y
	float b1 = cosine_interp(a1, a3, dy),
		b2 = cosine_interp(a2, a4, dy);

	// Interpolate along z
	float c = cosine_interp(b1, b2, dz);
	return c; 
}


const float NUM_OCTAVES = 50.0;

/**
 * Sums NUM_OCTAVES octaves of increasingly smaller noise offsets
 * From the noise lecture (slide 29)
 */
float multi_octave_noise (float x, float y, float z) {
	float total = 0.0;
	float persistence = 0.5;

	for (float i = 0.0; i < NUM_OCTAVES; i += 1.0) {
		float freq = pow(2.0, 1.0);
		float amp = pow(persistence, 1.0);

		total += interp_noise(x, y, z, freq) * amp;
	}

	return total;
}

void main() {
    vUv = uv;

    float noise_offset;
    if (pixelate) {
    	noise_offset = floor(multi_octave_noise(position.x + time, position.y + time, position.z + time) / pixelPower) * pixelPower;
    } else {
    	noise_offset = multi_octave_noise(position.x + time, position.y + time, position.z + time);
    }
    vec4 noise_pos = vec4(position.xyz + normal * 2.0 * noise_offset, 1.0);
    noise = noise_offset;

    noise2 = noise_gen1(position.x + 0.00012321, position.y+ 0.23423, position.z+ 0.1232);

    gl_Position = projectionMatrix * modelViewMatrix * noise_pos;
}