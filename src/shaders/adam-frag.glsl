varying vec2 vUv;
varying vec3 nor;
varying float noise;
varying float mus;

uniform sampler2D image;
uniform vec3 colorMult;


void main() {

  vec4 color = texture2D( image, vUv );

  gl_FragColor = vec4( (1. - noise) * nor.rgb +  noise * colorMult, 1.0 );
  // gl_FragColor = vec4( mus * color.rgb, 1.0 );
}