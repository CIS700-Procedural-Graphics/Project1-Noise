
varying vec3 vNormal;
varying float noise;
uniform sampler2D image;
uniform sampler2D alpha;

void main() {
  vec3 color_1 = vec3(0.0 / 255.0, 27.0 / 255.0, 72.0 / 255.0);
  vec3 color_2 = vec3(0.0 / 255.0, 68.0 / 255.0, 129.0 / 255.0);
  vec3 color_3 = vec3(1.0 / 255.0, 138.0 / 255.0, 190.0 / 255.0);
  vec3 color_4 = vec3(151.0 / 255.0, 202.0 / 255.0, 219.0 / 255.0);
  vec3 color_5 = vec3(222.0 / 255.0, 232.0 / 255.0, 241.0 / 255.0);

  vec3 interpCol = vec3(1.0, 1.0, 1.0);
  if (noise < 0.25) {
    interpCol = mix(color_1, color_2, 1.0 - (noise - 0.0) / 0.25);
  }
  if (noise >= 0.25 && noise < 0.5) {
    interpCol = mix(color_2, color_3, 1.0 - (noise - 0.25) / 0.25);
  }
  if (noise >= 0.5 && noise < 0.75) {
    interpCol = mix(color_3, color_4, 1.0 - (noise - 0.5) / 0.25);
  }
  if (noise >= 0.75 && noise <= 1.0) {
    interpCol = mix(color_4, color_5, 1.0 - (noise - 0.75) / 0.25);
  }

  vec4 textureCol = texture2D( image, vec2(0.0, noise));
  vec4 alphaCol = texture2D( alpha, vec2(0.0, noise));
  float alpha = alphaCol.x;
  vec4 color = textureCol;

  gl_FragColor = vec4( color.rgb, alpha);

}