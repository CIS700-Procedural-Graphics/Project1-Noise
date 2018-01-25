uniform float u_time;
uniform float u_strength;
uniform float u_frequency;
uniform float u_speed;

varying vec3 vNormal;
varying float noise;

float noise2d(float x, float y) {
    return fract(sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5453);
}

float noise3d(vec3 p) {
    return noise2d(noise2d(p.x, p.y), p.z);
}

float linear_interp(float a, float b, float t) {
  return a * (1.0 - t) + b * t;
}

float cosine_interp(float a, float b, float t) {
  float cos_t = (1.0 - cos(t * 3.14))* 0.5;
  return linear_interp(a, b, cos_t);
}

float interp_noise(vec3 p) {
    p *= 8.0;  // scale up the vertex coordinates

    float x = p.x;
    float y = p.y;
    float z = p.z;

    vec3 v6 = vec3(floor(x), floor(y), floor(z));
    vec3 v1 = v6 + vec3(0.0, 1.0, 1.0);
    vec3 v2 = v6 + vec3(0.0, 0.0, 1.0);
    vec3 v3 = v6 + vec3(1.0, 0.0, 1.0);
    vec3 v4 = v6 + vec3(1.0, 1.0, 1.0);
    vec3 v5 = v6 + vec3(0.0, 1.0, 0.0);
    vec3 v7 = v6 + vec3(1.0, 0.0, 0.0);
    vec3 v8 = v6 + vec3(1.0, 1.0, 0.0);

    float n1 = noise3d(v1);
    float n2 = noise3d(v2);
    float n3 = noise3d(v3);
    float n4 = noise3d(v4);
    float n5 = noise3d(v5);
    float n6 = noise3d(v6);
    float n7 = noise3d(v7);
    float n8 = noise3d(v8);

    float interp1_4 = cosine_interp(n1, n4, fract(x));
    float interp2_3 = cosine_interp(n2, n3, fract(x));
    float interpFront = cosine_interp(interp2_3, interp1_4, fract(y));

    float interp5_8 = cosine_interp(n5, n8, fract(x));
    float interp6_7 = cosine_interp(n6, n7, fract(x));
    float interpBack = cosine_interp(interp6_7, interp5_8, fract(y));

    float interped = cosine_interp(interpBack, interpFront, fract(z));

    return interped;
}



void main() {
    vNormal = normal;

    float offset_1 = cos(3.14  * 0.001 * u_time * u_speed);
    float offset_2 = sin(3.14  * 0.001 * u_time * u_speed);

    const int octaves = 8;
    float freq = 0.5;
    float amp = 1.0;
    float sumNoise = 0.0;
    float sumAmplitude = 0.0;
    for(int i = 0; i < octaves; ++i) {
        sumAmplitude += amp;
        vec3 pos = position + vec3(offset_1, offset_2, 0);
        vec3 newP = vec3(pos.x * freq, pos.y * freq, pos.z * freq);
        sumNoise += interp_noise(newP) * amp;
        freq *= u_frequency;
        amp *= u_strength;
    }
    sumNoise /= 1.3;
    sumNoise = abs(sumNoise);
    noise = sumNoise;
    float displaceNoise = (sumNoise /3.0);
    
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position + normal.xyz * displaceNoise, 1.0 );
}