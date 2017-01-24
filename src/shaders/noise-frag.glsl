varying vec2 vUv;
varying vec3 vNormal;
varying float vNoiseValue;

varying float noise;
uniform sampler2D image;

float lerp(float a, float b, float t) {
	return a * (1.0 - t) + b * t; 
}

void main() {
	vec4 color = vec4(vNoiseValue * vNormal.x, vNoiseValue * vNormal.y, vNoiseValue * vNormal.z, 1.0);
		// vec4 color = vec4(vNormal.x, vNormal.y, vNormal.z, 1.0);
	gl_FragColor = color;

}