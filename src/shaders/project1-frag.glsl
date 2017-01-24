varying vec2 vUv;
varying float vNoise;
uniform sampler2D image;

float getSin(float t){
  return sin( t * 1.57);
}

void main() {

  //vec4 color = texture2D( image, vUv );
  //gl_FragColor = vec4( color.gbr, 1.0 );
  //float val = getSin( vUv.x );
  //gl_FragColor = vec4( val, val, val, 1.0 );
  
  gl_FragColor = vec4( vNoise*vNoise*vNoise, vNoise*vNoise, (1.0-vNoise) * (1.0-vNoise), 1.0 );
}