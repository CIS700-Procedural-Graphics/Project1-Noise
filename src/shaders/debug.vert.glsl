uniform float time;
uniform vec2 SCREEN_SIZE;

varying vec2 vUv;

void main() {
    vUv = uv;

    float aspect = SCREEN_SIZE.x / SCREEN_SIZE.y;
    vec3 pos = position;

#ifdef FULLSCREEN
    gl_Position = vec4(pos * 2.0, 1.0);
#else
	pos.y *= aspect;
	pos.y -= .5 * aspect;
    gl_Position = vec4(pos * .5 + vec3(-.75, 1.0, 1.0), 1.0);
#endif

}