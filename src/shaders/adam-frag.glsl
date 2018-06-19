

varying vec2 vUv;
varying float noise;

uniform float time;


void main() {


  // colour is RGBA: u, v, 0, 1
  gl_FragColor = vec4( vec3( vUv, 0. ), 1. );

}