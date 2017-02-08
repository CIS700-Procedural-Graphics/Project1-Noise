varying vec2 vUv;
uniform float time;
uniform int octaves;
uniform float magnitude;
uniform float rate;
uniform float persistence;
varying float noise;

float PI = 3.14159265358979323;
float gen_noise(float x, float y, float z) {
  return fract(sin(dot(vec3(x, y, z) ,vec3(12.9898,78.233,53.641))) * 43758.5453);
}

float linear_interpolation(float a, float b, float t) {
  return a * (1.0 - t) + b * t;
}

float cosine_interpolation(float a, float b, float t) {
  return linear_interpolation(a, b, (1.0 - cos(t * PI)) * 0.5);
}

float noise_interpolation(float x, float y, float z) {
  float x0 = floor(x),
        x1 = floor(x) + 1.0,
        y0 = floor(y),
        y1 = floor(y) + 1.0,
        z0 = floor(z),
        z1 = floor(z) + 1.0;

  float i000 = gen_noise(x0, y0, z0),
        i001 = gen_noise(x0, y0, z1),
        i010 = gen_noise(x0, y1, z0),
        i011 = gen_noise(x0, y1, z1),
        i100 = gen_noise(x1, y0, z0),
        i101 = gen_noise(x1, y0, z1),
        i110 = gen_noise(x1, y1, z0),
        i111 = gen_noise(x1, y1, z1);

  float dx = x - x0,
        dy = y - y0,
        dz = z - z0;

  float ix00 = cosine_interpolation(i000, i100, dx),
        ix01 = cosine_interpolation(i001, i101, dx),
        ix10 = cosine_interpolation(i010, i110, dx),
        ix11 = cosine_interpolation(i011, i111, dx);

  float iy0 = cosine_interpolation(ix00, ix10, dy),
        iy1 = cosine_interpolation(ix01, ix11, dy);

  float iz = cosine_interpolation(iy0, iy1, dz);
  return iz;
}

float multi_octave_noise(float x, float y, float z, float persistence) {
	float total = 0.0;
	for (int i = 0; i < 10; i++) {
    if (i >= octaves) {
      break;
    }
		float freq = pow(2.0, 1.0);
		float amp = pow(persistence, 1.0);

		total += noise_interpolation(freq * x, freq * y, freq * z) * amp;
	}

	return total;
}

void main() {
    vUv = uv;
    float ptb = time * rate * 0.001;
    noise = multi_octave_noise(position.x + ptb, position.y + ptb, position.z + ptb, persistence) * magnitude;
    vec4 new_pos = vec4(noise * normal + position, 1.0);
    gl_Position = projectionMatrix * modelViewMatrix * new_pos;
}
