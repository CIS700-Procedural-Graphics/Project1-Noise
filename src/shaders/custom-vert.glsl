
varying vec2 vUv;
varying vec3 nor;

uniform float time;
uniform float radius;
uniform float persistence;
uniform float freqMultiplier;
uniform float displacement;

float interpolate1(float v1, float v2, float xmu) {
  float mu2 = (1.0 - cos(xmu * 3.141592653589)) / 2.0;
  return (v1 * (1.0 - mu2) + v2 * mu2);
}

float random2v(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// v1, v2, v3, v4 are the VALUES at the corners of a unit square
float interpolate2(float v1, float v2, float v3, float v4,
                   float xmu, float ymu) {
  float s = interpolate1(v1, v2, xmu);
  float t = interpolate1(v3, v4, xmu);
  return interpolate1(s, t, ymu);
}

/************************* 3D Noise **************************/

float random3(float x, float y, float z) {
  return random2v(vec2(random2v(vec2(x,y)), z));
}

float interpolate3(float v1, float v2, float v3, float v4,
                   float v5, float v6, float v7, float v8,
                   float xmu, float ymu, float zmu) {

  float s = interpolate1(v1, v2, xmu);
  float t = interpolate1(v3, v4, xmu);
  float u = interpolate1(v5, v6, xmu);
  float v = interpolate1(v7, v8, xmu);

  return interpolate2(s, t, u, v, ymu, zmu);
}

float smooth3(float x, float y, float z) {
  float total = 0.0;

  for (float i = -1.0; i <= 1.0; i++) {
    for (float j = -1.0; j <= 1.0; j++) {
      for (float k = -1.0; k <= 1.0; k++) {
        total += random3(x + i, y + j, z + k);
      }
    }
  }

  return total / 27.0;
}

// noise has range equal to range of smooth
float noise3(float x, float y, float z) {
  const float NUM_OCTAVES = 4.0;
  float total = 0.0;
  float totalAmplitude = 0.0;

  for (float i = 0.0; i < NUM_OCTAVES; i++) {
    float frequency = freqMultiplier * pow(2.0, i);
    float amplitude = pow(persistence, i);
    float d = 5.0;

    x = x * frequency / d;
    y = y * frequency / d;
    z = z * frequency / d;

    float x_f = floor(x);
    float y_f = floor(y);
    float z_f = floor(z);

    float x_c = ceil(x);
    float y_c = ceil(y);
    float z_c = ceil(z);

    float xmu = (fract(x));
    float ymu = (fract(y));
    float zmu = (fract(z));

    float v1 = smooth3(x_f, y_f, z_f);
    float v2 = smooth3(x_c, y_f, z_f);
    float v3 = smooth3(x_f, y_c, z_f);
    float v4 = smooth3(x_c, y_c, z_f);

    float v5 = smooth3(x_f, y_f, z_c);
    float v6 = smooth3(x_c, y_f, z_c);
    float v7 = smooth3(x_f, y_c, z_c);
    float v8 = smooth3(x_c, y_c, z_c);

    total += interpolate3(v1, v2, v3, v4, v5, v6, v7, v8, xmu, ymu, zmu) * amplitude;
    totalAmplitude += amplitude;
  }

  return total / totalAmplitude;
}

/****************************** 4D Noise ******************************/

float random4(float x, float y, float z, float w) {
  return random2v(vec2(random3(x, y, z), w));
}

float smooth4(float x, float y, float z, float w) {
  float total = 0.0;

  for (float i = -1.0; i <= 1.0; i++) {
    for (float j = -1.0; j <= 1.0; j++) {
      for (float k = -1.0; k <= 1.0; k++) {
        for (float l = -1.0; l <= 1.0; l++) {
          total += random4(x + i, y + j, z + k, w + l);
        }
      }
    }
  }

  return total / 81.0;
}

float interpolate4(float v1,  float v2,  float v3,  float v4,
                   float v5,  float v6,  float v7,  float v8,
                   float v9,  float v10, float v11, float v12,
                   float v13, float v14, float v15, float v16,
                   float xmu, float ymu, float zmu, float wmu) {

   float s = interpolate1(v1,  v2,  xmu);
   float t = interpolate1(v3,  v4,  xmu);
   float u = interpolate1(v5,  v6,  xmu);
   float v = interpolate1(v7,  v8,  xmu);
   float m = interpolate1(v9,  v10, xmu);
   float n = interpolate1(v11, v12, xmu);
   float p = interpolate1(v13, v13, xmu);
   float q = interpolate1(v15, v16, xmu);

   return interpolate3(s, t, u, v, m, n, p, q, ymu, zmu, wmu);
}

float noise4(float x, float y, float z, float w) {
  const float NUM_OCTAVES = 4.0;
  float total = 0.0;
  float totalAmplitude = 0.0;

  for (float i = 0.0; i < NUM_OCTAVES; i++) {
    float frequency = freqMultiplier * pow(2.0, i);
    float amplitude = pow(persistence, i);
    float d = 5.0;

    x = x * frequency / d;
    y = y * frequency / d;
    z = z * frequency / d;
    w = w * frequency / d;

    float x_c = ceil(x);
    float y_c = ceil(y);
    float z_c = ceil(z);
    float w_c = ceil(w);

    float x_f = floor(x);
    float y_f = floor(y);
    float z_f = floor(z);
    float w_f = floor(w);

    float xmu = fract(x);
    float ymu = fract(y);
    float zmu = fract(z);
    float wmu = fract(w);

    float v1 = smooth4(x_f, y_f, z_f, w_f);
    float v2 = smooth4(x_c, y_f, z_f, w_f);
    float v3 = smooth4(x_f, y_c, z_f, w_f);
    float v4 = smooth4(x_c, y_c, z_f, w_f);

    float v5 = smooth4(x_f, y_f, z_c, w_f);
    float v6 = smooth4(x_c, y_f, z_c, w_f);
    float v7 = smooth4(x_f, y_c, z_c, w_f);
    float v8 = smooth4(x_c, y_c, z_c, w_f);

    float v9  = smooth4(x_f, y_f, z_f, w_c);
    float v10 = smooth4(x_c, y_f, z_f, w_c);
    float v11 = smooth4(x_f, y_c, z_f, w_c);
    float v12 = smooth4(x_c, y_c, z_f, w_c);

    float v13 = smooth4(x_f, y_f, z_c, w_c);
    float v14 = smooth4(x_c, y_f, z_c, w_c);
    float v15 = smooth4(x_f, y_c, z_c, w_c);
    float v16 = smooth4(x_c, y_c, z_c, w_c);

    total += interpolate4(v1,  v2,   v3,  v4,
                          v5,  v6,   v7,  v8,
                          v9,  v10, v11, v12,
                          v13, v14, v15, v16,
                          xmu, ymu, zmu, wmu) * amplitude;
    totalAmplitude += amplitude;
  }

  return total / totalAmplitude;
}


/*********************************************************************/


float noise(float x, float y, float z, float w) {
  // return noise4(x + time, y + time, z + time, w);
  return noise3(x + time, y + time, z + time);
}


void main() {
    float r = noise(position.x, position.y, position.z, time);
    vUv = vec2(0.0, 1.3 * r - (time / 1000.0) + 0.2); // 0.2 = fire, -0.1=ice, -0.5=earth
    nor = normal.xyz;
    vec3 pos = position + displacement * r * nor;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( pos, 1.0 );
}
