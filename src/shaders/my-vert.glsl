
varying vec2 vUv;
varying vec3 vNormal;
const int numOctaves = 1;

float generateNoise1(int x, int y, int z) {
	return fract(sin(dot(vec3(x,y,z), vec3(12.9898, 78.23, 107.0))) * 43758.5453);
} 

float linearInterpolate(float a, float b, float t) {
	return a * (1.0 - t) + b * t;
}

float cosineInterpolate(float a, float b, float t) {
	float cos_t = (1.0 - cos(t * 3.14159265359879323846264)) * 0.5;
	return linearInterpolate(a, b, cos_t);
}

// given a point in 3d space, produces a noise value by interpolating surrounding points
float interpolateNoise(float x, float y, float z) {
	int integerX = int(floor(x));
    float weightX = x - float(integerX);

    int integerY = int(floor(y));
    float weightY = y - float(integerY);

    int integerZ = int(floor(z));
    float weightZ = z - float(integerZ);

    float v1 = generateNoise1(integerX, integerY, integerZ);
    float v2 = generateNoise1(integerX, integerY, integerZ + 1);
    float v3 = generateNoise1(integerX, integerY + 1, integerZ + 1);
    float v4 = generateNoise1(integerX, integerY + 1, integerZ);

    float v5 = generateNoise1(integerX + 1, integerY, integerZ);
    float v6 = generateNoise1(integerX + 1, integerY, integerZ + 1);
    float v7 = generateNoise1(integerX + 1, integerY + 1, integerZ + 1);
    float v8 = generateNoise1(integerX + 1, integerY + 1, integerZ);

    float i1 = cosineInterpolate(v1, v5, weightX);
    float i2 = cosineInterpolate(v2, v6, weightX);
    float i3 = cosineInterpolate(v3, v7, weightX);
    float i4 = cosineInterpolate(v4, v8, weightX);

    float ii1 = cosineInterpolate(i1, i4, weightY);
    float ii2 = cosineInterpolate(i2, i3, weightY);

    return cosineInterpolate(ii1, ii2 , weightZ);
}

// a multi-octave noise generation function that sums multiple noise functions together
// with each subsequent noise function increasing in frequency and decreasing in amplitude
float generateMultiOctaveNoise(float x, float y, float z) {
    float total = 0.0;
    float persistence = 1.0/2.0;

    //loop for some number of octaves
    for (int i = 0; i < numOctaves; i++) {
        float frequency = pow(2.0, float(i));
        float amplitude = pow(persistence, float(i));

        total += interpolateNoise(x * frequency, y * frequency, z * frequency) * amplitude;
    }

    return total;
}

void main() {
    vUv = uv;
    vNormal = normal;

    float offset = generateMultiOctaveNoise(position[0], position[1], position[2]);
    vec3 newPosition = position + offset * normal;

    gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );
}