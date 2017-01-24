varying vec2 vUv;
varying vec3 vNormal;
varying float time;

uniform int frequencyBands[32];

void main() {
    vUv = uv;
    vNormal = normalMatrix * normal;

    vec3 pos = position;
    float radius = length(pos.xz * .045); 

    float f = float(frequencyBands[int(floor(mod(radius * 8.0, 32.0)))]);

    pos.y += pow(f / 256.0, 4.0) * 16.0;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0 );
}