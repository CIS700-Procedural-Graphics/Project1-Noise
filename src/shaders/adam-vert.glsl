/////////////////////////////////////////////////////////////////

//noise function taken from:
//https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
float mod289(float x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec4 mod289(vec4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 perm(vec4 x) {
	return mod289(((x * 34.0) + 1.0) * x);
}

float sample_noise(vec3 p) {
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

//////////////////////////////////////////////////////////////////

float linear_interpolate(float a, float b, float t) {
  return a * (1.0 - t) + b * t;
}

#define M_PI 3.1415926535897932384626433832795
float cosine_interpolate(float a, float b, float t) {
  float cos_t = (1.0 - cos(t * M_PI)) * 0.5;
  return linear_interpolate(a, b, cos_t);
}

float lattice_interpolate(vec3 pos) 
{
  //get the 8 corners of the cube
  vec3 P1 = vec3(floor(pos.x), floor(pos.y), floor(pos.z));
  vec3 P2 = vec3(P1.x + 1.0, P1.y, P1.z);
  vec3 P3 = vec3(P1.x, P1.y + 1.0, P1.z);
  vec3 P4 = vec3(P1.x, P1.y, P1.z + 1.0);
  vec3 P5 = vec3(P1.x + 1.0, P1.y + 1.0, P1.z);
  vec3 P6 = vec3(P1.x + 1.0, P1.y, P1.z + 1.0);
  vec3 P7 = vec3(P1.x, P1.y + 1.0, P1.z + 1.0);
  vec3 P8 = vec3(P1.x + 1.0, P1.y + 1.0, P1.z + 1.0);

  //get the noise values of the 8 corners
  float p1 = sample_noise(P1);
  float p2 = sample_noise(P2);
  float p3 = sample_noise(P3);
  float p4 = sample_noise(P4);
  float p5 = sample_noise(P5);
  float p6 = sample_noise(P6);
  float p7 = sample_noise(P7);
  float p8 = sample_noise(P8);

  //get the interpolated noise value of the 8 corners
  float xT = distance(P1.x, pos.x) / distance(P1.x, P2.x);
  float c1 = cosine_interpolate(p1, p2, xT);
  float c2 = cosine_interpolate(p3, p5, xT);
  float c3 = cosine_interpolate(p4, p6, xT);
  float c4 = cosine_interpolate(p7, p8, xT);

  float yT = distance(P1.y, pos.y) / distance(P1.y, P3.y);
  float b1 = cosine_interpolate(c1, c2, yT);
  float b2 = cosine_interpolate(c3, c4, yT);

  float zT = distance(P1.z, pos.z) / distance(P1.z, P4.z);
  float a = cosine_interpolate(b1, b2, zT);

  return a;
} 

float multioctave_noise(vec3 pos) {
  float persistence = 0.8;
  float total = 0.0;
  for (float octave = 0.0; octave < 3.0; octave++) {
      float frequency = pow(2.0, octave);
      float amplitude = pow(persistence, octave);
      total += lattice_interpolate(vec3(frequency) * pos) * amplitude;
  }
  return total;
}

/////////////////////////////////////////////////////////////////


//for more given uniform variables, go to:
//https://threejs.org/docs/api/renderers/webgl/WebGLProgram.html

//varying vec2 vUv;
varying float noise;
varying vec3 normColor;
varying vec3 vecPos;
varying vec3 vecNormal;

uniform float time;
uniform float freq; //ranges from 0 to 255
uniform float amp;

float turbulence( vec3 p ) {
    float w = 100.0;
    float t = -0.5;
    for (float f = 1.0 ; f <= 10.0 ; f++ ){
        float power = pow( 2.0, f );
        t += abs( multioctave_noise( vec3( power * p )) / power );
    }
    return t;
}

void main() {

    // add time to the noise parameters so it's animated
    noise = 10.0 *  -0.10 * turbulence( 0.5 * normal + time );
    // amp can be changed to by slider to change magnitude of fluctuation
    float b = amp * freq * multioctave_noise( 0.05 * position + vec3( 2.0 * time ) );
    float displacement = - noise + b;
    
    vec3 newPosition = position + normal * displacement;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );

    //passing to fragment shader
    //vUv = uv;
    normColor = vec3( 0.6*abs(normal.x), 0.6*abs(normal.y), 0.6*abs(normal.z) );
    vecPos = (modelMatrix * vec4(newPosition, 1.0)).xyz;
    vecNormal = normalMatrix * normal;

    //rotate light along with blob
    //vecPos = newPosition;
    //vecNormal = normal;
}





/*
///////////////////// Better Noise Generation //////////////////////
//based on https://github.com/ashima/webgl-noise

vec3 mod289(vec3 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec3 fade(vec3 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise, periodic variant
float pnoise(vec3 P, vec3 rep)
{
  vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
  vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}
///////////////////////////////////////////////////////

//for more given uniform variables, go to:
//https://threejs.org/docs/api/renderers/webgl/WebGLProgram.html

//varying vec2 vUv;
varying float noise;
//varying vec3 normColor;
varying vec3 vecPos;
varying vec3 vecNormal;

uniform float time;
uniform float freq; //ranges from 0 to 255
uniform float amp;

float turbulence( vec3 p ) {
    float w = 100.0;
    float t = -0.5;
    for (float f = 1.0 ; f <= 10.0 ; f++ ){
        float power = pow( 2.0, f );
        t += abs( pnoise( vec3( power * p ), vec3( 10.0, 10.0, 10.0 ) ) / power );
    }
    return t;
}

void main() {

    // add time to the noise parameters so it's animated
    noise = 10.0 *  -0.10 * turbulence( .5 * normal + time );
    // amp can be changed to by slider to change magnitude of fluctuation
    float b = amp * freq * pnoise( 0.05 * position + vec3( 2.0 * time ), vec3( 100.0 ) );
    float displacement = - noise + b;
    
    vec3 newPosition = position + normal * displacement;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );

    //passing to fragment shader
    //vUv = uv;
    //normColor = vec3( 0.6*abs(normal.x), 0.6*abs(normal.y), 0.6*abs(normal.z) );
    vecPos = (modelMatrix * vec4(newPosition, 1.0)).xyz;
    vecNormal = normalMatrix * normal;

    //rotate light along with blob
    //vecPos = newPosition;
    //vecNormal = normal;
}
*/





/*
varying vec2 vUv;
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}
*/