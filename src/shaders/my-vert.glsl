
varying vec2 vUv;
varying vec3 vNormal;
const int numOctaves = 3;
uniform float time;

float generateNoise(int x, int y, int z, int numOctave) {
	if (numOctave == 0) {
        return fract(sin(dot(vec3(x,y,z), vec3(12.9898, 78.23, 107.81))) * 43758.5453);
    } else if (numOctave == 1) {
        return fract(sin(dot(vec3(z,x,y), vec3(16.363, 43.597, 199.73))) * 69484.7539);
    } else if (numOctave == 2) {
        return fract(sin(dot(vec3(y,x,z), vec3(13.0, 68.819, 90.989))) * 92041.9823);
    }
} 

float linearInterpolate(float a, float b, float t) {
	return a * (1.0 - t) + b * t;
}

float cosineInterpolate(float a, float b, float t) {
	float cos_t = (1.0 - cos(t * 3.14159265359879323846264)) * 0.5;
	return linearInterpolate(a, b, cos_t);
}

// given a point in 3d space, produces a noise value by interpolating surrounding points
float interpolateNoise(float x, float y, float z, int numOctave) {
	int integerX = int(floor(x));
    float weightX = x - float(integerX);

    int integerY = int(floor(y));
    float weightY = y - float(integerY);

    int integerZ = int(floor(z));
    float weightZ = z - float(integerZ);

    float v1 = generateNoise(integerX, integerY, integerZ, numOctave);
    float v2 = generateNoise(integerX, integerY, integerZ + 1, numOctave);
    float v3 = generateNoise(integerX, integerY + 1, integerZ + 1, numOctave);
    float v4 = generateNoise(integerX, integerY + 1, integerZ, numOctave);

    float v5 = generateNoise(integerX + 1, integerY, integerZ, numOctave);
    float v6 = generateNoise(integerX + 1, integerY, integerZ + 1, numOctave);
    float v7 = generateNoise(integerX + 1, integerY + 1, integerZ + 1, numOctave);
    float v8 = generateNoise(integerX + 1, integerY + 1, integerZ, numOctave);

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

        total += interpolateNoise(x * frequency, y * frequency, z * frequency, i) * amplitude;
    }

    return total;
}

void main() {
    vUv = uv;
    vNormal = normal;

    float offset = generateMultiOctaveNoise(position[0] + time/999.0, position[1] + time/999.0, position[2] + time/999.0);
    vec3 newPosition = position + offset * normal;

    gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );
}