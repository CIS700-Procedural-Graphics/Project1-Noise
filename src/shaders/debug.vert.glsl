// #define FULLSCREEN

uniform float time;

varying vec2 vUv;

void main() {
    vUv = uv;

    vec3 pos = position;

#ifdef FULLSCREEN
    gl_Position = vec4(pos * 2.0, 1.0);
#else
    gl_Position = vec4(pos * .5 + vec3(.75, -.75, 1.0), 1.0);
#endif

}