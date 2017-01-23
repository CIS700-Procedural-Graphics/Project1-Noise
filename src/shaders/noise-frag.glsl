varying vec2 vUv;
varying vec3 vNormal;

varying float noise;
uniform sampler2D image;


void main() {

  vec4 color = vec4(vNormal.x, vNormal.y, vNormal.z, 0);

  gl_FragColor = vec4( color.rgb, 1.0);

}