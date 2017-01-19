
varying vec2 vUv;
varying vec3 color;
void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
    color = vec3(normal.x, normal.y, normal.z);
}