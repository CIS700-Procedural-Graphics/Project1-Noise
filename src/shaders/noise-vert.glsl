varying vec2 vUv;
varying vec3 vNormal;
varying float vNoiseValue; 
uniform float time;
uniform float u_persistance;

// Pseudo Random noise functions: 
//------------------------------
// noise functions from slides
// returns range [-1,1]
float noise_1(float x, float y, float z){
	float value1 = fract(sin(dot(vec2(z, y) ,vec2(1027.9898, 29381.233))) * 333019.5453);
	float value2 = fract(sin(x) * 43758.5453);

	return dot(value1, value2); 
}

float noise_2(float x, float y, float z) {
	float value1 = fract(sin(dot(vec2(x, y) ,vec2(12.9898, 78.233))) * 43758.5453);
	float value2 = fract(sin(z) * 202229.5453);

	return dot(value1, value2); 
}

float noise_3(float x, float y, float z) {
	float n = x * 109277.101 ; 
	float m = y * 101010010.0001; 
	n = fract(cos(dot(vec2(n,z), vec2(19469.294485, 128282.9383))) * 1094877.1293);
	n = fract(tan(dot(n, m)));
	return n;
}

float noise_4(float x, float y, float z){
	float value1 = fract(sin(dot(vec2(x, y) ,vec2(3427.9898, 9847.233))) * 202.5453);
	float value2 = fract(cos(z) * 20247.5453);

	return fract(dot(value1, value2)); 
}

//----------------------------

// Linear Interpolation
float lerp(float a, float b, float t) {
	return a * (1.0 - t) + b * t; 
}

// Cosine Interpolation
float cos_interp(float a, float b, float t) {
	float cos_t = (1.0 - cos(t * 3.14159265358979)) * 0.5;
	return lerp(a , b , cos_t);
}

// Interpolate Noise function
// Given a position, use surrounding lattice points to interpolate and find influence 
// takes in (x,y,z) position, and the current octave level
float interpolateNoise(float x, float y, float z, int i) {
	// define the lattice points surrounding the input position 
	float x0 = floor(x);
	float x1 = x0 + 1.0; 
	float y0 = floor(y);
	float y1 = y0 + 1.0;
	float z0 = floor(z);
	float z1 = z0 + 1.0; 

	// VALUE BASED NOISE
	vec3 p0 = vec3(x0, y0, z0); vec3 p1 = vec3(x0, y0, z1);
	vec3 p2 = vec3(x0, y1, z0); vec3 p3 = vec3(x0, y1, z1);
	vec3 p4 = vec3(x1, y0, z0); vec3 p5 = vec3(x1, y0, z1);
	vec3 p6 = vec3(x1, y1, z0); vec3 p7 = vec3(x1, y1, z1);

	// use noise function to generate random value
	// depending on the current octave, sample noise using a different function 
	float v0, v1, v2, v3, v4, v5, v6, v7;
	if (i == 0) {
		 v0 = noise_2(p0.x, p0.y, p0.z); v1 = noise_2(p1.x, p1.y, p1.z);
		 v2 = noise_2(p2.x, p2.y, p2.z); v3 = noise_2(p3.x, p3.y, p3.z);
		 v4 = noise_2(p4.x, p4.y, p4.z); v5 = noise_2(p5.x, p5.y, p5.z);
		 v6 = noise_2(p6.x, p6.y, p6.z); v7 = noise_2(p7.x, p7.y, p7.z);
	} else if (i == 1) {
		 v0 = noise_3(p0.x, p0.y, p0.z); v1 = noise_3(p1.x, p1.y, p1.z);
		 v2 = noise_3(p2.x, p2.y, p2.z); v3 = noise_3(p3.x, p3.y, p3.z);
		 v4 = noise_3(p4.x, p4.y, p4.z); v5 = noise_3(p5.x, p5.y, p5.z);
		 v6 = noise_3(p6.x, p6.y, p6.z); v7 = noise_3(p7.x, p7.y, p7.z);
	 } else if (i == 2) {
		 v0 = noise_1(p0.x, p0.y, p0.z); v1 = noise_1(p1.x, p1.y, p1.z);
		 v2 = noise_1(p2.x, p2.y, p2.z); v3 = noise_1(p3.x, p3.y, p3.z);
		 v4 = noise_1(p4.x, p4.y, p4.z); v5 = noise_1(p5.x, p5.y, p5.z);
		 v6 = noise_1(p6.x, p6.y, p6.z); v7 = noise_1(p7.x, p7.y, p7.z);
	} else {
		 v0 = noise_4(p0.x, p0.y, p0.z); v1 = noise_4(p1.x, p1.y, p1.z);
		 v2 = noise_4(p2.x, p2.y, p2.z); v3 = noise_4(p3.x, p3.y, p3.z);
		 v4 = noise_4(p4.x, p4.y, p4.z); v5 = noise_4(p5.x, p5.y, p5.z);
		 v6 = noise_4(p6.x, p6.y, p6.z); v7 = noise_4(p7.x, p7.y, p7.z);
	}

	// trilinear interpolation of all 8 values
	// coordinates in the unit cube: 
	float unitX = x - x0;
	float unitY = y - y0;
	float unitZ = z - z0;

	float xCos1 = cos_interp(v0, v4, unitX);
	float xCos2 = cos_interp(v1, v5, unitX);
	float xCos3 = cos_interp(v2, v6, unitX);
	float xCos4 = cos_interp(v3, v7, unitX);

	float yCos1 = cos_interp(xCos1, xCos3, unitY);
	float yCos2 = cos_interp(xCos2, xCos4, unitY);

	float average = cos_interp(yCos1, yCos2, unitZ);

	return average;
}

// multioctave noise generation
float fbm(float x, float y, float z) {
	float total = 0.0; 
	const int OCTAVES = 4;


	// loop for some number of octaves
	for(int i = 0; i < OCTAVES; i++) {
		float i_float = float(i);
		float frequency = pow(2.0, i_float);
		float amplitude = pow(u_persistance, i_float);

		// use interpolate noise function to find noise value
        float sampleNoise = interpolateNoise(x * frequency , y * frequency , z * frequency, i);
        total += sampleNoise * amplitude;
	}

	return total;
}

void main() {
    vUv = uv;
    vNormal = normal;

    // alter positions based on noise function
    float timeMod = time / 300.0; 
    float noiseHeight = fbm(
    	float(position.x) + timeMod, 
    	float(position.y) + timeMod, 
    	float(position.z) + timeMod);
    vec3 noisyPosition = (vec3(
    	position.x + noiseHeight / 100.0 + normal.x * noiseHeight , 
    	position.y + noiseHeight / 100.0 + normal.y * noiseHeight , 
    	position.z + noiseHeight / 100.0 + normal.z * noiseHeight)); 

    vNoiseValue = noiseHeight;


    gl_Position = projectionMatrix * modelViewMatrix * vec4( noisyPosition, 1.0 );
}