varying vec3 vNormal;
varying float noise;
uniform sampler2D image;
uniform sampler2D alpha;

void main() {
  vec4 textureCol = texture2D( image, vec2(0.0, noise));
  vec4 alphaCol = texture2D( alpha, vec2(0.0, noise));
  float alpha = alphaCol.x;
  vec4 color = textureCol;

  gl_FragColor = vec4( color.xyz, 1.0);
}