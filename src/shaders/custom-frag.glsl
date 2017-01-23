varying vec2 vUv;
varying float noise;
varying vec3 nor;

uniform sampler2D image;

void main() {

  vec4 color = texture2D( image, vUv );

  gl_FragColor = vec4( color.rgb, 1.0 );
}
