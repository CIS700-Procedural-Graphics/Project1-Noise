varying vec2 vUv;
varying vec3 color;
uniform float time;
varying float noise;
float M_PI = 3.14159265359;


//http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
// float hash( float n )
// {
//     return fract(sin(n)*43758.5453);
// }


// float lerp(float a, float b, float t) {
// 		float cos_t = (1.0 - cos(t * M_PI)) * 0.5;
// 	return a * (1.0 - cos_t) + b * cos_t;

// }
// float noise( vec3 x )
// {
//     // The noise function returns a value in the range -1.0f -> 1.0f

//     vec3 p = floor(x);
//     vec3 f = fract(x);

//     f = f*f*(3.0-2.0*f);
//     float n = p.x + p.y*57.0 + 113.0*p.z;

//     return lerp(lerp(lerp( hash(n+0.0), hash(n+1.0),f.x),
//                    lerp( hash(n+57.0), hash(n+58.0),f.x),f.y),
//                lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
//                    lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
// }


// From http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float noise_gen1(float x, float y, float z) {
	return fract(sin(dot(vec3(x, y, z) ,vec3(12.9898,78.233, 34.2838))) * 43758.5453);
	// return noise(vec3(x, y, z));
}

float noise_gen2(float x, float y) {
	//TODO
	return x;
}



// From the noise lecture (slide 26)
float cosine_interp(float a, float b, float t) {
	float cos_t = (1.0 - cos(t * M_PI)) * 0.5;
	return a * (1.0 - cos_t) + b * cos_t;
}

float interp_noise(float x, float y, float z, float freq) { 
	float x0 = floor(x * freq) / freq,
		y0 = floor(y * freq) / freq,
		z0 = floor(z * freq) / freq,
	 	x1 = ceil(x * freq) / freq,
	 	y1 = ceil(y * freq) / freq,
	 	z1 = ceil(z * freq) / freq;

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
    float noise_offset = multi_octave_noise(position.x + time, position.y + time, position.z + time);
    vec4 noise_pos = vec4(position.xyz + normal * 2.0 * noise_offset, 1.0);
    // if (noise_pos == vec4(0,0,0,1)) {
    // 	noise_pos = vec4(position, 1.0);
    // }

    // if (noise_offset > 0.5) {
    // 	vUv = vec2(noise_offset, 0.0);
    // }

    // vUv = vec2(0.0, noise_offset / 2.0 + 0.5);
    noise = noise_offset;

    gl_Position = projectionMatrix * modelViewMatrix * noise_pos;
    // color = vec3(normal.x, normal.y, normal.z);
}