varying vec2 vUv;
varying vec3 vNormal;

// Pseudo Random noise functions: 
//------------------------------
// noise functions from slides
// returns range [-1,1]
float noise_1(float x, float y, float z){
	x = pow(x / pow(2.0, 13.0), x); 
	float value1 = (1.0 - (x * (x * x * 15731.0 + 789221.0) + 1376312589.0)) / 107377418240.0;

	float value2 = (sin(dot(vec2(y , z), vec2(12.9898, 78.233))) * 43758.5453); 

    return dot(value1, value2);
}

// noise function found on stackoverflow
// returns range [-1,1]
float noise_2(float x, float y, float z) {
	float value1 = fract(sin(dot(vec2(x, y) ,vec2(12.9898, 78.233))) * 43758.5453);
	
	float value2 = fract(sin(z) * 43758.5453);

	return dot(value1, value2); 
}

//------------------------------

// based on given noise value, choose from a well-defined set of gradient vectors
// vec3 findGradient(float noiseValue) {
// 	if (noiseValue < (- 5.0 / 6.0)) { return vec3(1.0,1.0,0.0);}
//     else if (noiseValue < (- 4.0 / 6.0)) { return vec3(-1.0,1.0,0.0);}
//     else if (noiseValue < (- 3.0 / 6.0)) { return vec3(1.0,-1.0,0.0);}
//     else if (noiseValue < (- 2.0 / 6.0)) { return vec3(-1.0,-1.0,0.0);}
//     else if (noiseValue < (- 1.0 / 6.0)) { return vec3(1.0,0.0,1.0);}
//     else if (noiseValue < (0.0)) { return vec3(-1.0,0.0,1.0);}
//     else if (noiseValue < (1.0 / 6.0)) { return vec3(1.0,0.0,-1.0);}
//     else if (noiseValue < (2.0 / 6.0)) { return vec3(-1.0,0.0,-1.0);}
//     else if (noiseValue < (3.0 / 6.0)) { return vec3(0.0,1.0,1.0);}
//     else if (noiseValue < (4.0 / 6.0)) { return vec3(0.0,-1.0,1.0);}
//     else if (noiseValue < (5.0 / 6.0)) { return vec3(0.0,1.0,-1.0);}
//     else { return vec3(0.0,-1.0,-1.0); }
// }

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
float interpolateNoise(float x, float y, float z, int i) {
	// define the lattice points surrounding the input position 
	float x0 = floor(x);
	float x1 = x0 + 1.0; 
	float y0 = floor(y);
	float y1 = y0 + 1.0;
	float z0 = floor(z);
	float z1 = z0 + 1.0; 

	// VALUE BASED NOISE
	vec3 p0 = vec3(x0, y0, z0);
	vec3 p1 = vec3(x0, y0, z1);
	vec3 p2 = vec3(x0, y1, z0);
	vec3 p3 = vec3(x0, y1, z1);
	vec3 p4 = vec3(x1, y0, z0);
	vec3 p5 = vec3(x1, y0, z1);
	vec3 p6 = vec3(x1, y1, z0);
	vec3 p7 = vec3(x1, y1, z1);

	// use noise function to generate random value
	float v0, v1, v2, v3, v4, v5, v6, v7;
	// if (i == 0) {
	// 	 v0 = noise_1(p0.x, p0.y, p0.z);
	// 	 v1 = noise_1(p1.x, p1.y, p1.z);
	// 	 v2 = noise_1(p2.x, p2.y, p2.z);
	// 	 v3 = noise_1(p3.x, p3.y, p3.z);
	// 	 v4 = noise_1(p4.x, p4.y, p4.z);
	// 	 v5 = noise_1(p5.x, p5.y, p5.z);
	// 	 v6 = noise_1(p6.x, p6.y, p6.z);
	// 	 v7 = noise_1(p7.x, p7.y, p7.z);
	// } else {
		 v0 = noise_2(p0.x, p0.y, p0.z);
		 v1 = noise_2(p1.x, p1.y, p1.z);
		 v2 = noise_2(p2.x, p2.y, p2.z);
		 v3 = noise_2(p3.x, p3.y, p3.z);
		 v4 = noise_2(p4.x, p4.y, p4.z);
		 v5 = noise_2(p5.x, p5.y, p5.z);
		 v6 = noise_2(p6.x, p6.y, p6.z);
		 v7 = noise_2(p7.x, p7.y, p7.z);
	// }

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

    // PERLIN ATTEMPTS 
	// vec3 o = vec3(x,y,z);
	// vec3 p0 = vec3(x0, y0, z0);
	// vec3 p1 = vec3(x0, y0, z1);
	// vec3 p2 = vec3(x0, y1, z0);
	// vec3 p3 = vec3(x0, y1, z1);
	// vec3 p4 = vec3(x1, y0, z0);
	// vec3 p5 = vec3(x1, y0, z1);
	// vec3 p6 = vec3(x1, y1, z0);
	// vec3 p7 = vec3(x1, y1, z1);

	// store the gradient vectors of each position: 
	// use psuudo-random noise functions inside the multi-octave function
	// hash value to a set of well-defined gradients using findGradient() 
	// how do we use different noise functions?? DONT GET IT 
	// vec3 g0 = findGradient(noise_1(p0.x, p0.y, p0.z));
	// vec3 g1 = findGradient(noise_1(p1.x, p1.y, p1.z));
	// vec3 g2 = findGradient(noise_1(p2.x, p2.y, p2.z));
	// vec3 g3 = findGradient(noise_1(p3.x, p3.y, p3.z));
	// vec3 g4 = findGradient(noise_1(p4.x, p4.y, p4.z));
	// vec3 g5 = findGradient(noise_1(p5.x, p5.y, p5.z));
	// vec3 g6 = findGradient(noise_1(p6.x, p6.y, p6.z));
	// vec3 g7 = findGradient(noise_1(p7.x, p7.y, p7.z));

	// store the distance vectors of each position
	// vec3 d0 = (o - p0);
	// vec3 d1 = (o - p1);
	// vec3 d2 = (o - p2);
	// vec3 d3 = (o - p3);
	// vec3 d4 = (o - p4);
	// vec3 d5 = (o - p5);
	// vec3 d6 = (o - p6);
	// vec3 d7 = (o - p7);

	// take the dot product of each  pair of gradient/distance vectors (and normalize?)
	// to find the influence of each lattice point 
	// float dot0 = normalize(dot(g0, d0)); 
	// float dot1 = normalize(dot(g1, d1)); 
	// float dot2 = normalize(dot(g2, d2)); 
	// float dot3 = normalize(dot(g3, d3)); 
	// float dot4 = normalize(dot(g4, d4)); 
	// float dot5 = normalize(dot(g5, d5)); 
	// float dot6 = normalize(dot(g6, d6)); 
	// float dot7 = normalize(dot(g7, d7)); 

	// trilinear interpolation of all 8 values
	// coordinates in the unit circle: 
	// float unitX = x - x0;
	// float unitY = y - y0;
	// float unitZ = z - z0;

	// float xCos1 = lerp(dot0, dot4, unitX);
	// float xCos2 = lerp(dot1, dot5, unitX);
	// float xCos3 = lerp(dot2, dot6, unitX);
	// float xCos4 = lerp(dot3, dot7, unitX);

	// float yCos1 = lerp(xCos1, xCos3, unitY);
	// float yCos2 = lerp(xCos2, xCos4, unitY);

	// float average = lerp(yCos1, yCos2, unitZ);

	// return final value
	//return average;
}

