#define M_PI 3.1415926535897932384626433832795
#define N_OCTAVES 5
varying vec2 vUv;
varying vec3 vNormal;
uniform float uTime;


float noise1(vec3 seed){
    return fract(sin(dot(seed ,vec3(12.9898,78.233, 157.179))) * 43758.5453);
}

float noise2(vec3 seed){
    return fract(sin(dot(seed ,vec3(12.9898,78.233, 157.179))) * 131070.5453);
}

float noise3(vec3 seed){
	return fract(sin(dot(seed ,vec3(12.9898,78.233, 157.179))) * 524286.5453);
}

float TotalNoise(vec3 seed, float frequency, float amplitude){ //inside frequency outside amplit
	float n1 = noise1(seed * frequency) * amplitude;
	float n2 = noise2(seed * frequency*2.0) * amplitude/2.0;
	float n3 = noise3(seed * frequency*3.0) * amplitude/3.0;
	return n1;
}

float lerp(float a, float b, float t){
	return (a * (1.0 - t) + b * t);
}

float cosine_interpolate(float a, float b, float t){
	float cos_t = (1.0 - cos(t * M_PI)) * 0.5;
	return lerp(a, b, cos_t);
}


float trilinearInterpolation(float frequency, float amplitude){

	vec3 pd = position;

	//8 adjacent vec3 positions on lattice
	vec3 v000 = vec3(floor(pd.x),floor(pd.y),floor(pd.z));
	vec3 v100 = vec3(ceil(pd.x),floor(pd.y),floor(pd.z));
	vec3 v010 = vec3(floor(pd.x), ceil(pd.y), floor(pd.z));
	vec3 v001 = vec3(floor(pd.x), floor(pd.y), ceil(pd.z));
	vec3 v101 = vec3(ceil(pd.x), floor(pd.y), ceil(pd.z));
	vec3 v110 = vec3(ceil(pd.x), ceil(pd.y), floor(pd.z));
	vec3 v011 = vec3(floor(pd.x), ceil(pd.y), ceil(pd.z));
	vec3 v111 = vec3(ceil(pd.x), ceil(pd.y), ceil(pd.z));
	
	//noise of cooresponding positions on lattice
	float n000 = TotalNoise(v000, frequency, amplitude);
	float n100 = TotalNoise(v100, frequency, amplitude);
	float n010 = TotalNoise(v010, frequency, amplitude);
	float n001 = TotalNoise(v001, frequency, amplitude);
	float n101 = TotalNoise(v101, frequency, amplitude);
	float n110 = TotalNoise(v110, frequency, amplitude);
	float n011 = TotalNoise(v011, frequency, amplitude);
	float n111 = TotalNoise(v111, frequency, amplitude);

	//time val for interpolation
	float tX = pd.x - floor(pd.x);
	float tY = pd.y - floor(pd.y);
	float tZ = pd.z - floor(pd.z);

	float n00 = cosine_interpolate(n000, n100, tX);
	float n10 = cosine_interpolate(n001, n101, tX);
	float n11 = cosine_interpolate(n011, n111, tX);
	float n01 = cosine_interpolate(n010, n110, tX);
	float n0 = cosine_interpolate(n00, n10, tZ);
	float n1 = cosine_interpolate(n01, n11, tZ);
	float n = cosine_interpolate(n0, n1, tY);

	return n;
}


float PerlinNoise3D(){
	float total = 0.0;
	float persistance = 1.0 / 2.0;

	for (int i = 0 ; i < N_OCTAVES; i++){

		float frequency = pow(2.0, float(i));
		float amplitude = pow(persistance, float(i));
		total += trilinearInterpolation(frequency, amplitude);

	}

	return total;

}

void main() {
    vUv = uv;
    vNormal = normal;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position + normal*PerlinNoise3D(), 1.0 );
}


