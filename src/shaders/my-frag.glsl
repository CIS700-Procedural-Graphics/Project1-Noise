varying vec2 vUv;
varying float noise;
uniform sampler2D image;
varying vec3 vNormal;

void main() {

  gl_FragColor = vec4( vNormal.rgb, 1.0 );

}