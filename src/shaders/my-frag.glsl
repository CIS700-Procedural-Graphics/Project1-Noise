varying vec2 vUv;
varying float vNoise;
uniform sampler2D image;
varying vec3 vNormal;

float linearInterpolate(float a, float b, float t) {
	return a * (1.0 - t) + b * t;
}

void main() {
  float r = linearInterpolate(vNormal.rgb[0], 0.9, vNoise); 
  float g = linearInterpolate(vNormal.rgb[1], 0.9, vNoise); 
  float b = linearInterpolate(vNormal.rgb[2], 0.9, vNoise); 

  gl_FragColor = vec4( r, g, b, 1.0 );
}