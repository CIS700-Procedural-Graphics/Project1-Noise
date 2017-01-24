uniform float time;

varying vec2 vUv;

void main() {
    vUv = uv;

    vec3 pos = position;

    gl_Position = vec4(pos.xy * 2.0, .01, 1.0);
}