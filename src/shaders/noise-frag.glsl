varying vec2 vUv;
varying vec3 vNormal;
varying float vNoiseValue;
varying float noise;
uniform sampler2D image;
uniform float u_color; 

float lerp(float a, float b, float t) {
	return a * (1.0 - t) + b * t; 
}

void main() {
	// Color based on noise values and user input
	vec4 color = vec4(
		0.1 * vNoiseValue + 0.4 + u_color, 
		vNormal.y * vNoiseValue + 0.7, 
		0.7 * vNoiseValue + 0.4, 
		1.0);
	// Color based on surface normals 
    // vec4 color = vec4(vNormal.x, vNormal.y, vNormal.z, 1.0);
	gl_FragColor = color;

}