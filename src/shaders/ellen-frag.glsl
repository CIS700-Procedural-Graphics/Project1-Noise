varying vec2 vUv;
varying vec3 vNormal;
varying float noise;
uniform sampler2D image;


void main() {

  // vec4 color = texture2D( image, vUv );
  // gl_FragColor = vNormal;

  gl_FragColor = vec4(vNormal, 1.0);
}