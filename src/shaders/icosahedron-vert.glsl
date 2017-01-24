varying vec3 norm;
varying vec2 vUv;
uniform float time;
uniform float noise_scale;


float noise_1(float x, float y, float z) {
  return cos(z * sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5453);
}

float noise_2(float x, float y, float z) {
  return dot(vec2(sin(x), 14591), vec2(cos(y), 179)) * tan(z);
}

float noise_3(float x, float y, float z) {
  float sum = (x * 13.0) + (y * 17.0) + (z * 19.0);
  return sin(sum);
}

float linear_interpolate(float a, float b, float t) {
  return a * (1.0 - t) + b * t;
}

float cosine_interpolate(float a, float b, float t) {
  float cos_t = (1.0 - cos(t * 3.1459)) * 0.5;
  return linear_interpolate(a, b, cos_t);
}

float interpolate_noise(float x, float y, float z) {
  //pos
  float pos_NE = noise_1(ceil(x), ceil(y), ceil(z));
  float pos_NW = noise_1(floor(x), ceil(y), ceil(z));
  float pos_SW = noise_1(floor(x), ceil(y), floor(z));
  float pos_SE = noise_1(ceil(x), ceil(y), floor(z));

  //neg
  float neg_NE = noise_1(ceil(x), floor(y), ceil(z));
  float neg_NW = noise_1(floor(x), floor(y), ceil(z));
  float neg_SW = noise_1(floor(x), floor(y), floor(z));
  float neg_SE = noise_1(ceil(x), floor(y), floor(z));

  float x_t = ceil(x) - x;
  float z_t = ceil(z) - z;
  float y_t = ceil(y) - y;

  float pos_north = cosine_interpolate(pos_NE, pos_NW, x_t);
  float pos_south = cosine_interpolate(pos_SE, pos_SW, x_t);
  float pos_ns = cosine_interpolate(pos_north, pos_south, z_t);

  float neg_north = cosine_interpolate(neg_NE, neg_NW, x_t);
  float neg_south = cosine_interpolate(neg_SE, neg_SW, x_t);
  float neg_ns = cosine_interpolate(neg_north, neg_south, z_t);

  float res_noise = cosine_interpolate(pos_ns, neg_ns, y_t);

  return res_noise;
}

void main() {
  float pos_x = position[0];
  float pos_y = position[1];
  float pos_z = position[2];
  float noise = interpolate_noise(pos_x, pos_y, time);
  float adj_noise = noise_scale / 100.0 * noise;
  vec3 new_pos = position + (adj_noise) * normal;
  vUv = vec2(uv[0] * abs(noise), uv[1] * abs(noise));
  gl_Position = projectionMatrix * modelViewMatrix * vec4( new_pos, 1.0 );
}

