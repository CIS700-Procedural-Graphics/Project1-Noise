varying vec2 vUv;
varying float vNoise;
varying vec3 vNormal;

float linearInterpolate(float a, float b, float t) {
	return a * (1.0 - t) + b * t;
}

void main() {
  float r = linearInterpolate(0.0, 0.9, vNoise); 
  float g = linearInterpolate(0.0, 0.9, vNoise); 
  float b = linearInterpolate(0.0, 0.9, vNoise); 

  gl_FragColor = vec4(r, g, b, 1.0);
  //gl_FragColor = vec4(vNormal.rgb, 1.0);
}