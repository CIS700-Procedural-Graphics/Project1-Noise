varying vec2 vUv;
varying vec3 col;
varying float noise;
uniform sampler2D image;

void main() {

  //vec2 uv = vec2(1,1) - vUv;
  //vec4 color = texture2D( image, uv );

  //vec4 color = vec4( abs(normal.x),abs(normal.y),abs(normal.z), 1.0 );
  gl_FragColor = vec4( col.rgb, 1.0 );

}