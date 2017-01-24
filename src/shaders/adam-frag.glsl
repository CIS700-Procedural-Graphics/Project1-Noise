varying vec2 vUv;
varying float n;
uniform sampler2D image;
varying vec3 col;
varying vec3 nor;
varying float s;

void main() {

  vec2 uv = vec2(1,1) - vUv * cos(n);
  vec4 color = texture2D( image, uv * sin(n) + s);

  gl_FragColor = vec4( color.rgb, 1.0 );
  
  //gl_FragColor = vec4(abs(nor.rgb), 1.0);

  //gl_FragColor = vec4(col.rgb, 1.0);
}