// multioctave noise generation
// how to include z???? very confused 
float fbm(float x, float y, float z) {
	float total = 0.0; 
	float persistence = 0.5;
	int numOctaves = 2; 
	//float maxValue = 0.0;  // Used for normalizing result to 0.0 - 1.0

	// loop for some number of octaves
	for(int i = 0; i < 2; i++) {
		float i_float = float(i);
		float frequency = pow(2.0, i_float);
		float amplitude = pow(persistence, i_float);


        float sampleNoise = interpolateNoise(x , y , z, i) * frequency;
        total += sampleNoise * amplitude;
        //maxValue += amplitude;

		// accumulate contributions in total
		// what is the frequency??? don't undertand this part um hum... 
		// total += noise_1(x, y, frequency);  // but then how do i sample multiple functions? 
	}
	return total; /// maxValue; 
}

void main() {

    vUv = uv;

    vNormal = normal;

    // alter positions based on noise function
    float noiseHeight = fbm(float(position.x), float(position.y), float(position.z));
    vec3 noisyPosition = (vec3(
    	position.x + normal.x * noiseHeight , 
    	position.y + normal.y * noiseHeight , 
    	position.z + normal.z * noiseHeight)); 

    gl_Position = projectionMatrix * modelViewMatrix * vec4( noisyPosition, 1.0 );
}