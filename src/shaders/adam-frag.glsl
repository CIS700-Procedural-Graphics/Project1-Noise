varying vec2 vUv;
varying float noise;
uniform sampler2D image;


void main() {

  vec4 color = texture2D( image, vUv );

  gl_FragColor = vec4( color.gbr, 1.0 );

}