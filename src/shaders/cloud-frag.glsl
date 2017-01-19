varying vec3 norm;

void main() {

  vec3 color = norm;

  gl_FragColor = vec4( color.rgb, 1.0 );

}