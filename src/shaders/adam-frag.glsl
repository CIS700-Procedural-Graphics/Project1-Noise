varying vec2 vUv;
varying vec3 nor;
varying float noise;
uniform sampler2D image;


void main() {

  vec4 color = texture2D( image, vUv );

  gl_FragColor = vec4( (1. - noise) * nor.rgb, 1.0 );

}