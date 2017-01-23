#define M_PI 3.1415926535897932384626433832795
#define N_OCTAVES 5
varying vec2 vUv;
varying vec3 vNormal;
uniform float uTime;


float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float lerp(float a, float b, float t){
	return (a * (1.0 - t) + b * t);
}

float cosine_interpolate(float a, float b, float t){
	float cos_t = (1.0 - cos(t * M_PI)) * 0.5;
	return lerp(a, b, cos_t);
}

float PerlinNoise3D(float x, float y, float z){
	float total = 0.0;
	float persistance = 1.0 / 2.0;

	for (int i = 0; i < N_OCTAVES; ++i){

		float frequency = pow(2.0, float(i));
		float amplitude = pow(persistance, float(i));

		//TODO:
		//sum the total from a noise function
	}

	return 0.0;

}

void main() {
    vUv = uv;
    vNormal = normal;
    float noiseOffset = rand(uv);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0 );
}


