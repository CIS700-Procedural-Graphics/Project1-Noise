varying vec2 vUv;
varying vec3 vNormal;
varying float noise;

void main() {
  vec2 uv = vec2(1,1) - vUv;
  vec4 color = vec4( vNormal, 1.0 );

  gl_FragColor = vec4( color.rgb, 1.0 );
}