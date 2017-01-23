
varying vec2 vUv;
varying vec3 nor;

uniform float time;
uniform float radius;

float random2v(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float random3(float x, float y, float z) {
  return random2v(vec2(random2v(vec2(x,y)), z));
}

float random4(float x, float y, float z, float w) {
  return random2v(vec2(random3(x, y, z), w));
}

float smooth3(float x, float y, float z) {
  float faces = random3(x + 1.0, y, z) +
                random3(x, y + 1.0, z) +
                random3(x, y, z + 1.0) +
                random3(x - 1.0, y, z) +
                random3(x, y - 1.0, z) +
                random3(x, y, z - 1.0); // 6

  float edges = random3(x + 1.0, y + 1.0, z) +
                random3(x, y + 1.0, z + 1.0) +
                random3(x + 1.0, y, z + 1.0) +
                random3(x - 1.0, y - 1.0, z) +
                random3(x, y - 1.0, z - 1.0) +
                random3(x - 1.0, y, z - 1.0) +
                random3(x + 1.0, y - 1.0, z) +
                random3(x, y + 1.0, z - 1.0) +
                random3(x + 1.0, y, z - 1.0) +
                random3(x - 1.0, y + 1.0, z) +
                random3(x, y - 1.0, z + 1.0) +
                random3(x - 1.0, y, z + 1.0); // 12

  float corners = random3(x + 1.0, y + 1.0, z + 1.0) +
                  random3(x - 1.0, y + 1.0, z + 1.0) +
                  random3(x + 1.0, y - 1.0, z + 1.0) +
                  random3(x + 1.0, y + 1.0, z - 1.0) +
                  random3(x - 1.0, y - 1.0, z + 1.0) +
                  random3(x + 1.0, y - 1.0, z - 1.0) +
                  random3(x - 1.0, y + 1.0, z - 1.0) +
                  random3(x - 1.0, y - 1.0, z - 1.0); // 8

  float center = random3(x,y,z);

  return (faces + edges + corners + center) / 27.0;
}


float smooth4(float x, float y, float z, float w) {
  float faces = random4(x + 1.0, y, z, w) +
                random4(x, y + 1.0, z, w) +
                random4(x, y, z + 1.0, w) +
                random4(x, y, z, w + 1.0) +
                random4(x - 1.0, y, z, w) +
                random4(x, y - 1.0, z, w) +
                random4(x, y, z - 1.0, w) +
                random4(x, y, z, w - 1.0);
  float edges = random4(x + 1.0, y + 1.0, z, w) +
                random4(x, y + 1.0, z + 1.0, w) +
                random4(x, y, z + 1.0, w + 1.0) +
                random4(x + 1.0, y, z + 1.0, w) +
                random4(x, y + 1.0, z, w + 1.0) +
                random4(x + 1.0, y, z, w + 1.0) +
                random4(x - 1.0, y - 1.0, z, w) +
                random4(x, y - 1.0, z - 1.0, w) +
                random4(x, y, z - 1.0, w - 1.0) +
                random4(x - 1.0, y, z - 1.0, w) +
                random4(x, y - 1.0, z, w - 1.0) +
                random4(x - 1.0, y, z, w - 1.0) +
                random4(x + 1.0, y + 1.0, z, w) +
                random4(x, y + 1.0, z - 1.0, w) +
                random4(x, y, z + 1.0, w - 1.0) +
                random4(x + 1.0, y, z - 1.0, w) +
                random4(x, y + 1.0, z, w - 1.0) +
                random4(x + 1.0, y, z, w - 1.0) +
                random4(x - 1.0, y + 1.0, z, w) +
                random4(x, y - 1.0, z + 1.0, w) +
                random4(x, y, z - 1.0, w + 1.0) +
                random4(x - 1.0, y, z + 1.0, w) +
                random4(x, y - 1.0, z, w + 1.0) +
                random4(x - 1.0, y, z, w + 1.0);
  // float corners = random4(x + 1.0, y + 1.0, z + 1.0, w) +
  //                 random4(x, y + 1.0, z + 1.0, w + 1.0) +
  //                 random4(x + 1.0, y + 1.0, z, w + 1.0) +
  //                 random4(x + 1.0, y, z + 1.0, w + 1.0) +
  //                 random4(x - 1.0, y - 1.0, z - 1.0, w) +
  //                 random4(x, y - 1.0, z - 1.0, w - 1.0) +
  //                 random4(x - 1.0, y - 1.0, z, w - 1.0) +
  //                 random4(x - 1.0, y, z - 1.0, w - 1.0) +
  //                 random4(x - 1.0, y + 1.0, z + 1.0, w) +
  //                 random4(x, y - 1.0, z + 1.0, w + 1.0) +
  //                 random4(x - 1.0, y + 1.0, z, w + 1.0) +
  //                 random4(x - 1.0, y, z + 1.0, w + 1.0) +
  //                 random4(x + 1.0, y - 1.0, z - 1.0, w) +
  //                 random4(x, y + 1.0, z - 1.0, w - 1.0) +
  //                 random4(x + 1.0, y - 1.0, z, w - 1.0) +
  //                 random4(x + 1.0, y, z - 1.0, w - 1.0) +
  //                 random4(x - 1.0, y - 1.0, z + 1.0, w) +
  //                 random4(x, y - 1.0, z - 1.0, w + 1.0) +
  //                 random4(x - 1.0, y - 1.0, z, w + 1.0) +
  //                 random4(x - 1.0, y, z - 1.0, w + 1.0) +
  //                 random4(x + 1.0, y + 1.0, z - 1.0, w) +
  //                 random4(x, y + 1.0, z + 1.0, w - 1.0) +
  //                 random4(x + 1.0, y + 1.0, z, w - 1.0) +
  //                 random4(x + 1.0, y, z + 1.0, w - 1.0);
  float center = random4(x,y,z,w);

  return (faces + edges + center) / 32.0;//57.0;
}

float interpolate1(float v1, float v2, float xmu) {
  // return (v1 * (1.0 - xmu) + v2 * xmu);
  float mu2 = (1.0 - cos(xmu * 3.141592653589)) / 2.0;
  return (v1 * (1.0 - mu2) + v2 * mu2);
}

// v1, v2, v3, v4 are the VALUES at the corners of a unit square
float interpolate2(float v1, float v2, float v3, float v4, float xmu, float ymu) {
  float s = interpolate1(v1, v2, xmu);
  float t = interpolate1(v3, v4, xmu);
  return interpolate1(s, t, ymu);
}

float interpolate3(float v1, float v2, float v3, float v4, float v5, float v6, float v7, float v8, float xmu, float ymu, float zmu) {
  float s = interpolate1(v1, v2, xmu);
  float t = interpolate1(v3, v4, xmu);
  float u = interpolate1(v5, v6, xmu);
  float v = interpolate1(v7, v8, xmu);

  return interpolate2(s, t, u, v, ymu, zmu);
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

   return interpolate3(s, t, u, v, m , n, p, q, ymu, zmu, wmu);
}


// noise has range equal to range of smooth
float noise3(float x, float y, float z) {
  const float NUM_OCTAVES = 4.0;
  float total = 0.0;

  for (float i = 0.0; i < NUM_OCTAVES; i++) {
    float f_i = float(i);
    float frequency = pow(2.0,f_i);
    float d = 3.8932;

    x = x * frequency / d;
    y = y * frequency / d;
    z = z * frequency / d;

    float x_c = ceil(x);
    float y_c = ceil(y);
    float z_c = ceil(z);

    float x_f = floor(x);
    float y_f = floor(y);
    float z_f = floor(z);

    float xmu = fract(x);
    float ymu = fract(y);
    float zmu = fract(z);

    float v1 = smooth3(x_f, y_f, z_c);
    float v2 = smooth3(x_c, y_f, z_c);
    float v3 = smooth3(x_f, y_c, z_c);
    float v4 = smooth3(x_c, y_c, z_c);

    float v5 = smooth3(x_f, y_f, z_f);
    float v6 = smooth3(x_c, y_f, z_f);
    float v7 = smooth3(x_f, y_c, z_f);
    float v8 = smooth3(x_c, y_c, z_f);

    total += interpolate3(v1, v2, v3, v4, v5, v6, v7, v8, xmu, ymu, zmu);
  }

  return total / NUM_OCTAVES;
}

float noise4(float x, float y, float z, float w) {
  const float NUM_OCTAVES = 4.0;
  float total = 0.0;

  for (float i = 0.0; i < NUM_OCTAVES; i++) {
    float f_i = float(i);
    float frequency = pow(2.0,f_i);
    float d = 3.8932;

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

    float v1 = smooth4(x_f, y_f, z_c, w_c);
    float v2 = smooth4(x_c, y_f, z_c, w_c);
    float v3 = smooth4(x_f, y_c, z_c, w_c);
    float v4 = smooth4(x_c, y_c, z_c, w_c);

    float v5 = smooth4(x_f, y_f, z_f, w_c);
    float v6 = smooth4(x_c, y_f, z_f, w_c);
    float v7 = smooth4(x_f, y_c, z_f, w_c);
    float v8 = smooth4(x_c, y_c, z_f, w_c);

    float v9  = smooth4(x_f, y_f, z_c, w_f);
    float v10 = smooth4(x_c, y_f, z_c, w_f);
    float v11 = smooth4(x_f, y_c, z_c, w_f);
    float v12 = smooth4(x_c, y_c, z_c, w_f);

    float v13 = smooth4(x_f, y_f, z_f, w_f);
    float v14 = smooth4(x_c, y_f, z_f, w_f);
    float v15 = smooth4(x_f, y_c, z_f, w_f);
    float v16 = smooth4(x_c, y_c, z_f, w_f);

    total += interpolate4(v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, xmu, ymu, zmu, wmu);
  }

  return total / NUM_OCTAVES;
}

float noise(float x, float y, float z, float w) {
  // return noise4(x, y, z, w);
  return noise3(x, y - time, z);
}

void main() {
    float r = noise(position.x, position.y, position.z, time);
    vUv = vec2(0.0, 1.1 * r);
    nor = normal.xyz;
    vec3 pos = position + 200.0 * r * nor;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( pos, 1.0 );
}
