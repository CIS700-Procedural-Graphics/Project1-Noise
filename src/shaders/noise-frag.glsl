varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vUv;
// varying float noise;

#define M_PI 3.1415926535897932384626433832795

uniform float uTime;

// Simplex 2D noise
//
vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
           -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}







vec2 cosine_interpolate(vec2 a, vec2 b, float t) 
{
  float cos_t = ( 1.0 - cos(t * M_PI) ) * 0.5;
  return mix(a, b, cos_t);
}


void main() {


  // vec3 color = vec3( 1.0, 1.0, 1.0 ) * cos( uTime );
  // vec3 color = vec3( 1.0, 0.0, 0.0 ) * snoise(cos(vUv * 10.0 * sin(0.1 * uTime)) ) ;

  // vec3 color = vec3( 1.0, 0.0, 0.0 ) * snoise( cos( vUv * 10.0 ) );
  vec3 color1 = 1.0 * vec3( 1.0, 0.0, 0.0 ) * snoise( cos( vUv * 1.0 ) );
  vec3 color2 = 0.5 * vec3( 1.0, 0.0, 0.0 ) * snoise( sin( vUv * 10.0 + M_PI) );
  vec3 color3 = 0.1 * vec3( 1.0, 0.0, 0.0 ) * snoise( cos( vUv * 20.0 + 1.0 ) );


  vec3 color = color1 + color2 + color3;

  // vec3 color = vec3( 1.0, vUv) * cos( uTime );

  gl_FragColor = vec4( color.rgb, 1.0 );
  // gl_FragColor = vec4( 1.0, 1.0, 1.0 , 1.0 );
  // gl_FragColor = vec4(0.0);

}