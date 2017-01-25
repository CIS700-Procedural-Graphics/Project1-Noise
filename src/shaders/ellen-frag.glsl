varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying float noise;
uniform sampler2D image;
varying float vTime;

void main() {
  gl_FragColor = vec4(vNormal, 1.0);
}

