// varying vec2 vUv;
// varying float noise;

uniform float uTime;


void main() {


  vec3 color = vec3( 1.0, 1.0, 1.0 ) * cos( uTime );

  gl_FragColor = vec4( color.rgb, 1.0 );
  // gl_FragColor = vec4( 1.0, 1.0, 1.0 , 1.0 );
  // gl_FragColor = vec4(0.0);

}