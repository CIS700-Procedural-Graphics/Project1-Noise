varying vec2 vUv;
varying float noise;
uniform sampler2D image;


// so called "canonical" pseudoranom
float random_1(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float random1d_1(float x){
  return random_1(vec2(x, 1.337));
}

float random3d_1(vec3 inp){
  return random1d_1(random1d_1(random1d_1(inp.x) * inp.y) * inp.z);
}


float lerp(float a, float b, float x) {
  return a + x * (b - a);
}

//float lerp(float a, float b, float x){
//  return a*(1-x) + b*x;
//}

// test of twenty four and thirty six miles per hour.
//

float bilinear_interp(float a, float b, float c, float d, float x, float y){

  float left = lerp(a, b, x);
  float right = lerp(c, d, x);
  return lerp(left, right, y);
}

float trilinear_interp(float a, float b, float c, float d, float e, float f, float g, float h, float x, float y, float z){
  float bottom = bilinear_interp(a, b, c, d, x, y);
  float top = bilinear_interp(e, f, g, h, x, y);
  return lerp(bottom, top, z);
}

float trilinear_interp2(float a, float b, float c, float d, float e, float f, float g, float h, float x, float y, float z){
  // adapted from https://en.wikipedia.org/wiki/Trilinear_interpolation

  float xd = (x - floor(x));
  float yd = (y - floor(y));
  float zd = (z - floor(z));

  float c00 = a * (1.0 - xd) + d * xd;
  float c01 = b * (1.0 - xd) + c * xd;
  float c10 = e * (1.0 - xd) + h * xd;
  float c11 = f * (1.0 - xd) + g * xd;

  float c0 = c00 * (1.0 - yd) + c10 * yd;
  float c1 = c01 * (1.0 - yd) + c11 * yd;

  float cf = c0 * (1.0 - zd) + c1 * zd;

  return cf;
}

// trilinear

float interp_noise(float x, float y, float z){
  // interpolating the surrounding lattice values (for 3D, this means the surrounding eight 'corner' points)

  // start by assigning lattice as whole numbers to start
  float a = random3d_1(vec3(floor(x), floor(y), floor(z)));
  float b = random3d_1(vec3(floor(x), floor(y+1.0), floor(z)));
  float c = random3d_1(vec3(floor(x+1.0), floor(y+1.0), floor(z)));
  float d = random3d_1(vec3(floor(x+1.0), floor(y), floor(z)));
  float e = random3d_1(vec3(floor(x), floor(y), floor(z+1.0)));
  float f = random3d_1(vec3(floor(x), floor(y+1.0), floor(z+1.0)));
  float g = random3d_1(vec3(floor(x+1.0), floor(y+1.0), floor(z+1.0)));
  float h = random3d_1(vec3(floor(x+1.0), floor(y), floor(z+1.0)));

  return trilinear_interp2(a, b, c, d, e, f, g, h, x, y, z);
}

void main() {

  vec2 uv = vec2(1,1) - vUv;
  vec4 color = texture2D( image, uv );

  gl_FragColor = vec4( color.rgb, 1.0 );

}