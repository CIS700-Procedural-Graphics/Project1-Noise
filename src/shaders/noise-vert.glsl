uniform vec3 grads[12];
uniform float time;
uniform int num_octaves;
uniform float amplitude;
uniform float frequency;

varying vec3 vPosition;
varying vec3 vNormal;
varying float noise;

#define PI 3.14159265

int hash(vec3 p) {
	return int(mod(sin(dot(p, vec3(12.9898, 78.233,1938.2)))*43758.5453,12.0));
}

float new_t(float t) {
	return 6.0 * t*t*t*t*t - 15.0 * t*t*t*t + 10.0 * t*t*t;
}

float lerp(float a, float b, float t) {
  return a * (1.0-t) + b * t;
}

float cos_lerp(float a, float b, float t) {
  float cos_t = (1.0 - cos(t * PI)) * 0.5;
  return lerp(a,b,cos_t);
}

float blerp(float a, float b, float c, float d, float u, float v) {
	return cos_lerp(cos_lerp(a, b, u), cos_lerp(c, d, u), v);
}

float tlerp(float a, float b, float c, float d, float e, float f, float g, float h, float u, float v, float w) { 
	return cos_lerp(blerp(a,b,c,d,u,v), blerp(e,f,g,h,u,v), w);
}

float p_noise(vec3 point, float freq, float amp, float t) {
	vec3 p = freq * point/ 10.0 + vec3(t/100.0);
	vec3 cube1 = floor(p); 
	vec3 cube2 = vec3(ceil(p.x), floor(p.yz)); 
	vec3 cube3 = vec3(floor(p.x), ceil(p.y), floor(p.z));
	vec3 cube4 = vec3(ceil(p.xy), floor(p.z));
	vec3 cube5 = vec3(floor(p.xy), ceil(p.z));
	vec3 cube6 = vec3(ceil(p.x), floor(p.y), ceil(p.z));
	vec3 cube7 = vec3(floor(p.x), ceil(p.yz));
	vec3 cube8 = ceil(p);

	float u = new_t((p-cube1).x);
	float v = new_t((p-cube1).y);
	float w = new_t((p-cube1).z);

	float a = dot(p - cube1, grads[hash(cube1)]);
	float b = dot(p - cube2, grads[hash(cube2)]);
	float c = dot(p - cube3, grads[hash(cube3)]);
	float d = dot(p - cube4, grads[hash(cube4)]);
	float e = dot(p - cube5, grads[hash(cube5)]);
	float f = dot(p - cube6, grads[hash(cube6)]); 
	float g = dot(p - cube7, grads[hash(cube7)]);
	float h = dot(p - cube8, grads[hash(cube8)]);

	return amp * tlerp(a,b,c,d,e,f,g,h,u,v,w);
}

float perlin_noise(vec3 p, float freq, float amp, float t) { 
	float x0 = p_noise(p, freq,amp,t);
	float x_1 = p_noise(vec3(p.x - 1.0, p.yz), freq,amp,t);
	float x1 = p_noise(vec3(p.x + 1.0, p.yz), freq,amp,t);
	float y_1= p_noise(vec3(p.x, p.y - 1.0, p.z), freq,amp,t);
	float y1 = p_noise(vec3(p.x, p.y + 1.0, p.z), freq,amp,t);
	float z_1 = p_noise(vec3(p.xy, p.z - 1.0), freq,amp,t);
	float z1 = p_noise(vec3(p.xy, p.z + 1.0), freq,amp,t);
	return x0/4.0 + x_1/8.0 + x1/8.0 + y_1/8.0 + y1/8.0 + z_1/8.0 + z1/8.0;
}

void main() {

    vNormal = normal;
    vPosition = position;
    noise = 0.0;
    	for (int i = 0; i < 20; i++) {
    		if (i < num_octaves) {
    			float freq = pow(frequency, float(i));
    			float amp = pow(amplitude, float(i));
    			noise += p_noise(position, freq, amp, time);
    		}	
    	}

    vec4 p =  projectionMatrix * modelViewMatrix * vec4( position + noise * vNormal, 1.0 );
    gl_Position = p;
}