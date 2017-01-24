varying vec2 vUv;
varying vec3 vNormal;
varying float vNoise;
uniform sampler2D image;

void main() {
  vec2 uv = vec2(1,1) - vUv;
  vec3 noise_col = vec3(vNoise,vNoise,vNoise);
  vec4 color = vec4(noise_col, 1.0 );

  gl_FragColor = vec4( color.rgb, 1.0 );
}