uniform vec3 grads[12];
uniform float time;
uniform bool cell;

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
	return lerp(lerp(a, b, u), lerp(c, d, u), v);
}

float tlerp(float a, float b, float c, float d, float e, float f, float g, float h, float u, float v, float w) { 
	return lerp(blerp(a,b,c,d,u,v), blerp(e,f,g,h,u,v), w);
}

float perlin_noise(vec3 point, float freq, float amp, float t) {
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

vec3 cell_hash(vec3 p) {
	float x = mod(7.0 * p.x * p.y / p.z, 23.0)/23.0;
	float y = mod(13.0 * p.y * p.z / p.x, 23.0)/23.0;
	float z = mod(17.0 * p.z * p.x / p.y, 23.0)/23.0;
	return vec3(x,y,z);
}

vec2 cellular_noise(vec3 point) {
	float dist1 = 99.9;
	float dist2 = 99.9;
	vec3 cell = floor(point); 
	vec3 center = cell_hash(cell) + cell;
	for (int i = 0; i < 9; i++) {
		for (int j = 0; j < 3; j++) {
			for (int k = 0; k < 3; k++) {
				vec3 adj = vec3(cell.x - 1.0 + float(i), cell.y - 1.0 + float(j), cell.z - 1.0 + float(k));
				vec3 opt = cell_hash(adj) + adj;
				float d = distance(center, opt);
				if (d < dist1) {
					dist1 = d; dist2 = dist1;
				} else if (d < dist2) {
					dist2 = d;
				}
			}
		}
	}
	return vec2(dist1, dist2);
} 

void main() {

    vNormal = normal;
    vPosition = position;
    noise = 0.0;
    if (cell) {
    	noise = (cellular_noise(position).y - cellular_noise(position).x) / cellular_noise(position).x;
    } else { 
    	for (int i = 0; i < 5; i++) {
    		float freq = pow(2.0, float(i));
    		float amp = pow(0.80, float(i));
    		noise += perlin_noise(position, freq, amp, time);
    	}
    } 


    vec4 p =  projectionMatrix * modelViewMatrix * vec4( position + noise * vNormal, 1.0 );
    gl_Position = p;
}