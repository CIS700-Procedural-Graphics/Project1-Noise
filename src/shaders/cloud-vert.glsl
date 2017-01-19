varying vec3 norm;

void main() {
	norm = normal;

    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}