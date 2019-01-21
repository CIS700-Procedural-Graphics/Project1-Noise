

varying vec2 vUv;
varying float noise;
uniform float time;
varying vec3 vNormal;
varying float vDisplacement;

void main() {
  // colour is RGBA: u, v, 0, 1
  gl_FragColor = vec4( vec3( vDisplacement/20.0+.5, vDisplacement/20.0+.2, 0. ), vDisplacement );

}