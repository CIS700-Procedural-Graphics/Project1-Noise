// Implementation referenced:
// Perlin's Improved Noise: http://mrl.nyu.edu/~perlin/noise/
// explanations of Improved Noise: http://flafla2.github.io/2014/08/09/perlinnoise.html#the-hash-function

varying float normNoise;
varying float posNoise;
varying vec3 vNormal;

uniform float time;
uniform float freq;
uniform float pers;
uniform float amp;
uniform int octaves;
uniform float p[256];
uniform float audioData[256];

float lerp(float a, float b, float t) {
    return (a * (1.0 - t)) + (b * t);
}

float cosinterp(float a, float b, float t) {
    const float PI = 3.14159265358979323;
    float tCos = (1.0 - cos(t * PI)) * 0.5;
    return lerp(a, b, tCos);
}

float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float grad(float hash, float x, float y, float z) {
    float h = mod(hash, 256.0);
    float u = (h < 8.0) ? x : y;
    float v = (h < 4.0) ? y : ((h == 12.0 || h == 14.0) ? x : z);
    return ((mod(h, 2.0) == 0.0) ? u : -u) + (((h == 0.0) || (h == 1.0)) ? v : -v);
}

float perm(float t) {
    if (t > 256.0) t = mod(t, 256.0);
    return p[int(t)];
}

float nestedPerm(float a, float b, float c) {
    return perm(perm(perm(a) + b) + c);
}

float noise(vec3 v) {

    // Determine the unit cube that contains the point (x, y, z)
    float xi = mod(floor(v.x), 256.0);
    float yi = mod(floor(v.y), 256.0);
    float zi = mod(floor(v.z), 256.0);

    // Incremented copies of xi, yi, zi
    float xj = xi + 1.0;
    float yj = yi + 1.0;
    float zj = zi + 1.0;

    // Relative coordinate of point inside cube
    float xf = v.x - floor(v.x);
    float yf = v.y - floor(v.y);
    float zf = v.z - floor(v.z);

    // Decremented copies of xf, yf, zf
    float xg = xf - 1.0;
    float yg = yf - 1.0;
    float zg = zf - 1.0;

    // Compute fade curves for point
    float a = fade(xf);
    float b = fade(yf);
    float c = fade(zf);

    // Hash values for each of the 8 cube corners
    float aaa = nestedPerm(xi, yi, zi);
    float baa = nestedPerm(xj, yi, zi);
    float aba = nestedPerm(xi, yj, zi);
    float aab = nestedPerm(xi, yi, zj);
    float bba = nestedPerm(xj, yj, zi);
    float bab = nestedPerm(xj, yi, zj);
    float abb = nestedPerm(xi, yj, zj);
    float bbb = nestedPerm(xj, yj, zj);

    // Interpolate surrounding 8 lattice values
    float laa = cosinterp(grad(aaa, xf, yf, zf), grad(baa, xg, yf, zf), a);
    float lab = cosinterp(grad(aba, xf, yg, zf), grad(bba, xg, yg, zf), a);
    float lba = cosinterp(grad(aab, xf, yf, zg), grad(bab, xg, yf, zg), a);
    float lbb = cosinterp(grad(abb, xf, yg, zg), grad(bbb, xg, yg, zg), a);
    float la = cosinterp(laa, lab, b);
    float lb = cosinterp(lba, lbb, b);
    float l = cosinterp(la, lb, c);

    // Change range from [-1, 1] to [0, 1]
    return (l + 1.0) / 2.0;
}

float octaveNoise(vec3 v) {
    float total = 0.0;
    float maxNoise = 0.0;
    float ampV = amp;
    float freqV = freq;

    // GLSL doesn't compile unless the for loop is
    // guaranteed to finish.
    const int maxOctaves = 100;

    for (int i = 0; i < maxOctaves; i++) {
        if (i > octaves) break;

        v *= freqV;
        total += noise(v) * ampV;
        maxNoise += ampV;

        ampV *= pers;
        freqV *= 2.0;
    }

    // Again, normalize between [0, 1]
    return total / maxNoise;
}

void main() {
    normNoise = octaveNoise(normal + time);
    posNoise = octaveNoise(position + time);
    vNormal = normal;

    float displacement = posNoise;
    vec3 noisePosition = position + (normal * displacement);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(noisePosition, 1.0);
}