varying vec2 vUv;
varying float noise;
uniform sampler2D image;

//have multiple sampler2D variables for those image variables
//have flag, and have if statement for "if flag == some number", then do this image

void main() {


  //vec2 uv = vec2(1,1) - vUv;
  vec4 color = texture2D( image, vUv );

  gl_FragColor = vec4( color.rgb, 1.0 );

}
