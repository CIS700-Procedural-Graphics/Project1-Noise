varying vec2 vUv;
varying vec3 vPos;
uniform sampler2D image;
uniform float time;

varying vec3 vNor;


void main() {

  vec4 color = texture2D( image, vUv );
  gl_FragColor = vec4( color.rgb, 1.0 );

}